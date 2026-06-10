import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // General
      'app_name': 'Payam',
      'continue': 'Continue',
      'get_started': 'Get Started',
      'back': 'Back',
      'success': 'Success',
      'failed': 'Failed',
      'pending': 'Pending',
      'none': 'None',
      'done': 'Done',
      
      // Onboarding
      'onboarding_title_1': 'Send Money\nInstantly',
      'onboarding_subtitle_1': 'Transfer funds to anyone in Cameroon in seconds. Fast, easy, and secure.',
      'onboarding_title_2': 'Bank-Grade\nSecurity',
      'onboarding_subtitle_2': 'Your money is protected with 256-bit encryption and biometric authentication.',
      'onboarding_title_3': 'Grow Your\nWealth',
      'onboarding_subtitle_3': 'Earn cashback on every transaction. Save, invest, and prosper with Payam.',
      'already_have_account': 'Already have an account? Sign in',
      
      // Auth
      'welcome_back': 'Welcome Back',
      'login_subtitle': 'Sign in to access your secure wallet',
      'register_title': 'Create Account',
      'register_subtitle': 'Join Payam and start transacting today',
      'full_name': 'Full Name',
      'full_name_hint': 'Enter your full name',
      'personal_information': 'Personal Information',
      'email': 'Email Address',
      'email_hint': 'Enter your email address',
      'phone_number': 'Phone Number',
      'password': 'Password',
      'confirm_password': 'Confirm Password',
      'password_hint': '••••••••',
      'forgot_password': 'Forgot Password?',
      'sign_in': 'Sign In',
      'sign_up': 'Sign Up',
      'dont_have_account': 'Don\'t have an account? Sign up',
      'biometrics_prompt': 'Authenticate to sign in',
      'otp_title': 'Verification',
      'otp_subtitle': 'Enter the 6-digit code sent to',
      'otp_resend': 'Resend code',
      'otp_resend_in': 'Resend in',
      'otp_verify': 'Verify & Proceed',
      'invalid_pin': 'Invalid PIN code',
      
      // Home
      'good_morning': 'Good morning,',
      'total_balance': 'Total Balance',
      'hide': 'Hide',
      'show': 'Show',
      'quick_actions': 'Quick Actions',
      'action_send': 'Send',
      'action_receive': 'Receive',
      'action_pay': 'Pay',
      'action_airtime': 'Airtime',
      'action_data': 'Data',
      'action_bills': 'Bills',
      'recent_transactions': 'Recent Transactions',
      'see_all': 'See all',
      'promo_title': '🎁 Special Offer',
      'promo_body': 'Invite Friends,\nEarn FCFA 5,000!',
      'promo_button': 'Invite Now',
      'invite_success': 'Referral link copied to clipboard',
      
      // Wallet
      'my_wallet': 'My Wallet',
      'top_up': 'Top Up',
      'withdraw': 'Withdraw',
      'linked_banks': 'Linked Banks',
      'add_bank': 'Add Bank',
      'recent_activity': 'Recent Activity',
      'view_all': 'View All',
      'card_frozen': 'Card Frozen',
      'card_active': 'Card Active',
      'freeze_card': 'Freeze Card',
      'unfreeze_card': 'Unfreeze Card',
      'card_limits': 'Transaction Limits',
      'daily_limit': 'Daily Limit',
      
      // Send Money
      'send_money': 'Send Money',
      'to_who': 'To who?',
      'to_who_hint': 'Name, phone or account number',
      'recent_contacts': 'Recent Contacts',
      'sending_to': 'Sending to',
      'amount': 'Amount',
      'add_note': 'Add a note (optional)',
      'add_note_hint': 'e.g. Dinner share',
      'ready_to_send': 'Ready to send',
      'fee': 'Fee',
      'send_now': 'Send Now',
      'transaction_success': 'Money sent successfully!',
      
      // Receive Money
      'receive_money': 'Receive Money',
      'scan_to_pay': 'Scan to pay me',
      'share_qr': 'Share QR Code',
      'copy_link': 'Copy Payment Link',
      'link_copied': 'Link copied to clipboard',
      
      // Merchant / QR
      'pay_merchant': 'Pay Merchant',
      'scan_frame': 'Align QR code within frame\nto scan automatically',
      'upload': 'Upload',
      'enter_code': 'Enter Code',
      'flashlight': 'Flashlight',
      'enter_merchant_id': 'Enter Merchant ID',
      'enter_merchant_hint': 'e.g. MTN-123 or SNE-456',
      'merchant_details': 'Merchant Details',
      'merchant_name': 'Merchant Name',
      'confirm_and_pay': 'Confirm & Pay',
      'payment_success': 'Payment successful!',
      
      // Notifications
      'notifications': 'Notifications',
      'mark_all_read': 'All marked as read',
      'no_notifications': 'No new notifications',
      
      // Settings
      'settings': 'Settings',
      'preferences': 'Preferences',
      'dark_mode': 'Dark Mode / B&W',
      'language': 'Language',
      'security': 'Security',
      'change_pin': 'Change PIN',
      'biometric_auth': 'Biometric Authentication',
      'push_notifications': 'Push Notifications',
      'email_notifications': 'Email Notifications',
      'about': 'About',
      'terms_of_service': 'Terms of Service',
      'privacy_policy': 'Privacy Policy',
      'app_version': 'App Version',
      'log_out': 'Log Out',
      'current_pin': 'Current PIN',
      'new_pin': 'New PIN',
      'confirm_new_pin': 'Confirm New PIN',
      'pin_changed_success': 'PIN updated successfully!',
      'pin_mismatch': 'PINs do not match',
      
      // Actions/Details
      'tx_details': 'Transaction Details',
      'status': 'Status',
      'date_time': 'Date & Time',
      'reference': 'Reference',
      'recipient': 'Recipient',
      'note': 'Note',
      'download_receipt': 'Download Receipt',
      'receipt_downloaded': 'Receipt downloaded successfully',
      'report_issue': 'Report an Issue',
      
      // Airtime/Data/Bills Form
      'select_operator': 'Select Operator',
      'select_package': 'Select Package',
      'biller_electricity': 'SNE (Electricity)',
      'biller_water': 'SNDE (Water)',
      'biller_tv': 'Canal+ / DSTV',
      'account_number': 'Account Number',
      'verify_account': 'Verify Account',
      'account_verified': 'Account Verified',
      'purchase_success': 'Purchase successful!',

      // Extra keys for rewritten screens
      'send_success_msg': 'Money sent successfully!',
      'recipient_hint': 'Name, phone or account number',
      'scan_to_pay_me': 'Scan to pay me',
      'copied_link_msg': 'Payment link copied to clipboard',
      'align_qr_instruction': 'Align QR code within frame\nto scan automatically',
      'insufficient_balance': 'Insufficient balance',
      'biometrics': 'Biometric Authentication',
      'balance_growth': '+12.5% this month',
      'fcfa_wallet': 'FCFA Wallet',
      'special_offer': '🎁 Special Offer',
      'invite_promo': 'Invite Friends,\nEarn FCFA 5,000!',
      'invite_now': 'Invite Now',
      'send': 'Send',
      'receive': 'Receive',
      // NFC Sandbox
      'nfc_transfer': 'NFC Transfer',
      'nfc_desc': 'Secure contactless transfer',
      'nfc_tap_to_send': 'Tap to Send',
      'nfc_bring_together': 'Bring phones together',
      'nfc_sandbox': 'NFC Sandbox Simulator',
      'nfc_sender_title': 'Sender Phone (Ariel)',
      'nfc_receiver_title': 'Receiver Phone (Jean-Baptiste)',
      'nfc_simulate_tap': 'Simulate NFC Tap',
      'nfc_backend_log': 'Secure Server Logs',
      'nfc_sent_success': '5000 FCFA Sent!',
      'nfc_received_success': '+5000 FCFA',
      'nfc_biometrics_title': 'Confirm Identity',
      'nfc_biometrics_sub': 'Use biometric validation before sending',
      'pay': 'Pay',
      'airtime': 'Airtime',
      'data': 'Data',
      'bills': 'Bills',
      'add_note_optional': 'Add a note (optional)',
      'to': 'To',
      'phone': 'Phone',
      'cancel': 'Cancel',
      'transaction_history': 'Transaction History',
      'all': 'All',
      'sent': 'Sent',
      'received': 'Received',
      'payments': 'Payments',
      'search_transactions': 'Search transactions...',
      'no_transactions_found': 'No transactions found',
      'transaction_details': 'Transaction Details',
      'receipt_download_msg': 'Receipt downloaded successfully',
    },
    'fr': {
      // General
      'app_name': 'Payam',
      'continue': 'Continuer',
      'get_started': 'Commencer',
      'back': 'Retour',
      'success': 'Succès',
      'failed': 'Échoué',
      'pending': 'En attente',
      'none': 'Aucun',
      'done': 'Terminé',
      
      // Onboarding
      'onboarding_title_1': 'Envoyez de l\'Argent\nInstantanément',
      'onboarding_subtitle_1': 'Transférez des fonds à n\'importe qui au Cameroun en quelques secondes. Rapide, facile et sécurisé.',
      'onboarding_title_2': 'Sécurité de\nNiveau Bancaire',
      'onboarding_subtitle_2': 'Votre argent est protégé par un cryptage 256 bits et une authentification biométrique.',
      'onboarding_title_3': 'Faites Grandir\nVotre Fortune',
      'onboarding_subtitle_3': 'Gagnez du cashback sur chaque transaction. Épargnez, investissez et prospérez avec Payam.',
      'already_have_account': 'Vous avez déjà un compte? Se connecter',
      
      // Auth
      'welcome_back': 'Bon retour',
      'login_subtitle': 'Connectez-vous pour accéder à votre portefeuille sécurisé',
      'register_title': 'Créer un compte',
      'register_subtitle': 'Rejoignez Payam et commencez vos transactions dès aujourd\'hui',
      'full_name': 'Nom complet',
      'full_name_hint': 'Entrez votre nom complet',
      'personal_information': 'Informations Personnelles',
      'email': 'Adresse e-mail',
      'email_hint': 'Entrez votre adresse e-mail',
      'phone_number': 'Numéro de téléphone',
      'password': 'Mot de passe',
      'confirm_password': 'Confirmer le mot de passe',
      'password_hint': '••••••••',
      'forgot_password': 'Mot de passe oublié ?',
      'sign_in': 'Se Connecter',
      'sign_up': 'S\'inscrire',
      'dont_have_account': 'Vous n\'avez pas de compte ? S\'inscrire',
      'biometrics_prompt': 'Authentifiez-vous pour vous connecter',
      'otp_title': 'Vérification',
      'otp_subtitle': 'Entrez le code à 6 chiffres envoyé au',
      'otp_resend': 'Renvoyer le code',
      'otp_resend_in': 'Renvoyer dans',
      'otp_verify': 'Vérifier & Continuer',
      'invalid_pin': 'Code PIN invalide',
      
      // Home
      'good_morning': 'Bonjour,',
      'total_balance': 'Solde Total',
      'hide': 'Masquer',
      'show': 'Afficher',
      'quick_actions': 'Actions Rapides',
      'action_send': 'Envoyer',
      'action_receive': 'Recevoir',
      'action_pay': 'Payer',
      'action_airtime': 'Crédit',
      'action_data': 'Internet',
      'action_bills': 'Factures',
      'recent_transactions': 'Transactions Récentes',
      'see_all': 'Voir tout',
      'promo_title': '🎁 Offre Spéciale',
      'promo_body': 'Invitez des amis,\nGagnez 5 000 FCFA !',
      'promo_button': 'Inviter maintenant',
      'invite_success': 'Lien de parrainage copié dans le presse-papiers',
      
      // Wallet
      'my_wallet': 'Mon Portefeuille',
      'top_up': 'Recharger',
      'withdraw': 'Retirer',
      'linked_banks': 'Banques Liées',
      'add_bank': 'Ajouter',
      'recent_activity': 'Activité Récente',
      'view_all': 'Voir Tout',
      'card_frozen': 'Carte Gelée',
      'card_active': 'Carte Active',
      'freeze_card': 'Geler la carte',
      'unfreeze_card': 'Dégeler la carte',
      'card_limits': 'Limites de Transaction',
      'daily_limit': 'Limite journalière',
      
      // Send Money
      'send_money': 'Envoyer de l\'Argent',
      'to_who': 'À qui ?',
      'to_who_hint': 'Nom, téléphone ou numéro de compte',
      'recent_contacts': 'Contacts Récents',
      'sending_to': 'Envoi à',
      'amount': 'Montant',
      'add_note': 'Ajouter une note (optionnel)',
      'add_note_hint': 'ex. Partage de dîner',
      'ready_to_send': 'Prêt à envoyer',
      'fee': 'Frais',
      'send_now': 'Envoyer Maintenant',
      'transaction_success': 'Argent envoyé avec succès !',
      
      // Receive Money
      'receive_money': 'Recevoir de l\'Argent',
      'scan_to_pay': 'Scannez pour me payer',
      'share_qr': 'Partager le QR Code',
      'copy_link': 'Copier le lien de paiement',
      'link_copied': 'Lien copié dans le presse-papiers',
      
      // Merchant / QR
      'pay_merchant': 'Payer un Marchand',
      'scan_frame': 'Alignez le code QR dans le cadre\npour scanner automatiquement',
      'upload': 'Importer',
      'enter_code': 'Saisir Code',
      'flashlight': 'Lampe',
      'enter_merchant_id': 'Saisir l\'identifiant du marchand',
      'enter_merchant_hint': 'ex. MTN-123 ou SNE-456',
      'merchant_details': 'Détails du Marchand',
      'merchant_name': 'Nom du Marchand',
      'confirm_and_pay': 'Confirmer & Payer',
      'payment_success': 'Paiement réussi !',
      
      // Notifications
      'notifications': 'Notifications',
      'mark_all_read': 'Tous marqués comme lus',
      'no_notifications': 'Aucune nouvelle notification',
      
      // Settings
      'settings': 'Paramètres',
      'preferences': 'Préférences',
      'dark_mode': 'Mode Sombre / N&B',
      'language': 'Langue',
      'security': 'Sécurité',
      'change_pin': 'Changer le Code PIN',
      'biometric_auth': 'Authentification Biométrique',
      'push_notifications': 'Notifications Push',
      'email_notifications': 'Notifications E-mail',
      'about': 'À propos',
      'terms_of_service': 'Conditions d\'utilisation',
      'privacy_policy': 'Politique de confidentialité',
      'app_version': 'Version de l\'application',
      'log_out': 'Se Déconnecter',
      'current_pin': 'PIN Actuel',
      'new_pin': 'Nouveau PIN',
      'confirm_new_pin': 'Confirmer le nouveau PIN',
      'pin_changed_success': 'PIN mis à jour avec succès !',
      'pin_mismatch': 'Les codes PIN ne correspondent pas',
      
      // Actions/Details
      'tx_details': 'Détails de la Transaction',
      'status': 'Statut',
      'date_time': 'Date & Heure',
      'reference': 'Référence',
      'recipient': 'Destinataire',
      'note': 'Note',
      'download_receipt': 'Télécharger le Reçu',
      'receipt_downloaded': 'Reçu téléchargé avec succès',
      'report_issue': 'Signaler un Problème',
      
      // Airtime/Data/Bills Form
      'select_operator': 'Sélectionner l\'opérateur',
      'select_package': 'Sélectionner le forfait',
      'biller_electricity': 'SNE (Électricité)',
      'biller_water': 'SNDE (Eau)',
      'biller_tv': 'Canal+ / DSTV',
      'account_number': 'Numéro de compte',
      'verify_account': 'Vérifier le compte',
      'account_verified': 'Compte vérifié',
      'purchase_success': 'Achat réussi !',

      // Extra keys for rewritten screens
      'send_success_msg': 'Argent envoyé avec succès !',
      'recipient_hint': 'Nom, téléphone ou numéro de compte',
      'scan_to_pay_me': 'Scannez pour me payer',
      'copied_link_msg': 'Lien de paiement copié dans le presse-papiers',
      'align_qr_instruction': 'Alignez le code QR dans le cadre\npour scanner automatiquement',
      'insufficient_balance': 'Solde insuffisant',
      'biometrics': 'Authentification Biométrique',
      'balance_growth': '+12,5% ce mois-ci',
      'fcfa_wallet': 'Portefeuille FCFA',
      'special_offer': '🎁 Offre Spéciale',
      'invite_promo': 'Invitez des amis,\nGagnez 5 000 FCFA !',
      'invite_now': 'Inviter maintenant',
      'send': 'Envoyer',
      'receive': 'Recevoir',
      // NFC Sandbox (French)
      'nfc_transfer': 'Transfert NFC',
      'nfc_desc': 'Transfert sans contact sécurisé',
      'nfc_tap_to_send': 'Appuyez pour envoyer',
      'nfc_bring_together': 'Approchez les téléphones',
      'nfc_sandbox': 'Simulateur Sandbox NFC',
      'nfc_sender_title': 'Téléphone Expéditeur (Ariel)',
      'nfc_receiver_title': 'Téléphone Destinataire (Jean-Baptiste)',
      'nfc_simulate_tap': 'Simuler le contact NFC',
      'nfc_backend_log': 'Journaux du serveur sécurisé',
      'nfc_sent_success': '5000 FCFA Envoyés !',
      'nfc_received_success': '+5000 FCFA',
      'nfc_biometrics_title': 'Confirmer l\'identité',
      'nfc_biometrics_sub': 'Utiliser la validation biométrique',
      'pay': 'Payer',
      'airtime': 'Crédit',
      'data': 'Internet',
      'bills': 'Factures',
      'add_note_optional': 'Ajouter une note (optionnel)',
      'to': 'À',
      'phone': 'Téléphone',
      'cancel': 'Annuler',
      'transaction_history': 'Historique des Transactions',
      'all': 'Tout',
      'sent': 'Envoyé',
      'received': 'Reçu',
      'payments': 'Paiements',
      'search_transactions': 'Rechercher des transactions...',
      'no_transactions_found': 'Aucune transaction trouvée',
      'transaction_details': 'Détails de la Transaction',
      'receipt_download_msg': 'Reçu téléchargé avec succès',
    }
  };

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ?? AppLocalizations(const Locale('en'));
  }

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? _localizedValues['en']?[key] ?? key;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  final Locale activeLocale;
  const AppLocalizationsDelegate(this.activeLocale);

  @override
  bool isSupported(Locale locale) => ['en', 'fr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return Future.value(AppLocalizations(activeLocale));
  }

  @override
  bool shouldReload(covariant AppLocalizationsDelegate old) => old.activeLocale != activeLocale;
}

extension LocalizationExtension on BuildContext {
  String loc(String key) {
    return AppLocalizations.of(this).translate(key);
  }
}
