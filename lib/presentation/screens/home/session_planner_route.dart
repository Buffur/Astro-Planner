import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/library_viewmodels.dart';
import '../../viewmodels/plan_lifecycle_viewmodel.dart';
import '../../viewmodels/session_plan_viewmodel.dart';
import '../../viewmodels/startup_viewmodel.dart';
import 'home_screen.dart';

/// `/session/:id` (ADR-015): the session planner. `current` shows the
/// current session directly; a stored session id is opened first
/// (`PlanLifecycleViewModel.openSession`: a frozen session becomes a copy in a
/// new draft, TASK 11.4).
class SessionPlannerRoute extends StatefulWidget {
  const SessionPlannerRoute({super.key, required this.id});

  final String id;

  @override
  State<SessionPlannerRoute> createState() => _SessionPlannerRouteState();
}

class _SessionPlannerRouteState extends State<SessionPlannerRoute> {
  Future<void>? _opening;

  @override
  void initState() {
    super.initState();
    final id = int.tryParse(widget.id);
    final plan = context.read<SessionPlanViewModel>();
    if (id != null && id != plan.activeSessionId) {
      _opening = _open(
        context.read<StartupViewModel>(),
        context.read<PlanLifecycleViewModel>(),
        context.read<SessionsViewModel>(),
        id,
      );
    }
  }

  static Future<void> _open(
    StartupViewModel startup,
    PlanLifecycleViewModel lifecycle,
    SessionsViewModel sessions,
    int id,
  ) async {
    await startup.ready;
    final session = await sessions.get(id);
    if (session != null) await lifecycle.openSession(session);
  }

  @override
  Widget build(BuildContext context) {
    final opening = _opening;
    if (opening == null) return const HomeScreen();
    return FutureBuilder<void>(
      future: opening,
      builder: (context, snapshot) =>
          snapshot.connectionState == ConnectionState.done
          ? const HomeScreen()
          : const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}
