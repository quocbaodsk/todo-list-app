class User {
  final int id;
  final String email;
  final String username;
  final String? fullname;
  final bool isAdmin;
  final bool isActive;
  final String? avatarUrl;
  final String? lastLoginIp;
  final DateTime? lastLoginAt;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.username,
    this.fullname,
    this.isAdmin = false,
    this.isActive = true,
    this.avatarUrl,
    this.lastLoginIp,
    this.lastLoginAt,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      fullname: json['fullname'],
      isAdmin: json['is_admin'] == 1,
      isActive: json['is_active'] == 1,
      avatarUrl: json['avatar_url'],
      lastLoginIp: json['last_login_ip'],
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'])
          : null,
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.parse(json['email_verified_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'username': username,
      'fullname': fullname,
      'avatar_url': avatarUrl,
    };
  }
}