import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillconnect/presentation/pages/provider_profile_page.dart';
import 'package:skillconnect/presentation/blocs/provider_bloc.dart';
import 'package:skillconnect/domain/entities/provider_entity.dart';

class SearchResultsPage extends StatefulWidget {
  final String category;

  const SearchResultsPage({super.key, required this.category});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProviderBloc>().add(LoadProvidersByCategory(widget.category.toLowerCase()));
  }

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
          'Results: ${widget.category}',
          style: const TextStyle(
            color: Color(0xFFE67E22),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocBuilder<ProviderBloc, ProviderState>(
        builder: (context, state) {
          if (state is ProviderLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProviderLoaded) {
            if (state.providers.isEmpty) {
              return const Center(child: Text('No providers found in this category.'));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(20.0),
              itemCount: state.providers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _ProviderResultCard(provider: state.providers[index]);
              },
            );
          } else if (state is ProviderError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('Search for services'));
        },
      ),
    );
  }
}

class _ProviderResultCard extends StatelessWidget {
  final ProviderEntity provider;

  const _ProviderResultCard({required this.provider});

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
              Expanded(
                child: Text(
                  provider.businessName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.check_circle, color: Colors.green, size: 18),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Starting from ${provider.baseRate.toStringAsFixed(0)} UGX',
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
                    builder: (context) => ProviderProfilePage(provider: provider),
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
