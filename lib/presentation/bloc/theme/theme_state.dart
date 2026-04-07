import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class ThemeState extends Equatable {
  const ThemeState();

  @override
  List<Object?> get props => [];
}

class ThemeInitial extends ThemeState {
  const ThemeInitial();
}

class ThemeReady extends ThemeState {
  const ThemeReady(this.mode);

  final ThemeMode mode;

  @override
  List<Object?> get props => [mode];
}
