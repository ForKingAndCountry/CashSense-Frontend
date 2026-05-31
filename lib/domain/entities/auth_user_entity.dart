class AuthUserEntity {
  const AuthUserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.baseCurrency = 'LRD',
  });

  final String id;
  final String email;
  final String name;
  final String baseCurrency;

  String get greetingName {
    final n = name.trim();
    if (n.isNotEmpty) return n.split(' ').first;
    if (email.contains('@')) return email.split('@').first;
    return 'Friend';
  }
}
