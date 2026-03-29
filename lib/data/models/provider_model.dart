import 'package:skillconnect/domain/entities/provider_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    required super.displayName,
    required super.photoUrl,
    required super.userType,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      userType: json['userType'] ?? 'client',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'userType': userType,
    };
  }
}

class ProviderModel extends ProviderEntity {
  const ProviderModel({
    required super.providerId,
    required super.businessName,
    required super.bio,
    required super.rating,
    required super.ratingCount,
    required super.portfolioImages,
    required super.baseRate,
    required super.category,
    required super.totalEarnings,
    required super.profileImageBase64,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    return ProviderModel(
      providerId: json['pid'] ?? json['providerId'] ?? '',
      businessName: json['businessName'] ?? json['name'] ?? '',
      bio: json['bio'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      ratingCount: json['ratingCount'] ?? 0,
      portfolioImages: List<String>.from(json['portfolioImages'] ?? []),
      baseRate: (json['baseRate'] ?? json['basePrice'] ?? 0.0).toDouble(),
      category: json['category'] ?? '',
      totalEarnings: (json['totalEarnings'] ?? 0.0).toDouble(),
      profileImageBase64: json['profileImageBase64'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pid': providerId,
      'businessName': businessName,
      'bio': bio,
      'rating': rating,
      'ratingCount': ratingCount,
      'portfolioImages': portfolioImages,
      'baseRate': baseRate,
      'category': category,
      'totalEarnings': totalEarnings,
      'profileImageBase64': profileImageBase64,
    };
  }
}
