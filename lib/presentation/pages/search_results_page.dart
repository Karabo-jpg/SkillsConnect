import 'package:flutter/material.dart';
import 'package:skillconnect/presentation/pages/provider_profile_page.dart';

class SearchResultsPage extends StatelessWidget {
  final String category;

  const SearchResultsPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFE67E22)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Results: $category',
          style: const TextStyle(
            color: Color(0xFFE67E22),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: const [
          _ProviderResultCard(
            name: 'Faith\'s Stitch Studio',
            price: '100,000 UGX',
          ),
          SizedBox(height: 20),
          _ProviderResultCard(
            name: 'Juliet Fashion',
            price: '150,000 UGX',
          ),
        ],
      ),
    );
  }
}

class _ProviderResultCard extends StatelessWidget {
  final String name;
  final String price;

  const _ProviderResultCard({
    required this.name,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.check_circle, color: Colors.green, size: 18),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Starting from $price',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProviderProfilePage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE67E22),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('View Profile'),
            ),
          ),
        ],
      ),
    );
  }
}
