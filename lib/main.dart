import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/localization/app_localizations.dart';
import 'core/providers/hce_payment_provider.dart';
import 'core/services/nfc_method_channel.dart';
import 'shared/providers/app_providers.dart';
import 'shared/widgets/background_payment_listener.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize centralized NFC handler
  nfcMethodChannel.initialize();

  runApp(const ProviderScope(child: PayamApp()));
}

class PayamApp extends ConsumerStatefulWidget {
  const PayamApp({super.key});

  @override
  ConsumerState<PayamApp> createState() => _PayamAppState();
}

class _PayamAppState extends ConsumerState<PayamApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initNfc();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Restart background receive if enabled
      _startBackgroundReceiveIfEnabled();
    }
  }

  Future<void> _initNfc() async {
    // Load persisted auto-receive setting first
    await ref.read(autoReceiveNfcProvider.notifier).init();

    // Set up NFC intent handler (for when app is launched via NFC)
    nfcMethodChannel.onNfcIntent = (transactionId) {
      _handleNfcIntent(transactionId);
    };

    // Wait for provider state to propagate before checking autoReceive
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startBackgroundReceiveIfEnabled();
    });
  }

  void _startBackgroundReceiveIfEnabled() {
    final autoReceive = ref.read(autoReceiveNfcProvider);
    if (autoReceive) {
      final paymentState = ref.read(hcePaymentProvider);
      if (!paymentState.isBackgroundReceiving && 
          paymentState.phase == NfcPaymentPhase.idle) {
        ref.read(hcePaymentProvider.notifier).startBackgroundReceive();
      }
    }
  }

  void _handleNfcIntent(String transactionId) {
    final router = ref.read(routerProvider);
    router.push('/nfc-receive/$transactionId');
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return BackgroundPaymentListener(
      child: MaterialApp.router(
        title: 'Payam',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        locale: locale,
        localizationsDelegates: [
          AppLocalizationsDelegate(locale),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
          Locale('fr', ''),
        ],
        routerConfig: router,
      ),
    );
  }
}

/// Helper: extract transactionId from raw NDEF payload bytes.
String? extractTransactionIdFromNdef(Uint8List payload) {
  try {
    final json = jsonDecode(utf8.decode(payload)) as Map<String, dynamic>;
    return json['transactionId'] as String?;
  } catch (_) {
    return null;
  }
}