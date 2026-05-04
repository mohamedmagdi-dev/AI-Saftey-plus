class UserProfileModel {
  const UserProfileModel({
    required this.username,
    this.email,
    this.role,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final username = json['username'] as String? ??
        json['name'] as String? ??
        json['user_name'] as String? ??
        '';
    final email = json['email'] as String?;
    final role = json['role'] as String?;
    return UserProfileModel(
      username: username.isEmpty ? 'User' : username,
      email: email,
      role: role,
    );
  }

  final String username;
  final String? email;
  final String? role;
}
