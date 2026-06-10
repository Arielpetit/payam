import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static String format(double amount, {String symbol = 'FCFA'}) {
    final formatter = NumberFormat('#,##0', 'fr_FR');
    return '$symbol ${formatter.format(amount)}';
  }

  static String formatCompact(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M FCFA';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K FCFA';
    }
    return format(amount);
  }
}

class DateFormatter {
  DateFormatter._();

  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy • HH:mm').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  static String formatRelative(DateTime date, {String languageCode = 'en'}) {
    final now = DateTime.now();
    final diff = now.difference(date);
    final isFr = languageCode == 'fr';
    if (diff.inDays == 0) return isFr ? "Aujourd'hui" : 'Today';
    if (diff.inDays == 1) return isFr ? 'Hier' : 'Yesterday';
    if (diff.inDays < 7) {
      return isFr ? 'Il y a ${diff.inDays} jours' : '${diff.inDays} days ago';
    }
    return DateFormat('dd MMM', languageCode).format(date);
  }
}
