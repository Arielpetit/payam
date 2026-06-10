class UserModel {
  final String id;
  final String fullName;
  final String phone;
  final String email;
  final String? avatarUrl;
  final double balance;
  final String accountNumber;
  final bool isVerified;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.email,
    this.avatarUrl,
    required this.balance,
    required this.accountNumber,
    this.isVerified = true,
  });

  UserModel copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? email,
    String? avatarUrl,
    double? balance,
    String? accountNumber,
    bool? isVerified,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      balance: balance ?? this.balance,
      accountNumber: accountNumber ?? this.accountNumber,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  String get firstName => fullName.split(' ').first;

  String get initials => fullName
      .split(' ')
      .where((e) => e.isNotEmpty)
      .map((e) => e[0])
      .take(2)
      .join()
      .toUpperCase();
}
