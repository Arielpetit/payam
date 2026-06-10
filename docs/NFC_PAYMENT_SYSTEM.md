# NFC Payment System Architecture

## Overview

This document describes the NFC payment system implemented in Payam, following the architecture where NFC is used for recipient identification, and actual money transfers happen securely on the backend.

## System Components

### 1. NFC Service (`lib/core/services/nfc_service.dart`)

Handles low-level NFC communication using the `nfc_manager` package.

**Key Features:**
- NFC availability checking
- NFC tag discovery and reading
- NDEF message creation and transmission
- Transaction token exchange

**Main Functions:**
```dart
Future<bool> checkNfcAvailability()
void startDiscovery({Function(NfcReceiveData) onTransactionReceived, Function(String) onError})
Future<void> sendTransaction(NfcTransactionConfig config)
void stopDiscovery()
```

### 2. Biometric Service (`lib/core/services/biometric_service.dart`)

Handles biometric authentication using the `local_auth` package.

**Key Features:**
- Biometric availability checking
- Fingerprint/Face ID authentication
- Device support detection

**Main Functions:**
```dart
Future<void> initialize()
Future<bool> authenticate({String localizedReason, bool useErrorDialogs})
String getBiometricTypeName()
```

### 3. Backend Service (`lib/core/services/backend_service.dart`)

Simulates backend transaction processing.

**Key Features:**
- Transaction initiation
- Transaction validation
- Balance checking
- Transfer execution
- One-time nonce generation for security

**Main Functions:**
```dart
Future<TransferResponse> initiateTransaction({String senderId, double amount})
Future<TransferResponse> confirmTransaction({String transactionId, String receiverId, String nonce})
```

### 4. WebSocket Service (`lib/core/services/websocket_service.dart`)

Provides real-time updates via WebSocket (currently mocked for demo).

**Key Features:**
- Connection management
- Real-time event streaming
- Transaction status updates

## Payment Flow

### Step 1: Amount Entry (Sender)
- User enters amount to send
- User can toggle biometric requirement
- User clicks "Continue"

### Step 2: Biometric Verification (Sender)
- If enabled, user authenticates with fingerprint/face
- Backend creates a temporary transaction token with 30-second expiry

### Step 3: NFC Discovery (Sender)
- Sender's phone enters NFC discovery mode
- Screen shows "Bring Phones Together"
- 30-second countdown timer starts
- Animated NFC waves displayed

### Step 4: NFC Transmission (Both Phones)
- Phones physically touch (distance < 4cm)
- Sender's phone transmits transaction ID
- Receiver's phone receives transaction ID
- **No money or credentials are transmitted via NFC**

### Step 5: Backend Validation (Receiver)
- Receiver's phone sends to backend:
  ```json
  {
    "transactionId": "txn_789",
    "receiverId": "user_B",
    "nonce": "optional_security_token"
  }
  ```
- Backend validates:
  - Transaction exists and not expired
  - Sender has sufficient balance
  - Nonce hasn't been used before

### Step 6: Transfer Execution (Backend)
- Backend performs database transaction:
  ```sql
  BEGIN;
  sender.balance -= amount;
  receiver.balance += amount;
  COMMIT;
  ```

### Step 7: Success Confirmation (Both Phones)
- WebSocket events notify both parties
- Success animations displayed
- Transaction recorded in history

## Security Features

### 1. One-Time Nonces
Each transaction uses a unique nonce that expires after 30 seconds, preventing replay attacks.

### 2. Biometric Authentication
Optional fingerprint/face verification before initiating transfer.

### 3. Distance Validation
NFC requires devices to be within 4cm, preventing accidental transfers.

### 4. Transaction Expiration
Incomplete transactions expire after 30 seconds automatically.

### 5. Backend Validation
All transfers validated server-side before execution.

## UI States

### NfcPaymentPhase Enum
```dart
enum NfcPaymentPhase {
  idle,           // Initial state
  amountEntry,    // Amount input screen
  biometric,      // Biometric verification
  discovering,   // Awaiting NFC tap
  transmitting,   // Sending NFC data
  processing,     // Backend processing
  success,        // Transfer complete
  failed,         // Error state
}
```

### Screen Animations
- **Wave Animation**: Continuous pulsing circles during discovery
- **Success Animation**: Scale transition with checkmark
- **Failure Animation**: Error icon with shake
- **Processing Animation**: Loading spinner with log display

## Implementation Files

### Core Services
- `lib/core/services/nfc_service.dart` - NFC functionality
- `lib/core/services/biometric_service.dart` - Biometric auth
- `lib/core/services/backend_service.dart` - Transaction simulation
- `lib/core/services/websocket_service.dart` - Real-time updates

### State Management
- `lib/shared/providers/nfc_payment_provider.dart` - Production-ready payment flow
- `lib/shared/providers/nfc_provider.dart` - Sandbox simulation

### UI Screens
- `lib/features/nfc/screens/nfc_payment_screen.dart` - Production UI
- `lib/features/nfc/screens/nfc_sandbox_screen.dart` - Demo/Testing UI

### Models
- `lib/shared/models/nfc_transaction_model.dart` - Transaction data model

## Testing

### Sandbox Mode
Use `/nfc-sandbox` route to access the sandbox screen which simulates the entire flow without real NFC hardware.

### Production Mode
Use `/nfc-payment` route for the production implementation with real NFC interaction.

## Dependencies

```yaml
dependencies:
  nfc_manager: ^3.5.0         # NFC hardware access
  local_auth: ^2.3.0          # Biometric authentication
  web_socket_channel: ^3.0.1  # Real-time updates
  vibration: ^2.0.0           # Haptic feedback
```

## Platform Support

- **Android**: Full NFC and biometric support
- **iOS**: Full NFC and Face ID/Touch ID support
- **Platform differences**:
  - Android can read NFC in background
  - iOS requires app to be in foreground
  - Different biometric naming (Face ID vs fingerprint)

## Future Enhancements

1. **Real Backend Integration**
   - Replace mock backend with actual API
   - Implement real WebSocket connection
   - Add authentication tokens

2. **Transaction History**
   - Show NFC transactions in transaction list
   - Export transaction history

3. **Multi-Receiver Support**
   - Send to multiple recipients
   - Batch transactions

4. **Offline Mode**
   - Queue transactions when offline
   - Sync when connection restored

5. **Enhanced Security**
   - PIN backup for biometric
   - Transaction limits
   - Fraud detection

## Architecture Diagram

```
┌─────────────┐
│ Sender Phone│
└──────┬──────┘
       │ NFC (Transaction ID Only)
       │
┌──────▼──────┐
│Receiver Phone│
└──────┬──────┘
       │ HTTPS
       │
┌──────▼──────┐
│   Backend   │
│   Server    │
└──────┬──────┘
       │
┌──────▼──────┐
│  Database   │
└─────────────┘
```

**Key Principle**: Money NEVER travels through NFC. Only a transaction identifier travels through NFC. The actual movement of money happens securely on the server.