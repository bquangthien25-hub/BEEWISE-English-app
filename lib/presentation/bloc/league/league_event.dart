import 'package:equatable/equatable.dart';

abstract class LeagueEvent extends Equatable {
  const LeagueEvent();

  @override
  List<Object?> get props => [];
}

class LeagueLoadRequested extends LeagueEvent {
  const LeagueLoadRequested();
}
