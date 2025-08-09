# BitFlow Payment Gateway

## 🚀 Overview

BitFlow Payment Gateway is an advanced decentralized payment orchestration platform that delivers institutional-grade sBTC transaction processing with dynamic fee optimization, multi-party settlement coordination, and comprehensive business intelligence. Built on the Stacks blockchain using Clarity smart contracts, BitFlow empowers businesses to scale their digital payment operations while maintaining complete financial sovereignty and operational transparency.

## ✨ Key Features

### 🏢 Business Management

- **Business Registration**: Streamlined onboarding with customizable profiles
- **Dynamic Fee Configuration**: Granular fee management across multiple tiers (up to 10%)
- **Webhook Integration**: Advanced orchestration for seamless third-party integrations
- **Real-time Analytics**: Comprehensive business intelligence dashboard

### 💳 Payment Processing

- **Invoice Generation**: Cryptographically secured transaction references
- **Instant Settlement**: Real-time sBTC transaction processing
- **Expiration Management**: Configurable payment time windows (up to 30 days)
- **Status Tracking**: Comprehensive payment lifecycle monitoring

### 💰 Financial Operations

- **Balance Management**: Isolated balance architecture for enhanced security
- **Automated Withdrawals**: Seamless business balance extraction
- **Refund Processing**: Sophisticated refund mechanisms with automated reconciliation
- **Fee Distribution**: Transparent multi-tier fee collection system

### 🔒 Security Features

- **Temporal Payment Locks**: Military-grade security through time-based validation
- **Authorization Controls**: Multi-layered access management
- **Transaction Validation**: Comprehensive input validation and error handling
- **Principal-based Security**: Role-based access control system

## 🏗️ Architecture

### Smart Contract Components

- **Business Registry**: Manages merchant registration and configuration
- **Payment Engine**: Handles invoice creation and settlement
- **Balance Manager**: Tracks business funds and enables withdrawals
- **Fee Controller**: Manages platform and business fee structures
- **Reference System**: Maps custom business references to payment IDs

### Error Handling

The contract implements comprehensive error codes for robust operation:

```clarity
ERR_UNAUTHORIZED (u100)           - Access denied
ERR_INVALID_AMOUNT (u101)         - Invalid payment amount
ERR_PAYMENT_NOT_FOUND (u102)      - Payment record not found
ERR_PAYMENT_ALREADY_PROCESSED (u103) - Duplicate processing attempt
ERR_PAYMENT_EXPIRED (u104)        - Payment window expired
ERR_INSUFFICIENT_BALANCE (u105)   - Insufficient funds
ERR_BUSINESS_NOT_REGISTERED (u106) - Unregistered business
ERR_INVALID_SIGNATURE (u107)      - Cryptographic validation failed
```

## 🛠️ Installation & Setup

### Prerequisites

- [Clarinet](https://docs.hiro.so/stacks/clarinet) v2.0+
- [Node.js](https://nodejs.org/) v18+
- [Stacks CLI](https://docs.stacks.co/stacks-101/command-line-interface)

### Quick Start

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd bitflow
   ```

2. **Install dependencies**

   ```bash
   npm install
   ```

3. **Verify contract syntax**

   ```bash
   clarinet check
   ```

4. **Run test suite**

   ```bash
   npm test
   ```

5. **Deploy to testnet**

   ```bash
   clarinet deploy --testnet
   ```

## 📖 Usage Guide

### For Businesses

#### 1. Register Your Business

```clarity
(contract-call? .bitflow register-business 
  "Your Business Name" 
  (some "https://your-webhook-url.com"))
```

#### 2. Create Payment Invoice

```clarity
(contract-call? .bitflow create-payment 
  u1000000    ;; Amount in microSTX
  "Product purchase" 
  "INV-001"   ;; Your reference ID
  u144)       ;; Expires in blocks (~24 hours)
```

#### 3. Check Payment Status

```clarity
(contract-call? .bitflow get-payment-by-reference 
  'SP1EXAMPLE... 
  "INV-001")
```

#### 4. Withdraw Earnings

```clarity
(contract-call? .bitflow withdraw-balance u500000)
```

### For Customers

#### Pay Invoice

```clarity
(contract-call? .bitflow pay-invoice u1) ;; Payment ID
```

### For Administrators

#### Set Platform Fee

```clarity
(contract-call? .bitflow set-platform-fee u250) ;; 2.5%
```

## 🧪 Testing

### Running Tests

```bash
# Run all tests
npm test

# Run tests with coverage
npm run test:report

# Watch mode for development
npm run test:watch

# Check contract validity
clarinet check
```

### Test Structure

```
tests/
├── bitflow.test.ts          # Main contract tests
├── business.test.ts         # Business management tests
├── payments.test.ts         # Payment processing tests
├── security.test.ts         # Security validation tests
└── integration.test.ts      # End-to-end integration tests
```

## 🌐 Network Configuration

### Testnet Deployment

```toml
[network.testnet]
stacks_node_rpc_address = "https://api.testnet.hiro.so"
bitcoin_node_rpc_address = "https://blockstream.info/testnet/api"
```

### Mainnet Deployment

```toml
[network.mainnet]
stacks_node_rpc_address = "https://api.mainnet.hiro.so"
bitcoin_node_rpc_address = "https://blockstream.info/api"
```

## 📊 Fee Structure

| Tier | Platform Fee | Business Fee Range |
|------|-------------|-------------------|
| Standard | 1.0% | 0% - 10% |
| Enterprise | Negotiable | Custom rates |

## 🔗 API Reference

### Public Functions

| Function | Purpose | Parameters |
|----------|---------|------------|
| `register-business` | Register new merchant | name, webhook-url |
| `create-payment` | Generate payment invoice | amount, description, reference-id, expires-in-blocks |
| `pay-invoice` | Process payment | payment-id |
| `withdraw-balance` | Extract business funds | amount |
| `refund-payment` | Process refund | payment-id |

### Read-Only Functions

| Function | Purpose | Returns |
|----------|---------|---------|
| `get-payment` | Retrieve payment details | Payment object |
| `get-business` | Get business information | Business object |
| `get-business-balance` | Check balance | uint |
| `calculate-fees` | Preview fee breakdown | Fee structure |

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Follow Clarity best practices
- Add comprehensive tests for new features
- Update documentation for API changes
- Ensure all tests pass before submitting

## 🛡️ Security Considerations

- All contract calls are validated for authorization
- Payment amounts undergo strict validation
- Time-based expiration prevents stale transactions
- Balance isolation protects business funds
- Reference mapping prevents duplicate payments

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built on [Stacks](https://www.stacks.co/) blockchain
- Powered by [Clarity](https://clarity-lang.org/) smart contracts
- Testing with [Clarinet](https://docs.hiro.so/stacks/clarinet)
