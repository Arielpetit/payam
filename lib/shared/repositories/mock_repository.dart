import '../models/transaction_model.dart';
import '../models/user_model.dart';
import '../models/notification_model.dart';
import '../models/nfc_transaction_model.dart';

class MockRepository {
  MockRepository._() {
    _currentUser = UserModel(
      id: 'usr_001',
      fullName: 'Ariel Tchikaya',
      phone: '+242 06 123 4567',
      email: 'ariel.tchikaya@payam.app',
      balance: 250000,
      accountNumber: '2420 0612 3456',
      isVerified: true,
    );

    _transactions = [
      TransactionModel(
        id: 'txn_001',
        title: 'Grocery Store',
        subtitle: 'Marché Total Brazzaville',
        amount: 15500,
        isCredit: false,
        type: TransactionType.payment,
        status: TransactionStatus.success,
        date: DateTime.now().subtract(const Duration(hours: 2)),
        reference: 'PAY20241001001',
        note: 'Weekly groceries',
      ),
      TransactionModel(
        id: 'txn_002',
        title: 'Money Received',
        subtitle: 'From: Jean-Baptiste Moukala',
        amount: 50000,
        isCredit: true,
        type: TransactionType.receive,
        status: TransactionStatus.success,
        date: DateTime.now().subtract(const Duration(hours: 5)),
        reference: 'PAY20241001002',
        recipientName: 'Jean-Baptiste Moukala',
        recipientPhone: '+242 06 987 6543',
      ),
      TransactionModel(
        id: 'txn_003',
        title: 'Airtime Top-up',
        subtitle: 'MTN Congo — +242 06 123 4567',
        amount: 5000,
        isCredit: false,
        type: TransactionType.airtime,
        status: TransactionStatus.success,
        date: DateTime.now().subtract(const Duration(days: 1)),
        reference: 'PAY20240930001',
      ),
      TransactionModel(
        id: 'txn_004',
        title: 'Fuel Payment',
        subtitle: 'Total Energies Station',
        amount: 25000,
        isCredit: false,
        type: TransactionType.payment,
        status: TransactionStatus.success,
        date: DateTime.now().subtract(const Duration(days: 1)),
        reference: 'PAY20240930002',
        note: 'Full tank',
      ),
      TransactionModel(
        id: 'txn_005',
        title: 'Transfer Sent',
        subtitle: 'To: Marie Nguesso',
        amount: 30000,
        isCredit: false,
        type: TransactionType.send,
        status: TransactionStatus.success,
        date: DateTime.now().subtract(const Duration(days: 2)),
        reference: 'PAY20240929001',
        recipientName: 'Marie Nguesso',
        recipientPhone: '+242 05 456 7890',
        note: 'Rent contribution',
      ),
      TransactionModel(
        id: 'txn_006',
        title: 'Electricity Bill',
        subtitle: 'SNE — Account #12345',
        amount: 18750,
        isCredit: false,
        type: TransactionType.bills,
        status: TransactionStatus.success,
        date: DateTime.now().subtract(const Duration(days: 3)),
        reference: 'PAY20240928001',
      ),
      TransactionModel(
        id: 'txn_007',
        title: 'Deposit',
        subtitle: 'Bank Transfer — Ecobank',
        amount: 100000,
        isCredit: true,
        type: TransactionType.deposit,
        status: TransactionStatus.success,
        date: DateTime.now().subtract(const Duration(days: 3)),
        reference: 'PAY20240928002',
      ),
      TransactionModel(
        id: 'txn_008',
        title: 'Data Bundle',
        subtitle: 'Airtel Congo — 10GB',
        amount: 8000,
        isCredit: false,
        type: TransactionType.data,
        status: TransactionStatus.pending,
        date: DateTime.now().subtract(const Duration(days: 4)),
        reference: 'PAY20240927001',
      ),
      TransactionModel(
        id: 'txn_009',
        title: 'Restaurant Payment',
        subtitle: 'Chez Nathalie Restaurant',
        amount: 22000,
        isCredit: false,
        type: TransactionType.payment,
        status: TransactionStatus.success,
        date: DateTime.now().subtract(const Duration(days: 5)),
        reference: 'PAY20240926001',
      ),
      TransactionModel(
        id: 'txn_010',
        title: 'Money Received',
        subtitle: 'From: Papa Tchikaya',
        amount: 75000,
        isCredit: true,
        type: TransactionType.receive,
        status: TransactionStatus.success,
        date: DateTime.now().subtract(const Duration(days: 6)),
        reference: 'PAY20240925001',
        recipientName: 'Papa Tchikaya',
      ),
    ];

    _notifications = [
      NotificationModel(
        id: 'notif_001',
        title: '💰 Payment Received',
        message:
            'You received FCFA 50,000 from Jean-Baptiste Moukala. The funds are now available in your wallet.',
        category: NotificationCategory.transaction,
        isRead: false,
        date: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      NotificationModel(
        id: 'notif_002',
        title: '🎁 Cashback Earned!',
        message:
            'Congratulations! You earned FCFA 2,500 cashback on your recent grocery purchase.',
        category: NotificationCategory.promotion,
        isRead: false,
        date: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      NotificationModel(
        id: 'notif_003',
        title: '🔐 Security Alert',
        message: 'Your account was accessed from a new device. If this was not you, contact support immediately.',
        category: NotificationCategory.security,
        isRead: true,
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
      NotificationModel(
        id: 'notif_004',
        title: '📱 Airtime Top-up Successful',
        message:
            'Your MTN airtime top-up of FCFA 5,000 for +242 06 123 4567 was successful.',
        category: NotificationCategory.transaction,
        isRead: true,
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
      NotificationModel(
        id: 'notif_005',
        title: '🎉 Invite & Earn',
        message:
            'Refer a friend to Payam and earn FCFA 5,000 when they complete their first transaction!',
        category: NotificationCategory.promotion,
        isRead: true,
        date: DateTime.now().subtract(const Duration(days: 2)),
      ),
      NotificationModel(
        id: 'notif_006',
        title: '✅ Bill Payment Confirmed',
        message:
            'Your electricity bill payment of FCFA 18,750 to SNE has been processed successfully.',
        category: NotificationCategory.transaction,
        isRead: true,
        date: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];

    _contacts = [
      UserModel(
        id: 'usr_002',
        fullName: 'Jean-Baptiste Moukala',
        phone: '+242 06 987 6543',
        email: 'jb.moukala@email.com',
        balance: 0,
        accountNumber: '2420 0698 7654',
        isVerified: true,
      ),
      UserModel(
        id: 'usr_003',
        fullName: 'Marie Nguesso',
        phone: '+242 05 456 7890',
        email: 'marie.nguesso@email.com',
        balance: 0,
        accountNumber: '2420 0545 6789',
        isVerified: true,
      ),
      UserModel(
        id: 'usr_004',
        fullName: 'Papa Tchikaya',
        phone: '+242 06 321 0987',
        email: 'papa.tchikaya@email.com',
        balance: 0,
        accountNumber: '2420 0632 1098',
        isVerified: false,
      ),
      UserModel(
        id: 'usr_005',
        fullName: 'Celestine Mbemba',
        phone: '+242 05 111 2233',
        email: 'celestine.mbemba@email.com',
        balance: 0,
        accountNumber: '2420 0511 1223',
        isVerified: true,
      ),
      UserModel(
        id: 'usr_006',
        fullName: 'Roland Ossali',
        phone: '+242 06 444 5566',
        email: 'roland.ossali@email.com',
        balance: 0,
        accountNumber: '2420 0644 4556',
        isVerified: true,
      ),
    ];

    _nfcTransactions = [];
  }

  static final MockRepository instance = MockRepository._();

  late UserModel _currentUser;
  late List<TransactionModel> _transactions;
  late List<NotificationModel> _notifications;
  late List<UserModel> _contacts;
  // NFC transactions storage
  late List<NfcTransaction> _nfcTransactions;

  UserModel get currentUser => _currentUser;
  List<TransactionModel> get transactions => _transactions;
  List<NotificationModel> get notifications => _notifications;
  List<UserModel> get contacts => _contacts;
  List<NfcTransaction> get nfcTransactions => _nfcTransactions;

  void addNfcTransaction(NfcTransaction txn) {
    _nfcTransactions.insert(0, txn);
    // Update balances based on direction
    if (txn.direction == NfcTransactionDirection.send) {
      // Sender loses amount, receiver gains
      // Assuming currentUser is the sender for simplicity
      _currentUser = _currentUser.copyWith(balance: _currentUser.balance - txn.amount);
    } else {
      _currentUser = _currentUser.copyWith(balance: _currentUser.balance + txn.amount);
    }
  }

  void addTransaction(TransactionModel txn) {
    _transactions.insert(0, txn);
    if (txn.isCredit) {
      _currentUser = _currentUser.copyWith(balance: _currentUser.balance + txn.amount);
    } else {
      _currentUser = _currentUser.copyWith(balance: _currentUser.balance - txn.amount);
    }
  }

  void addNotification(NotificationModel notif) {
    _notifications.insert(0, notif);
  }

  void markNotificationsRead() {
    _notifications = _notifications.map((n) {
      return NotificationModel(
        id: n.id,
        title: n.title,
        message: n.message,
        category: n.category,
        isRead: true,
        date: n.date,
      );
    }).toList();
  }
}
