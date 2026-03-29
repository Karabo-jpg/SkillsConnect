import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillconnect/domain/entities/provider_entity.dart';
import 'package:skillconnect/presentation/blocs/provider_bloc.dart';
import 'package:skillconnect/presentation/pages/success_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

class ProviderProfilePage extends StatelessWidget {
  final ProviderEntity provider;
  const ProviderProfilePage({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfileHeader(provider: provider),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileNameSection(provider: provider),
                  const SizedBox(height: 20),
                  _ProfileBio(bio: provider.bio),
                  const SizedBox(height: 30),
                  _BookNowButton(provider: provider),
                  const SizedBox(height: 30),
                  const Text(
                    'Portfolio',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const _PortfolioGrid(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final ProviderEntity provider;
  const _ProfileHeader({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 250,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/portfolio_bg.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            color: Colors.black.withValues(alpha: 0.3),
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.only(top: 40, left: 10),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        Positioned(
          bottom: -40,
          left: 20,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey[200],
              backgroundImage: provider.profileImageBase64.isNotEmpty
                  ? MemoryImage(base64Decode(provider.profileImageBase64))
                  : null,
              child: provider.profileImageBase64.isEmpty
                  ? const Icon(Icons.person, size: 40, color: Colors.grey)
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileNameSection extends StatelessWidget {
  final ProviderEntity provider;
  const _ProfileNameSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            provider.businessName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 20),
            const SizedBox(width: 4),
            Text(
              provider.rating.toStringAsFixed(1),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProfileBio extends StatelessWidget {
  final String bio;
  const _ProfileBio({required this.bio});

  @override
  Widget build(BuildContext context) {
    return Text(
      bio.isEmpty ? 'No bio available.' : bio,
      style: TextStyle(color: Colors.grey[700], fontSize: 16),
    );
  }
}

class _BookNowButton extends StatelessWidget {
  final ProviderEntity provider;
  const _BookNowButton({required this.provider});

  String _getCategoryHint(String category) {
    switch (category.toLowerCase()) {
      case 'tailoring':
        return 'Describe fabric type, measurements, design preferences...';
      case 'baking':
        return 'Cake flavor, size, occasion, decoration style...';
      case 'hair':
        return 'Desired hairstyle, hair type, any references...';
      default:
        return 'Describe what you need for this service...';
    }
  }

  void _showBookingDialog(BuildContext context) {
    final notesController = TextEditingController();
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Book ${provider.businessName}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service & Price summary
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE67E22).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(provider.category, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('${provider.baseRate.toStringAsFixed(0)} UGX',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE67E22))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Date Picker
                    const Text('Preferred Date', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(const Duration(days: 1)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() => selectedDate = date);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 18, color: Color(0xFFE67E22)),
                            const SizedBox(width: 8),
                            Text(selectedDate != null
                                ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                                : 'Select date'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Time Picker
                    const Text('Preferred Time', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: const TimeOfDay(hour: 9, minute: 0),
                        );
                        if (time != null) {
                          setState(() => selectedTime = time);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time, size: 18, color: Color(0xFFE67E22)),
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
                    Text('Details (${provider.category})', style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: _getCategoryHint(provider.category),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                    final uid = FirebaseAuth.instance.currentUser?.uid;
                    if (uid == null) return;

                    DateTime? scheduledDateTime;
                    if (selectedDate != null) {
                      final time = selectedTime ?? const TimeOfDay(hour: 9, minute: 0);
                      scheduledDateTime = DateTime(
                        selectedDate!.year,
                        selectedDate!.month,
                        selectedDate!.day,
                        time.hour,
                        time.minute,
                      );
                    }

                    context.read<ProviderBloc>().add(CreateBookingEvent(
                      providerId: provider.providerId,
                      serviceName: provider.category,
                      amount: provider.baseRate.toInt(),
                      notes: notesController.text.trim(),
                      scheduledDate: scheduledDateTime,
                    ));

                    Navigator.pop(dialogContext);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A085),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Confirm Booking'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProviderBloc, ProviderState>(
      listener: (context, state) {
        if (state is BookingSuccess) {
          context.read<ProviderBloc>().add(LoadProvidersByCategory(provider.category));
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SuccessPage(
                serviceName: provider.category,
                amount: provider.baseRate.toInt(),
                providerName: provider.businessName,
              ),
            ),
          );
        } else if (state is ProviderError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Booking failed: ${state.message}')),
          );
        }
      },
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _showBookingDialog(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF16A085),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text(
            'Book Now',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class _PortfolioGrid extends StatelessWidget {
  const _PortfolioGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.image, color: Colors.grey),
        );
      },
    );
  }
}
