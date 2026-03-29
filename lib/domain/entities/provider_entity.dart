import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;
  final String userType;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.photoUrl,
    required this.userType,
  });

  @override
  List<Object?> get props => [uid, email, displayName, photoUrl, userType];
}

class ProviderEntity extends Equatable {
  final String providerId;
  final String businessName;
  final String bio;
  final double rating;
  final int ratingCount;
  final List<String> portfolioImages;
  final double baseRate;
  final String category;
  final double totalEarnings;
  final String profileImageBase64;

  const ProviderEntity({
    required this.providerId,
    required this.businessName,
    required this.bio,
    required this.rating,
    required this.ratingCount,
    required this.portfolioImages,
    required this.baseRate,
    required this.category,
    this.totalEarnings = 0.0,
    required this.profileImageBase64,
  });

  @override
  List<Object?> get props => [
        providerId,
        businessName,
        bio,
        rating,
        ratingCount,
        portfolioImages,
        baseRate,
        category,
        totalEarnings,
        profileImageBase64,
      ];
}
