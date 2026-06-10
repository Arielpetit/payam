import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/hce_payment_provider.dart';
import '../../../shared/widgets/payam_button.dart';

class NfcReceiveModeScreen extends ConsumerStatefulWidget {
const NfcReceiveModeScreen({super.key});

@override
ConsumerState<NfcReceiveModeScreen> createState() => _NfcReceiveModeScreenState();
}

class _NfcReceiveModeScreenState extends ConsumerState<NfcReceiveModeScreen>
with TickerProviderStateMixin {
late AnimationController _waveController;
late AnimationController _successController;
late AnimationController _pulseController;

@override
void initState() {
super.initState();
_waveController = AnimationController(
vsync: this,
duration: const Duration(milliseconds: 2000),
);
_successController = AnimationController(
vsync: this,
duration: const Duration(milliseconds: 800),
);
_pulseController = AnimationController(
vsync: this,
duration: const Duration(milliseconds: 1000),
)..repeat(reverse: true);

WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(hcePaymentProvider.notifier).recheckNfc();
      // Background receive is auto-started when app launches
      // Just ensure it's active
      ref.read(hcePaymentProvider.notifier).ensureBackgroundReceiveActive();
    });
}

@override
void dispose() {
_waveController.dispose();
_successController.dispose();
_pulseController.dispose();
ref.read(hcePaymentProvider.notifier).reset();
super.dispose();
}

@override
Widget build(BuildContext context) {
final state = ref.watch(hcePaymentProvider);
final isDark = Theme.of(context).brightness == Brightness.dark;

ref.listen<NfcPaymentState>(hcePaymentProvider, (_, next) {
if (next.phase == NfcPaymentPhase.waitingForTap) {
_waveController.repeat();
} else if (next.phase == NfcPaymentPhase.success) {
_waveController.stop();
_successController.forward();
} else {
_waveController.stop();
}
});

return Scaffold(
backgroundColor: isDark ? Colors.black : AppColors.background,
appBar: AppBar(
title: const Text('Receive Money'),
backgroundColor: isDark ? Colors.black : AppColors.background,
elevation: 0,
actions: [
if (state.phase == NfcPaymentPhase.waitingForTap)
IconButton(
icon: const Icon(Icons.close_rounded),
onPressed: () {
ref.read(hcePaymentProvider.notifier).reset();
context.pop();
},
),
],
),
body: _buildBody(state, isDark),
);
}

Widget _buildBody(NfcPaymentState state, bool isDark) {
switch (state.phase) {
case NfcPaymentPhase.idle:
case NfcPaymentPhase.amountEntry:
return _buildWaiting(isDark);
case NfcPaymentPhase.waitingForTap:
return _buildWaitingForTap(state, isDark);
case NfcPaymentPhase.processing:
return _buildProcessing(isDark);
case NfcPaymentPhase.success:
return _buildSuccess(state, isDark);
case NfcPaymentPhase.biometric:
case NfcPaymentPhase.failed:
return _buildFailed(state, isDark);
}
}

// ─── Initial Waiting (Reader Mode)─────────────────────────────────────────

Widget _buildWaiting(bool isDark) {
return Center(
child: Padding(
padding: const EdgeInsets.all(32),
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
Container(
width: 110,
height: 110,
decoration: BoxDecoration(
color: AppColors.primary.withOpacity(0.1),
shape: BoxShape.circle,
),
child: const Icon(Icons.nfc_rounded, size: 52, color: AppColors.primary),
),
const SizedBox(height: 24),
Text(
'Starting Reader Mode...',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w600,
color: isDark ? Colors.white : AppColors.textPrimary,
),
),
],
),
),
);
}

// ─── Waiting For Sender's Card──────────────────────────────────────────────

Widget _buildWaitingForTap(NfcPaymentState state, bool isDark) {
return Center(
child: Padding(
padding: const EdgeInsets.all(32),
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
Stack(
alignment: Alignment.center,
children: [
for (int i = 0; i < 3; i++)
AnimatedBuilder(
animation: _waveController,
builder: (_, __) => Container(
width: 140 + (_waveController.value * 70),
height: 140 + (_waveController.value * 70),
decoration: BoxDecoration(
shape: BoxShape.circle,
border: Border.all(
color: AppColors.success
.withOpacity((1 - _waveController.value) * 0.5),
width: 2,
),
),
),
),
Container(
width: 110,
height: 110,
decoration: BoxDecoration(
color: AppColors.success,
shape: BoxShape.circle,
boxShadow: [
BoxShadow(
color: AppColors.success.withOpacity(0.35),
blurRadius: 20,
spreadRadius: 6,
),
],
),
child: const Icon(Icons.contactless_rounded, size: 52, color: Colors.white),
),
],
),

const SizedBox(height: 36),

Text(
'Ready to Receive',
style: TextStyle(
fontSize: 22,
fontWeight: FontWeight.bold,
color: isDark ? Colors.white : AppColors.textPrimary,
),
),
const SizedBox(height: 8),
Text(
'Bring sender\'s phone close (< 4cm)',
style: TextStyle(
fontSize: 14,
color: isDark ? Colors.white60 : AppColors.textSecondary,
),
),

const SizedBox(height: 20),

Container(
padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
decoration: BoxDecoration(
color: state.countdown <= 15
? AppColors.error.withOpacity(0.1)
: AppColors.info.withOpacity(0.1),
borderRadius: BorderRadius.circular(20),
),
child: Row(
mainAxisSize: MainAxisSize.min,
children: [
Icon(
Icons.timer_rounded,
size: 14,
color: state.countdown <= 15
? AppColors.error
: AppColors.info,
),
const SizedBox(width: 4),
Text(
'${state.countdown}s remaining',
style: TextStyle(
fontSize: 14,
fontWeight: FontWeight.w600,
color: state.countdown <= 15
? AppColors.error
: AppColors.info,
),
),
],
),
),

const SizedBox(height: 24),

Container(
padding: const EdgeInsets.all(14),
decoration: BoxDecoration(
color: AppColors.info.withOpacity(0.08),
borderRadius: BorderRadius.circular(12),
border: Border.all(color: AppColors.info.withOpacity(0.2)),
),
child: Column(
children: [
Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(Icons.info_outline_rounded, size: 16, color: AppColors.info),
const SizedBox(width: 8),
Text(
'Reader Mode Active',
style: TextStyle(
fontSize: 12,
fontWeight: FontWeight.w600,
color: AppColors.info,
),
),
],
),
const SizedBox(height: 6),
Text(
'Your phone is acting as an NFC reader.\nWait for sender to tap their phone.',
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 12,
color: isDark ? Colors.white60 : AppColors.textSecondary,
height: 1.5,
),
),
],
),
).animate().fadeIn(delay: 200.ms),
],
),
),
);
}

// ─── Processing────────────────────────────────────────

Widget _buildProcessing(bool isDark) {
return Center(
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
Container(
width: 80,
height: 80,
decoration: BoxDecoration(
color: AppColors.primary.withOpacity(0.1),
shape: BoxShape.circle,
),
child: const CircularProgressIndicator(
strokeWidth: 3,
color: AppColors.primary,
),
).animate().fadeIn(),
const SizedBox(height: 20),
Text(
'Processing Payment...',
style: TextStyle(
fontSize: 16,
color: isDark ? Colors.white70 : AppColors.textSecondary,
),
),
],
),
);
}

// ─── Success────────────────────────────────────────────────────────────────

Widget _buildSuccess(NfcPaymentState state, bool isDark) {
return Center(
child: Padding(
padding: const EdgeInsets.symmetric(horizontal: 24),
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
ScaleTransition(
scale: Tween<double>(begin: 0, end: 1).animate(
CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
),
child: Container(
width: 110,
height: 110,
decoration: BoxDecoration(
color: AppColors.success.withOpacity(0.15),
shape: BoxShape.circle,
),
child: const Icon(Icons.check_rounded, size: 60, color: AppColors.success),
),
),
const SizedBox(height: 28),
Text(
'Money Received!',
style: TextStyle(
fontSize: 24,
fontWeight: FontWeight.bold,
color: isDark ? Colors.white : AppColors.textPrimary,
),
).animate().fadeIn(delay: 200.ms),
const SizedBox(height: 12),
Container(
padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
decoration: BoxDecoration(
color: isDark ? const Color(0xFF121212) : AppColors.surface,
borderRadius: BorderRadius.circular(16),
border: isDark ? Border.all(color: const Color(0xFF1E1E1E)) : null,
boxShadow: isDark ? null : AppColors.cardShadow,
),
child: Column(
children: [
Text(
'+${state.amount.toStringAsFixed(0)} FCFA',
style: const TextStyle(
fontSize: 32,
fontWeight: FontWeight.w800,
color: AppColors.success,
),
),
if (state.recipientName != null) ...[
const SizedBox(height: 4),
Text(
'From ${state.recipientName}',
style: TextStyle(
fontSize: 14,
color: isDark ? Colors.white60 : AppColors.textSecondary,
),
),
],
],
),
).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
const SizedBox(height: 32),
PayamButton(
label: 'Done',
icon: Icons.check_rounded,
onPressed: () {
ref.read(hcePaymentProvider.notifier).reset();
context.go('/home');
},
).animate().fadeIn(delay: 400.ms),
],
),
),
);
}

// ─── Failed───────────────────────────────────────────────────────────────

Widget _buildFailed(NfcPaymentState state, bool isDark) {
return Center(
child: Padding(
padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
Container(
width: 100,
height: 100,
decoration: BoxDecoration(
color: AppColors.error.withOpacity(0.12),
shape: BoxShape.circle,
),
child: const Icon(Icons.close_rounded, size: 52, color: AppColors.error),
).animate().scale(curve: Curves.easeOutBack),
const SizedBox(height: 24),
Text(
state.isSender ? 'Transfer Failed' : 'Receive Failed',
style: TextStyle(
fontSize: 22,
fontWeight: FontWeight.bold,
color: isDark ? Colors.white : AppColors.textPrimary,
),
),
const SizedBox(height: 12),
Container(
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: isDark ? const Color(0xFF121212) : AppColors.surface,
borderRadius: BorderRadius.circular(14),
border: Border.all(color: AppColors.error.withOpacity(0.25)),
),
child: Column(
children: [
Text(
state.errorMessage ?? 'An error occurred',
style: TextStyle(
fontSize: 14,
color: isDark ? Colors.white : AppColors.textPrimary,
),
textAlign: TextAlign.center,
),
if (state.errorCode != null) ...[
const SizedBox(height: 6),
Text(
state.errorCode!,
style: TextStyle(
fontSize: 11,
fontFamily: 'monospace',
color: isDark ? Colors.white38 : AppColors.textHint,
),
),
],
],
),
).animate().fadeIn(delay: 150.ms),
const SizedBox(height: 28),
Row(
children: [
Expanded(
child: PayamButton(
label: 'Cancel',
isOutlined: true,
onPressed: () {
ref.read(hcePaymentProvider.notifier).reset();
context.pop();
},
),
),
const SizedBox(width: 12),
Expanded(
child: PayamButton(
label: 'Try Again',
icon: Icons.refresh_rounded,
onPressed: () {
ref.read(hcePaymentProvider.notifier).reset();
// Background receive auto-starts when app launches
},
),
),
],
).animate().fadeIn(delay: 300.ms),
],
),
),
);
}
}