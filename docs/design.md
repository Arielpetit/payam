# NFC Transfer Sandbox Design

## Overview
The **NFC Transfer Sandbox** is a visual simulation that demonstrates how Payam’s NFC‑based payment handshake works. It replaces the direct NFC money‑transfer UI with a secure, backend‑driven flow.

## Layout
- **Three‑column split** horizontally centered on the screen.
  1. **Left column** – "Phone A (Sender)" mock phone UI.
  2. **Center column** – "Backend Logger" card showing JSON request/response and a progress bar.
  3. **Right column** – "Phone B (Receiver)" mock phone UI.
- Each mock phone is a rounded container (`borderRadius: 28px`) with a subtle glass‑morphism background (dark mode: `rgba(255,255,255,0.04)`, light mode: `rgba(0,0,0,0.04)`).
- A thin animated **wave line** travels from the sender to the receiver when the user taps **“Simulate NFC Tap”**.

## Color Palette
| Role | Light Mode | Dark Mode |
|------|------------|-----------|
| Primary | `#0B6E6B` (Emerald) | `#0B6E6B` |
| Surface / Card | `#F5F5F5` | `#1E1E1E` |
| Accent (Wave) | `#00C48C` | `#00C48C` |
| Text Primary | `#212121` | `#E0E0E0` |
| Text Secondary | `#757575` | `#B0B0B0` |
| Success | `#22C55E` | `#22C55E` |
| Error | `#EF4444` | `#EF4444` |

## Typography
- **Google Font:** `Inter` – loaded via `google_fonts` package.
- **Title (e.g., "NFC Transfer")** – `fontSize: 24`, `fontWeight: 700`.
- **Section headers (Phone labels)** – `fontSize: 16`, `fontWeight: 600`.
- **Body / JSON logs** – `fontSize: 12`, `fontFamily: 'Courier New', fontWeight: 400`.
- **Button label** – `fontSize: 14`, `fontWeight: 600`.

## Animations & Visual Feedback
1. **Wave propagation** – a `AnimatedContainer` with width expanding from 0 → full width over **800 ms**, color `Accent`. Uses `Curves.easeOut`.
2. **Backend logger** – fade‑in of request JSON, then a **spinner** (`CircularProgressIndicator`) for 1 s, then fade‑in of response JSON with a **green check** stamp on success or **red cross** on error.
3. **Success splash** – when the backend returns success, a confetti burst (`confetti` package) appears over both phones.
4. **Micro‑animation** – the “Simulate NFC Tap” button scales to `0.95` on press (`InkWell` with `onTapDown`).

## Interactive Elements
- **Amount input** – numeric `TextField` with `InputFormatter` to allow only digits.
- **Biometric toggle** – `SwitchListTile` labelled *“Require Biometric Auth”*.
- **Simulate NFC Tap** – primary `ElevatedButton` (`style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12))`).
- **Countdown timer** – appears after tap (30 s) showing remaining validity of the one‑time token.

## Sound Cue
- **`nfc_chime.wav`** – a short 200 ms high‑pitch chime (C5, 0 dB) played when the wave reaches the receiver. The sound file will be placed under `assets/sounds/` and declared in `pubspec.yaml`.

## Accessibility
- Contrast ratios meet WCAG AA for both themes.
- All interactive widgets have `semanticLabel` and `tooltip`.
- Focus order: Amount → Biometric toggle → Simulate NFC Tap.
- The logger card is announced as *“Backend request log, awaiting response”* when the spinner appears.

## Screens & Navigation
- **Route:** `/nfc-sandbox`
- Added to `app_router.dart` as a `GoRoute` under the main shell.
- The page widget will be `NfcSandboxScreen` placed in `lib/features/nfc/screens/`.

---
*Design created automatically based on the project’s visual language and the NFC handshake flow.*
