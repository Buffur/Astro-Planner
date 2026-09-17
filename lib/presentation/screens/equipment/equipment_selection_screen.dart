import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/repositories/equipment_repository.dart';
import '../../../domain/models/equipment_profile.dart';
import '../../viewmodels/planner_viewmodel.dart';

class EquipmentSelectionScreen extends StatelessWidget {
  const EquipmentSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<EquipmentRepository>();
    final planner = context.watch<PlannerViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Equipment'),
      ),
      body: FutureBuilder<List<EquipmentProfile>>(
        future: repo.getAllEquipment(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No equipment available.'));
          }

          final equipmentList = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: equipmentList.length,
            itemBuilder: (context, index) {
              final eq = equipmentList[index];
              final isSelected = eq.id == planner.selectedEquipment?.id;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(eq.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${eq.resolutionWidth}x${eq.resolutionHeight} • ${eq.focalLength}mm f/${eq.aperture}'),
                  trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.blue) : null,
                  onTap: () {
                    planner.setEquipment(eq);
                    context.pop();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
