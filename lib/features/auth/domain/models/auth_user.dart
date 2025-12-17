class AuthUser {
  final String uid;
  final String? phoneNumber;
  final String? email;

  const AuthUser({required this.uid, this.phoneNumber, this.email});

  @override
  String toString() {
    return 'AuthUser{uid: $uid, phoneNumber: $phoneNumber}';
  }
}
