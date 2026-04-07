import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

class ThemeLoadRequested extends ThemeEvent {
  const ThemeLoadRequested();
}

class ThemeModeChanged extends ThemeEvent {
  const ThemeModeChanged(this.mode);

  final ThemeMode mode;

  @override
  List<Object?> get props => [mode];
}
