import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../shared/detail_scaffold.dart';
import '../../shared/night_text.dart';
import '../../viewmodels/night_conditions_viewmodel.dart';
import '../../viewmodels/session_plan_viewmodel.dart';
import '../../viewmodels/site_viewmodel.dart';
import '../../widgets/weather_forecast_widget.dart';
import 'night_moon_screen.dart';

/// The Weather detail (S6.5; ADR-019 §5, §9; ADR-012; UX-10): the plan's
/// night forecast in full, moved here from the planner with nothing lost —
/// every variable and hour, the night ranges, the dew heuristic, the model,
/// the attribution, the age and stale label, retry, and the unavailable,
/// beyond-horizon and unknown states. No score, no good/bad colouring.
/// Its richer presentation (an hourly visual, icons) is Stage 9's.
class WeatherDetailScreen extends StatelessWidget {
  const WeatherDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final plan = context.watch<SessionPlanViewModel>();
    final site = context.watch<SiteViewModel>();
    final conditions = context.watch<NightConditionsViewModel>();
    return DetailScaffold(
      title: 'Weather',
      context: detailContext(plan.sessionNight, site.locationName),
      // The forecast card names its zone once, beside its times.
      summary: Text(
        WeatherText.summary(
          conditions.nightWeather,
          conditions.nightWeatherSummary,
        ),
        key: const Key('weatherDetail.summary'),
      ),
      sections: const [WeatherForecastWidget()],
    );
  }
}
