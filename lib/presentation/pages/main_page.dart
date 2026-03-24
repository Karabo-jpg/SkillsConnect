import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillconnect/presentation/pages/home_page.dart';
import 'package:skillconnect/presentation/pages/profile_page.dart';
import 'package:skillconnect/presentation/blocs/provider_bloc.dart';
import 'package:skillconnect/domain/entities/booking_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Main page for client users with bottom navigation.
/// Contains Home, Bookings, Info, and Profile tabs.
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFE67E22),
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.info_outline), label: 'Info'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return const HomePage();
      case 1:
        return const _ClientBookingsTab();
      case 2:
        return const _InfoTab();
      case 3:
        return const ProfilePage();
      default:
        return const HomePage();
    }
  }
}

/// Bookings tab showing client's bookings from Firestore in real-time.
class _ClientBookingsTab extends StatefulWidget {
  const _ClientBookingsTab();

  @override
  State<_ClientBookingsTab> createState() => _ClientBookingsTabState();
}

class _ClientBookingsTabState extends State<_ClientBookingsTab> {
  @override
  void initState() {
    super.initState();
    // Load client bookings stream
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      context.read<ProviderBloc>().add(LoadProviderDashboard(uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'My Bookings',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE67E22)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<ProviderBloc, ProviderState>(
        builder: (context, state) {
          if (state is ProviderLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DashboardLoaded) {
            if (state.bookings.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No bookings yet', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.bookings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final booking = state.bookings[index];
                return _BookingCard(booking: booking);
              },
            );
          }
          return const Center(child: Text('Loading bookings...'));
        },
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingEntity booking;
  const _BookingCard({required this.booking});

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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE67E22).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_today, color: Color(0xFFE67E22)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.serviceName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Status: ${booking.status}',
                  style: TextStyle(
                    color: booking.status == 'pending' ? Colors.orange : Colors.green,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (booking.status == 'pending')
            TextButton(
              onPressed: () {
                context.read<ProviderBloc>().add(CancelBooking(booking.bid));
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
    );
  }
}

/// Info/About tab with app information.
class _InfoTab extends StatelessWidget {
  const _InfoTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'About SkillConnect',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE67E22)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SkillConnect',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFE67E22)),
            ),
            SizedBox(height: 12),
            Text(
              'SkillConnect bridges the gap between local service providers and clients. '
              'Browse skilled professionals in tailoring, baking, hairstyling, and more.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 24),
            Text('How It Works', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            _InfoItem(icon: Icons.search, title: 'Browse', description: 'Search for service providers by category'),
            SizedBox(height: 12),
            _InfoItem(icon: Icons.person, title: 'Connect', description: 'View provider profiles, ratings, and portfolios'),
            SizedBox(height: 12),
            _InfoItem(icon: Icons.calendar_today, title: 'Book', description: 'Book services securely with Mobile Money'),
            SizedBox(height: 24),
            Text('Version 1.0.0', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _InfoItem({required this.icon, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF16A085).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF16A085)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(description, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }
}
