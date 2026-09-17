import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/repositories/equipment_repository.dart';
import '../../../domain/models/equipment_profile.dart';
import '../../viewmodels/planner_viewmodel.dart';

class EquipmentSelectionSheet extends StatefulWidget {
  const EquipmentSelectionSheet({super.key});

  @override
  State<EquipmentSelectionSheet> createState() => _EquipmentSelectionSheetState();
}

class _EquipmentSelectionSheetState extends State<EquipmentSelectionSheet> {
  @override
  Widget build(BuildContext context) {
    final repo = context.read<EquipmentRepository>();
    final planner = context.watch<PlannerViewModel>();

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.9,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Scaffold(
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

              final card = Card(
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

              return Dismissible(
                key: ValueKey('eq_${eq.id}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  decoration: BoxDecoration(
                    color: Colors.red.shade400,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Equipment?'),
                      content: Text('Are you sure you want to delete ${eq.name}?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) async {
                  await repo.deleteEquipment(eq.id);
                  setState(() {});
                },
                child: card,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEquipmentDialog(context),
        child: const Icon(Icons.add),
      ),
        ),
      ),
    );
  }

  void _showAddEquipmentDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final focalLengthCtrl = TextEditingController();
    final apertureCtrl = TextEditingController();
    final sensorWidthCtrl = TextEditingController();
    final sensorHeightCtrl = TextEditingController();
    final pixelCtrl = TextEditingController();
    final resWidthCtrl = TextEditingController();
    final resHeightCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Custom Equipment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name (e.g. My Lens)')),
                TextField(controller: focalLengthCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Focal Length (mm)')),
                TextField(controller: apertureCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Aperture (f/)')),
                TextField(controller: sensorWidthCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Sensor Width (mm)')),
                TextField(controller: sensorHeightCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Sensor Height (mm)')),
                TextField(controller: pixelCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Pixel Pitch (µm)')),
                TextField(controller: resWidthCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Resolution Width (px)')),
                TextField(controller: resHeightCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Resolution Height (px)')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final eq = EquipmentProfile(
                  id: 0,
                  name: nameCtrl.text,
                  focalLength: double.tryParse(focalLengthCtrl.text) ?? 50.0,
                  aperture: double.tryParse(apertureCtrl.text) ?? 2.8,
                  sensorWidth: double.tryParse(sensorWidthCtrl.text) ?? 36.0,
                  sensorHeight: double.tryParse(sensorHeightCtrl.text) ?? 24.0,
                  pixelPitch: double.tryParse(pixelCtrl.text) ?? 3.76,
                  resolutionWidth: int.tryParse(resWidthCtrl.text) ?? 6000,
                  resolutionHeight: int.tryParse(resHeightCtrl.text) ?? 4000,
                );
                await context.read<EquipmentRepository>().insertEquipment(eq);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  setState(() {});
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
