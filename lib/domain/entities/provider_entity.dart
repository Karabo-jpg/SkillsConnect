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
  final String name;
  final String bio;
  final double rating;
  final int ratingCount;
  final List<String> portfolioImages;
  final int basePrice;
  final String category;

  const ProviderEntity({
    required this.providerId,
    required this.name,
    required this.bio,
    required this.rating,
    required this.ratingCount,
    required this.portfolioImages,
    required this.basePrice,
    required this.category,
  });

  @override
  List<Object?> get props => [
        providerId,
        name,
        bio,
        rating,
        ratingCount,
        portfolioImages,
        basePrice,
        category,
      ];
}
