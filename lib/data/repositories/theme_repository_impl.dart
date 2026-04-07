import 'package:flutter/material.dart';

import '../../domain/repositories/theme_repository.dart';
import '../datasources/theme_local_data_source.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  ThemeRepositoryImpl(this._local);

  final ThemeLocalDataSource _local;

  @override
  Future<ThemeMode> loadThemeMode() async => _local.load();

  @override
  Future<void> saveThemeMode(ThemeMode mode) => _local.save(mode);
}
