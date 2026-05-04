import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;
  final bool isActive;
  final String? role;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    this.createdAt,
    this.lastLoginAt,
    this.isActive = true,
    this.role,
  });

  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isActive,
    String? role,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
      role: role ?? this.role,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        avatarUrl,
        createdAt,
        lastLoginAt,
        isActive,
        role,
      ];
}
