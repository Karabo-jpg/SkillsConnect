import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillconnect/presentation/blocs/settings/settings_bloc.dart';
import 'package:skillconnect/presentation/blocs/settings/settings_event.dart';
import 'package:skillconnect/presentation/blocs/settings/settings_state.dart';

/// Settings page for managing user preferences.
/// Persisted via SharedPreferences and restored on app restart.
// ignore_for_file: unused_local_variable, prefer_const_constructors, prefer_const_literals_to_create_immutables
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE67E22)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFE67E22)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: const [
              // Theme toggle
              _ThemeToggle(),
              SizedBox(height: 16),
              // Last search query display
              _LastSearchQuery(),
              SizedBox(height: 16),
              // Onboarding reset
              _OnboardingReset(),
            ],
          );
        },
      ),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SettingsBloc>().state;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: const [
          Icon(Icons.dark_mode, color: Color(0xFFE67E22)),
          SizedBox(width: 16),
          Expanded(
            child: Text('Dark Mode', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
          _ThemeSwitch(),
        ],
      ),
    );
  }
}

class _ThemeSwitch extends StatelessWidget {
  const _ThemeSwitch();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SettingsBloc>().state;
    return Switch(
      value: state.isDarkMode,
      activeThumbColor: const Color(0xFFE67E22),
      onChanged: (value) {
        context.read<SettingsBloc>().add(ToggleTheme(value));
      },
    );
  }
}

class _LastSearchQuery extends StatelessWidget {
  const _LastSearchQuery();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SettingsBloc>().state;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: const [
          Icon(Icons.search, color: Color(0xFFE67E22)),
          SizedBox(width: 16),
          Expanded(
            child: _LastSearchText(),
          ),
        ],
      ),
    );
  }
}

class _LastSearchText extends StatelessWidget {
  const _LastSearchText();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SettingsBloc>().state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Last Search', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(
          state.lastSearchQuery ?? 'No recent searches',
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}

class _OnboardingReset extends StatelessWidget {
  const _OnboardingReset();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: const [
          Icon(Icons.info_outline, color: Color(0xFFE67E22)),
          SizedBox(width: 16),
          Expanded(
            child: Text('Reset Onboarding', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
