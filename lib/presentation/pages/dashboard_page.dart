import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillconnect/domain/entities/booking_entity.dart';
import 'package:skillconnect/domain/entities/provider_entity.dart';
import 'package:skillconnect/presentation/blocs/provider_bloc.dart';
import 'package:skillconnect/presentation/pages/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';


class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ProviderBloc>().add(LoadProviderDashboard(uid));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFE67E22),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
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
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return BlocBuilder<ProviderBloc, ProviderState>(
          builder: (context, state) {
            if (state is ProviderLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DashboardLoaded) {
              return _DashboardHome(
                profile: state.profile,
                bookings: state.bookings,
              );
            } else if (state is ProviderError) {
              return const Center(child: Text('Error: {state.message}'));
            }
            return const Center(child: Text('Loading dashboard...'));
          },
        );
      case 1:
        return BlocBuilder<ProviderBloc, ProviderState>(
          builder: (context, state) {
            if (state is DashboardLoaded) {
              return _ProviderBookingsTab(bookings: state.bookings);
            }
            return const Center(child: Text('Loading bookings...'));
          },
        );
      case 2:
        return _buildInfoTab(context);
      case 3:
        return const ProfilePage();
      default:
        return const Center(child: Text('Unknown screen'));
    }
  }

  Widget _buildInfoTab(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Info & Support', style: TextStyle(color: Color(0xFFE67E22), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const ListTile(leading: Icon(Icons.help_outline, color: Color(0xFFE67E22)), title: Text('Help Center'), subtitle: Text('Get help with managing bookings')),
          const ListTile(leading: Icon(Icons.policy, color: Color(0xFFE67E22)), title: Text('Provider Terms of Service')),
          const ListTile(leading: Icon(Icons.privacy_tip, color: Color(0xFFE67E22)), title: Text('Privacy Policy')),
          const ListTile(leading: Icon(Icons.star_border, color: Color(0xFFE67E22)), title: Text('Rate the App')),
          const SizedBox(height: 40),
          Center(
            child: Text('SkillConnect Provider v1.0.0', style: TextStyle(color: Colors.grey.shade500)),
          ),
        ],
      ),
    );
  }
}

class _DashboardHome extends StatelessWidget {
  final ProviderEntity profile;
  final List<BookingEntity> bookings;

  const _DashboardHome({required this.profile, required this.bookings});

  @override
  Widget build(BuildContext context) {
    // Calculate dynamically based on all non-cancelled bookings
    final double computedBalance = bookings
        .where((b) => b.status != 'rejected')
        .fold<double>(0.0, (sum, b) => sum + b.depositAmount);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              'Hello, ${profile.businessName}!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFE67E22)),
            ),
            const SizedBox(height: 20),
            _BalanceCard(balance: '${computedBalance.toStringAsFixed(0)} UGX'),
            const SizedBox(height: 30),
            const Text('Active Bookings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _ProviderBookingList(bookings: bookings.where((b) => b.status != 'completed' && b.status != 'rejected').toList()),
            const SizedBox(height: 30),
            _DashboardAction(
              icon: Icons.mail_outline,
              title: 'Current Orders',
              trailing: '${bookings.where((b) => b.status == 'in-progress').length}',
            ),
            const SizedBox(height: 16),
            _DashboardAction(
              icon: Icons.trending_up,
              title: 'Total Earnings',
              trailing: '${computedBalance.toStringAsFixed(0)} UGX',
              isPositive: true,
            ),
            const SizedBox(height: 16),
            const _DashboardAction(
              icon: Icons.grid_view_rounded,
              title: 'My Portfolio',
              trailing: '0 items',
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final String balance;
  const _BalanceCard({required this.balance});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFE67E22),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE67E22).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Mobile Money Balance', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Text(balance, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _DashboardAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String trailing;
  final bool isPositive;

  const _DashboardAction({required this.icon, required this.title, required this.trailing, this.isPositive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFE67E22)),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isPositive ? Colors.green[50] : Colors.orange[50],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              trailing,
              style: TextStyle(
                color: isPositive ? Colors.green : const Color(0xFFE67E22),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Provider bookings tab with full status management
class _ProviderBookingsTab extends StatelessWidget {
  final List<BookingEntity> bookings;
  const _ProviderBookingsTab({required this.bookings});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Manage Bookings', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE67E22))),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: bookings.isEmpty
          ? const Center(child: Text('No bookings yet', style: TextStyle(color: Colors.grey)))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _ProviderBookingCard(booking: bookings[index]),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Implement navigation to CreateProductPage
          Navigator.pushNamed(context, '/createProduct');
        },
        icon: const Icon(Icons.add_box_rounded),
        label: const Text('Create Product/Service'),
        backgroundColor: const Color(0xFFE67E22),
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _ProviderBookingCard extends StatelessWidget {
  final BookingEntity booking;
  const _ProviderBookingCard({required this.booking});

  Color _statusColor(String status) {
    if (status == 'confirmed') status = 'accepted'; // legacy mapping
    switch (status) {
      case 'pending': return Colors.orange;
      case 'accepted': return Colors.blue;
      case 'in-progress': return Colors.purple;
      case 'completed': return Colors.green;
      case 'rejected': return Colors.red;
      default: return Colors.grey;
    }
  }

  /// Returns the next action buttons based on current status
  List<Widget> _buildActions(BuildContext context) {
    String currentStatus = booking.status == 'confirmed' ? 'accepted' : booking.status;
    switch (currentStatus) {
      case 'pending':
        return [
          _ActionButton(
            label: 'Accept',
            color: Colors.green,
            icon: Icons.check,
            onPressed: () {
              context.read<ProviderBloc>().add(
                UpdateBookingStatusEvent(bookingId: booking.bid, newStatus: 'accepted'),
              );
            },
          ),
          const SizedBox(width: 8),
          _ActionButton(
            label: 'Reject',
            color: Colors.red,
            icon: Icons.close,
            onPressed: () {
              context.read<ProviderBloc>().add(
                UpdateBookingStatusEvent(bookingId: booking.bid, newStatus: 'rejected'),
              );
            },
          ),
        ];
      case 'accepted':
        return [
          _ActionButton(
            label: 'Cancel',
            color: Colors.red,
            icon: Icons.cancel,
            onPressed: () {
              context.read<ProviderBloc>().add(
                UpdateBookingStatusEvent(bookingId: booking.bid, newStatus: 'rejected'),
              );
            },
          ),
          const SizedBox(width: 8),
          _ActionButton(
            label: 'Start Work',
            color: Colors.purple,
            icon: Icons.play_arrow,
            onPressed: () {
              context.read<ProviderBloc>().add(
                UpdateBookingStatusEvent(bookingId: booking.bid, newStatus: 'in-progress'),
              );
            },
          ),
        ];
      case 'in-progress':
        return [
          _ActionButton(
            label: 'Cancel',
            color: Colors.red,
            icon: Icons.cancel,
            onPressed: () {
              context.read<ProviderBloc>().add(
                UpdateBookingStatusEvent(bookingId: booking.bid, newStatus: 'rejected'),
              );
            },
          ),
          const SizedBox(width: 8),
          _ActionButton(
            label: 'Mark Complete',
            color: Colors.green,
            icon: Icons.done_all,
            onPressed: () {
              context.read<ProviderBloc>().add(
                UpdateBookingStatusEvent(bookingId: booking.bid, newStatus: 'completed'),
              );
            },
          ),
        ];
      default:
        return []; // completed / rejected — no actions
    }
  }

  @override
  Widget build(BuildContext context) {
    String displayStatus = booking.status == 'confirmed' ? 'accepted' : booking.status;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _statusColor(displayStatus).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.calendar_today, color: _statusColor(displayStatus)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.serviceName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    // Add FutureBuilder for Client Name and Message button
                    FutureBuilder<String>(
                      future: context.read<ProviderBloc>().repository.getUserName(booking.clientId),
                      builder: (context, snapshot) {
                        final clientName = snapshot.data ?? 'Loading client...';
                        return Row(
                          children: [
                            Expanded(
                              child: Text('Client: $clientName', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                            ),
                            Builder(
                              builder: (context) {
                                final currentUser = FirebaseAuth.instance.currentUser;
                                if (currentUser == null || currentUser.uid == booking.clientId) {
                                  return const SizedBox.shrink();
                                }
                                return const IconButton(
                                  icon: Icon(Icons.message, color: Color(0xFFE67E22)),
                                  tooltip: 'Message Client',
                                  onPressed: null, // Chat feature removed, button disabled
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _statusColor(displayStatus).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        displayStatus.toUpperCase(),
                        style: TextStyle(
                          color: _statusColor(displayStatus),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text('${booking.depositAmount.toStringAsFixed(0)} UGX',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE67E22))),
            ],
          ),

          // Scheduled Date
          if (booking.scheduledDate != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.event, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Scheduled: ${booking.scheduledDate!.day}/${booking.scheduledDate!.month}/${booking.scheduledDate!.year}',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ],

          // Client Notes
          if (booking.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.notes, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text('Client notes: ${booking.notes}',
                        style: const TextStyle(fontSize: 13, color: Colors.grey)),
                  ),
                ],
              ),
            ),
          ],

          // Action Buttons
          if (_buildActions(context).isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: _buildActions(context),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onPressed;

  const _ActionButton({required this.label, required this.color, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _ProviderBookingList extends StatelessWidget {
  final List<BookingEntity> bookings;
  const _ProviderBookingList({required this.bookings});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: Text('No active bookings')),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: bookings.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _ProviderBookingCard(booking: bookings[index]),
    );
  }
}
