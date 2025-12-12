import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? profilePictureUrl;
  final bool isVerified;

  const UserEntity({
    required this.id,
    required this.email,
    this.username,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.profilePictureUrl,
    this.isVerified = false,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    username,
    firstName,
    lastName,
    phoneNumber,
    profilePictureUrl,
    isVerified,
  ];

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (username != null) {
      return username!;
    }
    return email.split('@')[0];
  }

  UserEntity copyWith({
    String? id,
    String? email,
    String? username,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profilePictureUrl,
    bool? isVerified,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
