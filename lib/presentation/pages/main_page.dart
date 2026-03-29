import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillconnect/presentation/pages/home_page.dart';
import 'package:skillconnect/presentation/pages/profile_page.dart';
import 'package:skillconnect/presentation/blocs/provider_bloc.dart';
import 'package:skillconnect/domain/entities/booking_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Main page for client users with bottom navigation.
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
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month), label: 'Bookings'),
          BottomNavigationBarItem(
              icon: Icon(Icons.info_outline), label: 'Info'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profile'),
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
  Stream<List<BookingEntity>>? _bookingsStream;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final repo = context.read<ProviderBloc>().repository;
      _bookingsStream = repo.getBookingsStream(uid, 'client');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'My Bookings',
          style:
              TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE67E22)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _bookingsStream == null
          ? const Center(child: Text('Please log in to view bookings'))
          : StreamBuilder<List<BookingEntity>>(
              stream: _bookingsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final bookings = snapshot.data ?? [];
                if (bookings.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today,
                            size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No bookings yet',
                            style: TextStyle(color: Colors.grey, fontSize: 16)),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: bookings.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    return _ClientBookingCard(booking: booking);
                  },
                );
              },
            ),
    );
  }
}

class _ClientBookingCard extends StatelessWidget {
  final BookingEntity booking;
  const _ClientBookingCard({required this.booking});

  Color _statusColor(String status) {
    if (status == 'confirmed') status = 'accepted';
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'in-progress':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showEditDialog(BuildContext context) {
    final notesController = TextEditingController(text: booking.notes);
    DateTime? selectedDate = booking.scheduledDate;
    TimeOfDay? selectedTime = booking.scheduledDate != null
        ? TimeOfDay.fromDateTime(booking.scheduledDate!)
        : null;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Booking'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date
                    const Text('Scheduled Date',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ??
                              DateTime.now().add(const Duration(days: 1)),
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) setState(() => selectedDate = date);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                size: 18, color: Color(0xFFE67E22)),
                            const SizedBox(width: 8),
                            Text(selectedDate != null
                                ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                                : 'Select date'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Time
                    const Text('Scheduled Time',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: selectedTime ??
                              const TimeOfDay(hour: 9, minute: 0),
                        );
                        if (time != null) setState(() => selectedTime = time);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time,
                                size: 18, color: Color(0xFFE67E22)),
                            const SizedBox(width: 8),
                            Text(selectedTime != null
                                ? selectedTime!.format(context)
                                : 'Select time'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Notes
                    const Text('Notes',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Update your booking details...',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    DateTime? scheduledDateTime;
                    if (selectedDate != null) {
                      final time =
                          selectedTime ?? const TimeOfDay(hour: 9, minute: 0);
                      scheduledDateTime = DateTime(
                        selectedDate!.year,
                        selectedDate!.month,
                        selectedDate!.day,
                        time.hour,
                        time.minute,
                      );
                    }
                    context.read<ProviderBloc>().add(EditBookingEvent(
                          bookingId: booking.bid,
                          notes: notesController.text.trim(),
                          scheduledDate: scheduledDateTime,
                        ));
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Booking updated!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A085),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Booking'),
        content: const Text(
            'Are you sure you want to delete this booking? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              context.read<ProviderBloc>().add(DeleteBookingEvent(booking.bid));
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Booking deleted')),
              );
            },
            child:
                const Text('Yes, Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canEdit = booking.status == 'pending' ||
        booking.status == 'accepted' ||
        booking.status == 'confirmed';
    String displayStatus =
        booking.status == 'confirmed' ? 'accepted' : booking.status;

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
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE67E22).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    const Icon(Icons.calendar_today, color: Color(0xFFE67E22)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<String>(
                      future: context
                          .read<ProviderBloc>()
                          .repository
                          .getBusinessName(booking.providerId),
                      builder: (context, snapshot) {
                        final providerName =
                            snapshot.data ?? booking.serviceName;
                        return Text(providerName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16));
                      },
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color:
                            _statusColor(displayStatus).withValues(alpha: 0.1),
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
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFFE67E22))),
            ],
          ),

          // Scheduled date
          if (booking.scheduledDate != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.event, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Scheduled: ${booking.scheduledDate!.day}/${booking.scheduledDate!.month}/${booking.scheduledDate!.year} at ${TimeOfDay.fromDateTime(booking.scheduledDate!).format(context)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ],

          // Notes
          if (booking.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Notes: ${booking.notes}',
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ],

          // Action buttons
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (canEdit)
                TextButton.icon(
                  onPressed: () => _showEditDialog(context),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF16A085)),
                ),
              TextButton.icon(
                onPressed: () => _showDeleteDialog(context),
                icon: const Icon(Icons.delete, size: 16),
                label: const Text('Delete'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
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
          style:
              TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE67E22)),
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
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE67E22)),
            ),
            SizedBox(height: 12),
            Text(
              'SkillConnect bridges the gap between local service providers and clients. '
              'Browse skilled professionals in tailoring, baking, hairstyling, and more.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 24),
            Text('How It Works',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            _InfoItem(
                icon: Icons.search,
                title: 'Browse',
                description: 'Search for service providers by category'),
            SizedBox(height: 12),
            _InfoItem(
                icon: Icons.person,
                title: 'Connect',
                description: 'View provider profiles, ratings, and portfolios'),
            SizedBox(height: 12),
            _InfoItem(
                icon: Icons.calendar_today,
                title: 'Book',
                description: 'Book services securely with Mobile Money'),
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

  const _InfoItem(
      {required this.icon, required this.title, required this.description});

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
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              Text(description, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }
}
