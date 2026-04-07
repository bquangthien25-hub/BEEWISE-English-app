import 'package:equatable/equatable.dart';

abstract class MissionEvent extends Equatable {
  const MissionEvent();

  @override
  List<Object?> get props => [];
}

class MissionLoadRequested extends MissionEvent {
  const MissionLoadRequested();
}

class MissionClaimRequested extends MissionEvent {
  const MissionClaimRequested(this.missionId);

  final String missionId;

  @override
  List<Object?> get props => [missionId];
}

class MissionRefreshRequested extends MissionEvent {
  const MissionRefreshRequested();
}
