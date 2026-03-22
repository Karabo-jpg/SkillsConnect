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
    required super.name,
    required super.bio,
    required super.rating,
    required super.ratingCount,
    required super.portfolioImages,
    required super.basePrice,
    required super.category,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    return ProviderModel(
      providerId: json['providerId'] ?? '',
      name: json['name'] ?? '',
      bio: json['bio'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      ratingCount: json['ratingCount'] ?? 0,
      portfolioImages: List<String>.from(json['portfolioImages'] ?? []),
      basePrice: json['basePrice'] ?? 0,
      category: json['category'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'providerId': providerId,
      'name': name,
      'bio': bio,
      'rating': rating,
      'ratingCount': ratingCount,
      'portfolioImages': portfolioImages,
      'basePrice': basePrice,
      'category': category,
    };
  }
}
