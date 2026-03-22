import 'package:flutter_test/flutter_test.dart';
import 'package:skillconnect/data/models/provider_model.dart';

void main() {
  group('ProviderModel Tests', () {
    test('should return a valid model from JSON', () {
      final Map<String, dynamic> jsonMap = {
        'providerId': '123',
        'name': 'Faith',
        'bio': 'Passionate tailor',
        'rating': 4.9,
        'ratingCount': 120,
        'portfolioImages': ['img1.png', 'img2.png'],
        'basePrice': 50000,
        'category': 'Tailoring',
      };

      final result = ProviderModel.fromJson(jsonMap);

      expect(result.providerId, '123');
      expect(result.rating, 4.9);
      expect(result.portfolioImages.length, 2);
    });

    test('should return a valid JSON map from model', () {
      const model = ProviderModel(
        providerId: '123',
        name: 'Faith',
        bio: 'Passionate tailor',
        rating: 4.9,
        ratingCount: 120,
        portfolioImages: ['img1.png'],
        basePrice: 50000,
        category: 'Tailoring',
      );

      final result = model.toJson();

      expect(result['providerId'], '123');
      expect(result['basePrice'], 50000);
    });
  });
}
