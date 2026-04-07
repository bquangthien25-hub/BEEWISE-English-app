import 'package:flutter_test/flutter_test.dart';

import 'package:beewise/core/dependency_injection/injection_container.dart';
import 'package:beewise/main.dart';
import 'package:beewise/presentation/bloc/auth_bloc.dart';
import 'package:beewise/presentation/bloc/league/league_bloc.dart';
import 'package:beewise/presentation/bloc/lesson_bloc.dart';
import 'package:beewise/presentation/bloc/mission/mission_bloc.dart';
import 'package:beewise/presentation/bloc/theme/theme_bloc.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('BeeWise loads login screen', (WidgetTester tester) async {
    await initDependencies();
    final authBloc = sl<AuthBloc>();
    final lessonBloc = sl<LessonBloc>();
    final themeBloc = sl<ThemeBloc>();
    final missionBloc = sl<MissionBloc>();
    final leagueBloc = sl<LeagueBloc>();

    await tester.pumpWidget(
      BeeWiseApp(
        authBloc: authBloc,
        lessonBloc: lessonBloc,
        themeBloc: themeBloc,
        missionBloc: missionBloc,
        leagueBloc: leagueBloc,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('BeeWise'), findsOneWidget);
  });
}
