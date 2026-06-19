import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/auth/screens/recover_account_screen.dart';
import '../../features/auth/screens/verification_pending_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/wallet/screens/wallet_screen.dart';
import '../../features/send_money/screens/send_money_screen.dart';
import '../../features/receive_money/screens/receive_money_screen.dart';
import '../../features/merchant/screens/merchant_screen.dart';
import '../../features/transactions/screens/transaction_history_screen.dart';
import '../../features/transactions/screens/transaction_detail_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/kyc_verification_screen.dart';
import '../../features/topup/screens/topup_screen.dart';
import '../../shared/widgets/success/transaction_success_screen.dart';
import '../../features/nfc/screens/nfc_sandbox_screen.dart';
import '../../features/nfc/screens/nfc_payment_screen.dart';
import '../../features/nfc/screens/nfc_receive_screen.dart';
import '../../features/nfc/screens/nfc_receive_mode_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/settings/screens/about_screen.dart';
import '../../shared/models/transaction_model.dart';
import '../shell/main_shell.dart';
import '../utils/formatters.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => _buildPage(
          state,
          const SplashScreen(),
        ),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => _buildPage(
          state,
          const OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _buildPage(
          state,
          const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => _buildPage(
          state,
          const RegisterScreen(),
        ),
      ),
      GoRoute(
        path: '/otp',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final phone = extra?['phone'] as String? ?? '';
          final isRecovery = extra?['isRecovery'] as bool? ?? false;
          return _buildPage(state, OtpScreen(phone: phone, isRecovery: isRecovery));
        },
      ),
      GoRoute(
        path: '/recover-account',
        pageBuilder: (context, state) => _buildPage(
          state,
          const RecoverAccountScreen(),
        ),
      ),
      GoRoute(
        path: '/verification-pending',
        pageBuilder: (context, state) => _buildPage(
          state,
          const VerificationPendingScreen(),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => _buildPage(
              state,
              const HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/wallet',
            pageBuilder: (context, state) => _buildPage(
              state,
              const WalletScreen(),
            ),
          ),
          GoRoute(
            path: '/transactions',
            pageBuilder: (context, state) => _buildPage(
              state,
              const TransactionHistoryScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => _buildPage(
              state,
              const ProfileScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/send-money',
        pageBuilder: (context, state) => _buildPage(
          state,
          const SendMoneyScreen(),
        ),
      ),
      GoRoute(
        path: '/receive-money',
        pageBuilder: (context, state) => _buildPage(
          state,
          const ReceiveMoneyScreen(),
        ),
      ),
      GoRoute(
        path: '/merchant',
        pageBuilder: (context, state) => _buildPage(
          state,
          const MerchantScreen(),
        ),
      ),
      GoRoute(
        path: '/topup',
        pageBuilder: (context, state) => _buildPage(
          state,
          const TopupScreen(),
        ),
      ),
      GoRoute(
        path: '/kyc-verification',
        pageBuilder: (context, state) => _buildPage(
          state,
          const KycVerificationScreen(),
        ),
      ),
      GoRoute(
        path: '/transaction-detail',
        pageBuilder: (context, state) {
          final tx = state.extra as TransactionModel;
          return _buildPage(state, TransactionDetailScreen(transaction: tx));
        },
      ),
      GoRoute(
        path: '/nfc-sandbox',
        pageBuilder: (context, state) => _buildPage(state, const NfcSandboxScreen()),
      ),
      GoRoute(
        path: '/nfc-payment',
        pageBuilder: (context, state) => _buildPage(state, const NfcPaymentScreen()),
      ),
      GoRoute(
        path: '/nfc-receive/:transactionId',
        pageBuilder: (context, state) {
          final txnId = state.pathParameters['transactionId']!;
          return _buildPage(state, NfcReceiveScreen(transactionId: txnId));
        },
      ),
      GoRoute(
        path: '/nfc-receive-mode',
        pageBuilder: (context, state) => _buildPage(state, const NfcReceiveModeScreen()),
      ),
      GoRoute(
        path: '/nfc-success',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          final amountVal = extra['amount'] as double;
          final isSenderVal = extra['isSender'] as bool;
          final recipientNameVal = extra['recipientName'] as String?;
          return _buildSlideUpPage(
            state,
            TransactionSuccessScreen(
              title: isSenderVal ? 'Payment Sent!' : 'Payment Received!',
              subtitle: isSenderVal
                  ? 'Your payment has been successfully sent.'
                  : 'Payment has been successfully received.',
              amount: 'FCFA ${CurrencyFormatter.format(amountVal)}',
              icon: Icons.nfc_rounded,
              recipientName: recipientNameVal,
              isKnownContact: true,
              transactionType: isSenderVal ? TransactionType.send : TransactionType.receive,
              reference: 'PAY${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
              paymentMethod: 'NFC Tap',
              fee: '0 FCFA',
            ),
          );
        },
      ),
      GoRoute(
        path: '/notifications',
        pageBuilder: (context, state) => _buildPage(
          state,
          const NotificationsScreen(),
        ),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => _buildPage(
          state,
          const SettingsScreen(),
        ),
      ),
      GoRoute(
        path: '/about',
        pageBuilder: (context, state) => _buildPage(
          state,
          const AboutScreen(),
        ),
      ),
      GoRoute(
        path: '/transaction-success',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return _buildSlideUpPage(
            state,
            TransactionSuccessScreen(
              title: extra['title'] as String,
              subtitle: extra['subtitle'] as String,
              amount: extra['amount'] as String?,
              icon: extra['icon'] as IconData? ?? Icons.check_circle_rounded,
              recipientName: extra['recipientName'] as String?,
              recipientPhone: extra['recipientPhone'] as String?,
              recipientId: extra['recipientId'] as String?,
              isKnownContact: extra['isKnownContact'] as bool? ?? true,
              transactionType: extra['transactionType'] as TransactionType?,
              reference: extra['reference'] as String?,
              paymentMethod: extra['paymentMethod'] as String?,
              date: extra['date'] as DateTime?,
              fee: extra['fee'] as String?,
            ),
          );
        },
      ),
    ],
  );
});

CustomTransitionPage _buildPage(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

CustomTransitionPage _buildSlideUpPage(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 420),
  );
}