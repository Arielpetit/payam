# Testing NFC Payment Implementation

## Quick Start

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run the App
```bash
flutter run
```

## Testing in Sandbox Mode (No NFC Hardware Required)

### Access Sandbox Screen
1. Launch the app
2. Navigate to Home screen
3. Tap the "NFC" quick action button
4. You'll be taken to `/nfc-sandbox` route

### Sandbox Features
- **Amount Entry**: Enter amount to send
- **Biometric Toggle**: Enable/disable biometric requirement (simulated)
- **Simulate Tap**: Click "Tap To Send" to simulate the full flow
- **Backend Logs**: View simulated backend processing logs
- **Success/Failure**: View completion states with animations

### Sandbox Flow
1. Enter amount (e.g., 5000)
2. Toggle "Require Biometric" if desired
3. Click "Tap To Send"
4. Watch the simulated flow:
   - Biometric check (if enabled)
   - NFC wave animation
   - Backend processing logs
   - Success/failure screen

## Testing Production Mode (Requires NFC Hardware)

### Access Production Screen
1. Navigate to `/nfc-payment` route
2. This uses real NFC hardware

### Prerequisites
- **Android**: NFC-enabled device running Android 4.4+
- **iOS**: iPhone 7+ with iOS 13+

### Android Setup
1. Ensure NFC is enabled in Settings
2. Grant NFC permissions when prompted
3. Hold phones within 4cm of each other

### iOS Setup
1. No special setup required
2. Core NFC framework handles permissions
3. App must be in foreground for NFC reading

## Testing Scenarios

### Scenario 1: Successful Transfer
1. **Sender**:
   - Enter amount: 5000
   - Enable biometric: ON
   - Click "Continue"
   - Authenticate with biometric
   - Bring phones together
   
2. **Receiver**:
   - Phone automatically detects NFC
   - Transaction ID received
   - Backend validates
   - Money credited

3. **Result**:
   - Both phones show success animation
   - Balances updated
   - Transaction recorded

### Scenario 2: Insufficient Balance
1. Set amount higher than available balance
2. Proceed with transfer
3. **Expected**: Transfer fails with "Insufficient Balance" error

### Scenario 3: Transaction Expiry
1. Start transaction but don't tap phones
2. Wait 30 seconds
3. **Expected**: Transaction automatically cancels with expiry message

### Scenario 4: Biometric Failure
1. Enable biometric requirement
2. Cancel/fail biometric prompt
3. **Expected**: Transaction cancelled with "Authentication failed"

## Debugging

### Enable NFC Debug Logs
In `lib/core/services/nfc_service.dart`, set:
```dart
debugPrint('NFC Debug: $message');
```

### Check NFC Availability
```dart
final isAvailable = await NfcService().checkNfcAvailability();
print('NFC Available: $isAvailable');
```

### Check Biometric Support
```dart
final biometricService = BiometricService();
await biometricService.initialize();
print('Biometric: ${biometricService.getBiometricTypeName()}');
```

## Mock Data

### Default Test Users
- **Sender**: Ariel Tchikaya (usr_001) - Balance: 250,000 FCFA
- **Receiver**: Jean-Baptiste Moukala (usr_002)

### Test Contacts
Available in mock repository for simulation purposes.

## Known Limitations

1. **Sandbox Mode**:
   - No actual NFC hardware used
   - Biometric is simulated (always passes)
   - Backend operations are mocked
   - No real money transfer

2. **Production Mode**:
   - Requires two physical NFC-enabled devices
   - Real backend integration needed for actual transfers
   - WebSocket needs real server connection

## Troubleshooting

### "NFC Not Available"
- Check device NFC settings
- Verify device has NFC hardware
- On Android, check manifest permissions

### "Biometric Not Available"
- Check device biometric settings
- Enroll fingerprint/face in device settings
- Verify device has biometric hardware

### "Transfer Failed"
- Check sender balance
- Verify transaction hasn't expired
- Check network connectivity
- Review backend logs in processing screen

### App Crashes on NFC Screen
- Check all required permissions granted
- Verify NFC/Biometric services initialized
- Check device compatibility

## Performance Tips

1. **Sandbox Mode**: Instant, no network calls
2. **Production Mode**: 
   - Initial connection: ~500ms
   - NFC tap: ~200ms
   - Backend validation: ~300-600ms
   - Total flow: ~1-2 seconds

## Security Notes

### During Testing
- All transactions are simulated
- No real money involved
- No sensitive data transmitted
- Nonces are generated but not validated server-side

### For Production Deployment
- Implement real backend API
- Add authentication tokens
- Use HTTPS only
- Implement proper nonce validation
- Add rate limiting
- Implement transaction logging

## Next Steps

1. **Backend Integration**: Replace mock backend with real API
2. **WebSocket Connection**: Connect to real WebSocket server
3. **Error Handling**: Add comprehensive error states
4. **Analytics**: Track transaction metrics
5. **Testing**: Add unit tests for all services

## File Structure Reference
```
lib/
├── core/
│   └── services/
│       ├── nfc_service.dart           # NFC hardware interaction
│       ├── biometric_service.dart     # Biometric auth
│       ├── backend_service.dart       # Transaction processing
│       └── websocket_service.dart     # Real-time updates
├── features/
│   └── nfc/
│       └── screens/
│           ├── nfc_sandbox_screen.dart    # Demo/test mode
│           └── nfc_payment_screen.dart    # Production mode
└── shared/
    ├── providers/
    │   ├── nfc_provider.dart            # Sandbox state
    │   └── nfc_payment_provider.dart    # Production state
    └── models/
        └── nfc_transaction_model.dart   # Transaction data
```