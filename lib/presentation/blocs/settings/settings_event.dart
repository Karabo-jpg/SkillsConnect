import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {}

class ToggleTheme extends SettingsEvent {
  final bool isDarkMode;
  ToggleTheme(this.isDarkMode);

  @override
  List<Object?> get props => [isDarkMode];
}

class SetOnboardingSeen extends SettingsEvent {}

class SaveSearchQuery extends SettingsEvent {
  final String query;
  SaveSearchQuery(this.query);

  @override
  List<Object?> get props => [query];
}
