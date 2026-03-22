import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/settings_repository.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository settingsRepository;

  SettingsBloc({required this.settingsRepository}) : super(SettingsState.initial()) {
    on<LoadSettings>(_onLoadSettings);
    on<ToggleTheme>(_onToggleTheme);
    on<SetOnboardingSeen>(_onSetOnboardingSeen);
    on<SaveSearchQuery>(_onSaveSearchQuery);
  }

  Future<void> _onLoadSettings(LoadSettings event, Emitter<SettingsState> emit) async {
    final isDarkMode = await settingsRepository.getThemeMode();
    final hasSeenOnboarding = await settingsRepository.isOnboardingSeen();
    final lastQuery = await settingsRepository.getLastSearchQuery();

    emit(state.copyWith(
      isDarkMode: isDarkMode,
      hasSeenOnboarding: hasSeenOnboarding,
      lastSearchQuery: lastQuery,
    ));
  }

  Future<void> _onToggleTheme(ToggleTheme event, Emitter<SettingsState> emit) async {
    await settingsRepository.saveThemeMode(event.isDarkMode);
    emit(state.copyWith(isDarkMode: event.isDarkMode));
  }

  Future<void> _onSetOnboardingSeen(SetOnboardingSeen event, Emitter<SettingsState> emit) async {
    await settingsRepository.saveOnboardingSeen(true);
    emit(state.copyWith(hasSeenOnboarding: true));
  }

  Future<void> _onSaveSearchQuery(SaveSearchQuery event, Emitter<SettingsState> emit) async {
    await settingsRepository.saveLastSearchQuery(event.query);
    emit(state.copyWith(lastSearchQuery: event.query));
  }
}
