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

  const ProviderEntity({
    required this.providerId,
    required this.businessName,
    required this.bio,
    required this.rating,
    required this.ratingCount,
    required this.portfolioImages,
    required this.baseRate,
    required this.category,
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
      ];
}
