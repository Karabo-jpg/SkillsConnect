import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillconnect/presentation/pages/provider_profile_page.dart';
import 'package:skillconnect/presentation/pages/search_results_page.dart'; // Added
import 'package:skillconnect/presentation/blocs/provider_bloc.dart'; // Added
import 'package:skillconnect/presentation/blocs/settings/settings_bloc.dart';
import 'package:skillconnect/presentation/blocs/settings/settings_event.dart';
import 'package:skillconnect/presentation/blocs/settings/settings_state.dart';
import 'package:skillconnect/domain/entities/provider_entity.dart'; // Added

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProviderBloc>().add(LoadProvidersByCategory('tailoring'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'SkillConnect',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFFE67E22),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) {
              return IconButton(
                icon: Icon(
                  state.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: const Color(0xFF16A085),
                ),
                onPressed: () {
                  context.read<SettingsBloc>().add(ToggleTheme(!state.isDarkMode));
                },
              );
            },
          ),
        ],
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SearchBar(),
              SizedBox(height: 30),
              _CategoriesSection(),
              SizedBox(height: 30),
              _RecommendedSection(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Find services...',
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Colors.grey),
        ),
        onSubmitted: (query) {
          if (query.isNotEmpty) {
            // Save the search query to shared preferences
            context.read<SettingsBloc>().add(SaveSearchQuery(query));
            // Navigate to search results
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchResultsPage(category: query),
              ),
            );
          }
        },
      ),
    );
  }
}

class _CategoriesSection extends StatelessWidget {
  const _CategoriesSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _CategoryItem(Icons.content_cut, 'Tailoring'),
            _CategoryItem(Icons.bakery_dining, 'Baking'),
            _CategoryItem(Icons.person, 'Hair'),
            _CategoryItem(Icons.grid_view_rounded, 'Other'),
          ],
        ),
      ],
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CategoryItem(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchResultsPage(category: label),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: const Color(0xFF16A085), size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _RecommendedSection extends StatelessWidget {
  const _RecommendedSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recommended Verified Providers',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        BlocBuilder<ProviderBloc, ProviderState>(
          builder: (context, state) {
            if (state is ProviderLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ProviderLoaded) {
              if (state.providers.isEmpty) {
                return const Text('No providers found in this category.');
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.providers.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final provider = state.providers[index];
                  return _ProviderCard(
                    provider: provider,
                  );
                },
              );
            } else if (state is ProviderError) {
              return Text('Error: ${state.message}');
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final ProviderEntity provider;

  const _ProviderCard({
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProviderProfilePage(provider: provider),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
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
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 60,
                height: 60,
                color: Colors.grey[200],
                child: const Icon(Icons.person, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          provider.businessName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.check_circle, color: Colors.green, size: 16),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      ...List.generate(
                        5,
                        (index) => Icon(
                          Icons.star,
                          color: index < provider.rating.floor() ? Colors.amber : Colors.grey[300],
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        provider.rating.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFFE67E22),
      unselectedItemColor: Colors.grey,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      currentIndex: 0,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Bookings'),
        BottomNavigationBarItem(icon: Icon(Icons.info_outline), label: 'Info'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    );
  }
}
