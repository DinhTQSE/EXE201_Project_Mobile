class User {
  final String id;
  final String email;
  final String displayName;
  final String? fullName;
  final String? avatarUrl;
  final String? bio;
  final String role;
  final String accountType;
  final UserSubscription? subscription;

  User({
    required this.id,
    required this.email,
    required this.displayName,
    this.fullName,
    this.avatarUrl,
    this.bio,
    required this.role,
    required this.accountType,
    this.subscription,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      displayName: json['displayName']?.toString() ?? json['fullName']?.toString() ?? json['email']?.toString() ?? '',
      fullName: json['fullName']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      bio: json['bio']?.toString(),
      role: json['role']?.toString() ?? 'USER',
      accountType: json['accountType']?.toString() ?? 'BASIC',
      subscription: json['subscription'] != null
          ? UserSubscription.fromJson(json['subscription'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'fullName': fullName,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'role': role,
      'accountType': accountType,
      'subscription': subscription?.toJson(),
    };
  }
}

class UserSubscription {
  final String planType;
  final String status;
  final String startDate;
  final String endDate;

  UserSubscription({
    required this.planType,
    required this.status,
    required this.startDate,
    required this.endDate,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      planType: json['planType']?.toString() ?? 'FREE',
      status: json['status']?.toString() ?? 'INACTIVE',
      startDate: json['startDate']?.toString() ?? '',
      endDate: json['endDate']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'planType': planType,
      'status': status,
      'startDate': startDate,
      'endDate': endDate,
    };
  }
}

class LoginResponse {
  final String accessToken;
  final User user;

  LoginResponse({
    required this.accessToken,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken']?.toString() ?? '',
      user: User.fromJson(json['user'] ?? {}),
    );
  }
}
