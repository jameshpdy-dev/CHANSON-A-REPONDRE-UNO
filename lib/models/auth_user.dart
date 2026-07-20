class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    this.displayName,
    this.provider = 'Email',
  });

  final String id;
  final String email;
  final String? displayName;
  final String provider;
}
