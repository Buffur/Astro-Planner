import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/planner_viewmodel.dart';
import '../../../core/config/feature_scope.dart';

class SkyDarknessWidget extends StatelessWidget {
  const SkyDarknessWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PlannerViewModel>();
    final timeline = viewModel.nightTimeline;
    final theme = Theme.of(context);
    
    final lunarIllum = (viewModel.lunarIllumination * 100).toStringAsFixed(1);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sky Darkness & Timeline',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (FeatureScope.lightPollutionContext)
                  _BortleBadge(
                    bortleClass: viewModel.bortleClass,
                    onChanged: (val) {
                      if (val != null) {
                        viewModel.setBortleClass(val);
                      }
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Moon Status
            Row(
              children: [
                const Icon(Icons.nightlight_round, size: 20, color: Colors.blueGrey),
                const SizedBox(width: 8),
                Text('Moon Illumination: $lunarIllum%', style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Night Timeline
            _NightTimelineVisual(timeline: timeline),
          ],
        ),
      ),
    );
  }
}

class _BortleBadge extends StatelessWidget {
  final int bortleClass;
  final ValueChanged<int?> onChanged;

  const _BortleBadge({required this.bortleClass, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    Color textColor = Colors.white;
    switch (bortleClass) {
      case 1: badgeColor = Colors.black; break;
      case 2: badgeColor = Colors.blueGrey.shade900; break;
      case 3: badgeColor = Colors.blue.shade900; break;
      case 4: badgeColor = Colors.green.shade700; break;
      case 5: badgeColor = Colors.yellow.shade700; textColor = Colors.black; break;
      case 6: badgeColor = Colors.orange; break;
      case 7: badgeColor = Colors.deepOrange; break;
      case 8: badgeColor = Colors.red; break;
      case 9: badgeColor = Colors.white; textColor = Colors.red; break;
      default: badgeColor = Colors.grey; break;
    }

    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade400, width: 0.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: bortleClass,
          dropdownColor: Theme.of(context).cardColor,
          icon: Icon(Icons.arrow_drop_down, color: textColor),
          items: List.generate(
            9,
            (index) => DropdownMenuItem(
              value: index + 1,
              child: Text('Bortle ${index + 1}', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
            ),
          ),
          onChanged: onChanged,
          selectedItemBuilder: (BuildContext context) {
            return List.generate(9, (index) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 4.0),
                  child: Text(
                    'Bortle ${index + 1}',
                    style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              );
            });
          },
        ),
      ),
    );
  }
}

class _NightTimelineVisual extends StatelessWidget {
  final Map<String, DateTime?> timeline;

  const _NightTimelineVisual({required this.timeline});

  @override
  Widget build(BuildContext context) {
    String format(DateTime? dt) {
      if (dt == null) return '--:--';
      final local = dt.toLocal();
      return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _TimelinePoint(label: 'Sunset', time: format(timeline['sunset']), icon: Icons.wb_sunny_outlined, color: Colors.orange),
            _TimelinePoint(label: 'Astro Dusk', time: format(timeline['astroDusk']), icon: Icons.nights_stay_outlined, color: Colors.indigo),
            _TimelinePoint(label: 'Astro Dawn', time: format(timeline['astroDawn']), icon: Icons.nights_stay, color: Colors.indigo),
            _TimelinePoint(label: 'Sunrise', time: format(timeline['sunrise']), icon: Icons.wb_sunny, color: Colors.orange),
          ],
        ),
        const SizedBox(height: 12),
        // Visual bar
        Container(
          height: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            gradient: LinearGradient(
              colors: [
                Colors.orange.shade300,
                Colors.indigo.shade300,
                Colors.indigo.shade900,
                Colors.indigo.shade900,
                Colors.indigo.shade300,
                Colors.orange.shade300,
              ],
              stops: const [0.0, 0.2, 0.35, 0.65, 0.8, 1.0],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'True Night Window: ${format(timeline['astroDusk'])} - ${format(timeline['astroDawn'])}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _TimelinePoint extends StatelessWidget {
  final String label;
  final String time;
  final IconData icon;
  final Color color;

  const _TimelinePoint({required this.label, required this.time, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text(time, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10)),
      ],
    );
  }
}


