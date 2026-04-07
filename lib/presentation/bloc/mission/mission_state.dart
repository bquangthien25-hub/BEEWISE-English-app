import 'package:equatable/equatable.dart';

import '../../../domain/entities/daily_mission.dart';
import '../../../domain/entities/user_entity.dart';

abstract class MissionState extends Equatable {
  const MissionState();

  @override
  List<Object?> get props => [];
}

class MissionInitial extends MissionState {
  const MissionInitial();
}

class MissionLoading extends MissionState {
  const MissionLoading();
}

class MissionReady extends MissionState {
  const MissionReady({required this.missions, required this.user});

  final List<DailyMission> missions;
  final UserEntity user;

  @override
  List<Object?> get props => [missions, user];
}

class MissionError extends MissionState {
  const MissionError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
