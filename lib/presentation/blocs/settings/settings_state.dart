import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  final bool isDarkMode;
  final bool hasSeenOnboarding;
  final String? lastSearchQuery;

  const SettingsState({
    required this.isDarkMode,
    required this.hasSeenOnboarding,
    this.lastSearchQuery,
  });

  factory SettingsState.initial() {
    return const SettingsState(
      isDarkMode: false,
      hasSeenOnboarding: false,
    );
  }

  SettingsState copyWith({
    bool? isDarkMode,
    bool? hasSeenOnboarding,
    String? lastSearchQuery,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      lastSearchQuery: lastSearchQuery ?? this.lastSearchQuery,
    );
  }

  @override
  List<Object?> get props => [isDarkMode, hasSeenOnboarding, lastSearchQuery];
}
