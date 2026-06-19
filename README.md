<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.24+-02569B?style=flat-square&logo=flutter" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.5+-0175C2?style=flat-square&logo=dart" alt="Dart" />
  <img src="https://img.shields.io/badge/Platform-Android-3DDC84?style=flat-square&logo=android" alt="Android" />
  <img src="https://img.shields.io/badge/License-Proprietary-red?style=flat-square" alt="License" />
</p>

<h1 align="center">Payam</h1>

<p align="center"><strong>Send. Receive. Prosper.</strong></p>

<p align="center">
  A modern African digital wallet &amp; payment platform built with Flutter.<br/>
  Designed for Cameroon and Central Africa — FCFA currency, local providers, bilingual (EN/FR).
</p>

---

## Features

- **Authentication** — Phone number login with OTP verification, account registration, and recovery
- **Home Dashboard** — Wallet balance, quick actions, recent transactions, notification center
- **Send & Receive Money** — Contact-based transfers with QR code receiving
- **Merchant Payments** — Live QR code scanner for in-store payments
- **Top Up** — Bank transfer, MTN MoMo, and Orange Money integration
- **NFC Payments** — Peer-to-peer tap-to-pay using Android HCE (Host Card Emulation)
- **Transaction History** — Search, filter by type and date, detailed receipts
- **Wallet Management** — Balance visibility toggle, linked bank accounts, KYC status
- **KYC Verification** — Persona integration for identity verification
- **Profile & Settings** — Dark mode, language switch (EN/FR), biometric auth, PIN management
- **Notifications** — Categorized alerts (transaction, promotion, security, system)
- **Bilingual** — Full English and French localization

## Screens

| Flow | Screens |
|------|---------|
| **Auth** | Splash, Onboarding, Login, Register, OTP, Recover Account, Verification Pending |
| **Home** | Dashboard, Wallet, Transaction History, Profile |
| **Payments** | Send Money (3-step), Receive Money (QR), Merchant (QR Scanner), Top Up (3-step) |
| **NFC** | Payment (sender), Receive Mode, Receive, Success |
| **Settings** | Preferences, Security, Notifications, About |

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.24+ / Dart 3.5+ |
| State Management | Riverpod |
| Navigation | GoRouter |
| Animations | flutter_animate |
| NFC | nfc_manager + Android HCE (Kotlin) |
| QR | mobile_scanner (scan) + qr_flutter (generate) |
| Biometrics | local_auth |
| Networking | http, web_socket_channel |
| Localization | flutter_localizations + custom delegate |
| Persistence | shared_preferences |

## Project Structure

```
lib/
├── core/
│   ├── constants/          # Spacing, radius, animation durations
│   ├── localization/        # EN/FR translations & delegate
│   ├── providers/           # HCE NFC payment state machine
│   ├── router/              # GoRouter configuration
│   ├── services/            # Backend, NFC, biometric, WebSocket
│   ├── theme/               # AppColors, AppTheme (Material 3)
│   └── utils/               # Currency & date formatters
├── features/
│   ├── auth/                # Login, Register, OTP, Onboarding
│   ├── debug/               # NFC debug screen
│   ├── home/                # Dashboard
│   ├── merchant/            # QR scanner
│   ├── nfc/                 # NFC payment & receive flows
│   ├── notifications/       # Notification list
│   ├── profile/             # Profile, KYC verification
│   ├── send_money/          # 3-step send wizard
│   ├── receive_money/       # QR code display
│   ├── settings/            # Settings, About
│   ├── topup/               # 3-step top-up wizard
│   ├── transactions/        # History & detail
│   └── wallet/              # Wallet management
├── shared/
│   ├── models/              # User, Transaction, Notification, NFC
│   ├── providers/           # App-wide Riverpod providers
│   ├── repositories/        # Mock data repository
│   └── widgets/             # PayamButton, PayamTextField, etc.
└── main.dart
```

## Getting Started

### Prerequisites

- **Flutter SDK** ≥ 3.24 (Dart ≥ 3.5)
- **Android Studio** or **VS Code** with Flutter extension
- **Android device** (physical) for NFC testing — emulators do not support NFC
- **Java 17** for Android builds

### Installation

```bash
# Clone the repository
git clone https://github.com/Arielpetit/payam.git
cd payam

# Install dependencies
flutter pub get

# Generate localization files (if editing translations)
flutter gen-l10n
```

### Configuration

The backend URL is configurable via Dart compile-time variables:

```bash
# Development (default: http://localhost:3000)
flutter run

# Custom backend
flutter run --dart-define=BACKEND_URL=https://api.payam.app
```

### Running

```bash
# Debug mode
flutter run

# Release mode
flutter run --release

# Build APK
flutter build apk

# Build App Bundle (for Play Store)
flutter build appbundle
```

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `BACKEND_URL` | `http://localhost:3000` | Backend API base URL |

## Localization

The app supports **English** and **French** with ~200+ translation keys each.

- Translation files: `lib/core/localization/app_localizations.dart`
- Switch language in: Settings → Language, or on the Login screen

To add or edit translations, modify the `AppLocalizations` class and rebuild.

## Design System

- **Color basis:** Black, White, Teal (`#0F766E` → `#0D9488`)
- **Typography:** Material Design 3 with custom text styles
- **Dark mode:** Full dark palette with glass effects
- **Spacing:** Consistent scale from XS (4px) to XXL (48px)
- **Animations:** Staggered entrance animations via flutter_animate

## NFC Architecture

Payam uses Android's Host Card Emulation (HCE) for peer-to-peer NFC payments:

1. **Sender** enters amount → biometric auth → taps phone to receiver
2. **Receiver** enters receive mode → NFC reader detects sender → processes transaction
3. Both parties see a success screen with transaction details

The NFC flow is handled by a custom Kotlin service (`PayamHceService`) communicating with Flutter via `MethodChannel`.

## Current Status

> **MVP1 — Wireframe & Design Prototype**

This is the interactive wireframe phase. All data is mocked via `MockRepository`. Backend integration, real authentication, and production NFC flows are planned for MVP2.

## Contributing

This project is currently in private development. Contribution guidelines will be added when the project opens for collaboration.

## License

Proprietary — All rights reserved.