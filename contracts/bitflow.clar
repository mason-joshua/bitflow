;; Title: BitFlow Payment Gateway
;;
;; Summary: Advanced decentralized payment orchestration platform delivering 
;; institutional-grade sBTC transaction processing with dynamic fee optimization,
;; multi-party settlement coordination, and comprehensive business intelligence
;;
;; Description: BitFlow Payment Gateway represents the next evolution in blockchain
;; payment infrastructure, offering sophisticated financial technology solutions for
;; modern enterprises. This contract delivers a comprehensive ecosystem featuring
;; intelligent invoice automation, granular fee management across multiple tiers,
;; instantaneous settlement protocols, and enterprise-ready analytics dashboards.
;;
;; Key innovations include advanced webhook orchestration for seamless third-party
;; integrations, cryptographically secured transaction references, sophisticated
;; refund mechanisms with automated reconciliation, and military-grade security
;; through temporal payment locks and isolated balance architecture. The platform
;; empowers businesses to scale their digital payment operations while maintaining
;; complete financial sovereignty and operational transparency.

;; SYSTEM CONSTANTS
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_INVALID_AMOUNT (err u101))
(define-constant ERR_PAYMENT_NOT_FOUND (err u102))
(define-constant ERR_PAYMENT_ALREADY_PROCESSED (err u103))
(define-constant ERR_PAYMENT_EXPIRED (err u104))
(define-constant ERR_INSUFFICIENT_BALANCE (err u105))
(define-constant ERR_BUSINESS_NOT_REGISTERED (err u106))
(define-constant ERR_INVALID_SIGNATURE (err u107))

;; GLOBAL STATE VARIABLES
(define-data-var next-payment-id uint u1)
(define-data-var platform-fee-basis-points uint u100) ;; 1% platform fee
(define-data-var fee-collector principal CONTRACT_OWNER)

;; DATA STORAGE MAPS

;; Business registry and configuration
(define-map businesses
  principal
  {
    name: (string-ascii 64),
    webhook-url: (optional (string-ascii 256)),
    fee-rate: uint, ;; basis points (e.g., 250 = 2.5%)
    is-active: bool,
    total-processed: uint,
    registration-block: uint,
  }
)

;; Payment transaction records
(define-map payments
  uint
  {
    business: principal,
    customer: (optional principal),
    amount: uint,
    description: (string-ascii 256),
    reference-id: (string-ascii 64),
    status: (string-ascii 16), ;; "pending", "completed", "expired", "refunded"
    created-at: uint,
    expires-at: uint,
    processed-at: (optional uint),
    processor: (optional principal),
  }
)

;; Reference-based payment lookup
(define-map payment-references
  {
    business: principal,
    reference: (string-ascii 64),
  }
  uint
)

;; Business balance tracking
(define-map business-balances
  principal
  uint
)

;; BUSINESS MANAGEMENT FUNCTIONS

;; Register a new business entity
(define-public (register-business
    (name (string-ascii 64))
    (webhook-url (optional (string-ascii 256)))
  )
  (let ((caller tx-sender))
    (asserts! (is-none (map-get? businesses caller)) ERR_UNAUTHORIZED)
    (asserts! (> (len name) u0) ERR_INVALID_AMOUNT)
    (asserts! (<= (len name) u64) ERR_INVALID_AMOUNT)

    (map-set businesses caller {
      name: name,
      webhook-url: webhook-url,
      fee-rate: u0, ;; Default 0% business fee
      is-active: true,
      total-processed: u0,
      registration-block: stacks-block-height,
    })
    (ok true)
  )
)

;; Update existing business configuration
(define-public (update-business
    (name (string-ascii 64))
    (webhook-url (optional (string-ascii 256)))
    (fee-rate uint)
  )
  (let (
      (caller tx-sender)
      (current-business (unwrap! (map-get? businesses caller) ERR_BUSINESS_NOT_REGISTERED))
    )
    (asserts! (< fee-rate u1000) ERR_INVALID_AMOUNT)
    ;; Max 10% fee
    (asserts! (> (len name) u0) ERR_INVALID_AMOUNT)
    (asserts! (<= (len name) u64) ERR_INVALID_AMOUNT)

    (map-set businesses caller
      (merge current-business {
        name: name,
        webhook-url: webhook-url,
        fee-rate: fee-rate,
      })
    )
    (ok true)
  )
)

;; PAYMENT PROCESSING FUNCTIONS

;; Generate a new payment request
(define-public (create-payment
    (amount uint)
    (description (string-ascii 256))
    (reference-id (string-ascii 64))
    (expires-in-blocks uint)
  )
  (let (
      (caller tx-sender)
      (payment-id (var-get next-payment-id))
      (current-block stacks-block-height)
      (expiry-block (+ current-block expires-in-blocks))
    )
    ;; Input validation
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (asserts! (> expires-in-blocks u0) ERR_INVALID_AMOUNT)
    (asserts! (< expires-in-blocks u4320) ERR_INVALID_AMOUNT)
    ;; Max 30 days
    (asserts! (> (len description) u0) ERR_INVALID_AMOUNT)
    (asserts! (<= (len description) u256) ERR_INVALID_AMOUNT)
    (asserts! (> (len reference-id) u0) ERR_INVALID_AMOUNT)
    (asserts! (<= (len reference-id) u64) ERR_INVALID_AMOUNT)
    (asserts! (is-some (map-get? businesses caller)) ERR_BUSINESS_NOT_REGISTERED)
    (asserts!
      (is-none (map-get? payment-references {
        business: caller,
        reference: reference-id,
      }))
      ERR_PAYMENT_ALREADY_PROCESSED
    )

    ;; Create payment record
    (map-set payments payment-id {
      business: caller,
      customer: none,
      amount: amount,
      description: description,
      reference-id: reference-id,
      status: "pending",
      created-at: current-block,
      expires-at: expiry-block,
      processed-at: none,
      processor: none,
    })

    ;; Establish reference mapping
    (map-set payment-references {
      business: caller,
      reference: reference-id,
    }
      payment-id
    )

    ;; Increment global payment counter
    (var-set next-payment-id (+ payment-id u1))

    (ok payment-id)
  )
)