import 'package:flutter_test/flutter_test.dart';
import 'package:skillconnect/data/models/provider_model.dart';
import 'package:skillconnect/data/models/booking_model.dart';

void main() {
  group('ProviderModel Tests', () {
    test('should return a valid model from JSON', () {
      const Map<String, dynamic> jsonMap = {
        'pid': '123',
        'businessName': 'Faith',
        'bio': 'Passionate tailor',
        'rating': 4.9,
        'ratingCount': 120,
        'portfolioImages': ['img1.png', 'img2.png'],
        'baseRate': 50000.0,
        'category': 'Tailoring',
        'totalEarnings': 150000.0,
      };

      final result = ProviderModel.fromJson(jsonMap);

      expect(result.providerId, '123');
      expect(result.rating, 4.9);
      expect(result.portfolioImages.length, 2);
    });

    test('should return a valid JSON map from model', () {
      const model = ProviderModel(
        providerId: '123',
        businessName: 'Faith',
        bio: 'Passionate tailor',
        rating: 4.9,
        ratingCount: 120,
        portfolioImages: ['img1.png'],
        baseRate: 50000.0,
        category: 'Tailoring',
        totalEarnings: 150000.0,
      );

      final result = model.toJson();

      expect(result['pid'], '123');
      expect(result['baseRate'], 50000.0);
    });
  });

  group('BookingModel Tests', () {
    test('should return a valid model from Firestore data', () {
      final date = DateTime(2024, 1, 1);
      final model = BookingModel(
        bid: 'b1',
        clientId: 'c1',
        providerId: 'p1',
        serviceName: 'Tailoring',
        bookingDate: date,
        depositAmount: 5000.0,
        status: 'pending',
      );

      final result = model.toFirestore();

      expect(result['clientId'], 'c1');
      expect(result['serviceName'], 'Tailoring');
      expect(result['depositAmount'], 5000.0);
    });

    test('should correctly serialize status field', () {
      final model = BookingModel(
        bid: 'b2',
        clientId: 'c2',
        providerId: 'p2',
        serviceName: 'Baking',
        bookingDate: DateTime(2024, 6, 15),
        depositAmount: 10000.0,
        status: 'accepted',
      );

      expect(model.status, 'accepted');
      expect(model.serviceName, 'Baking');
      expect(model.depositAmount, 10000.0);
    });
  });
}
