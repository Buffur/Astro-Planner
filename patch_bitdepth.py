import re

path = r'c:\Users\zalub\OneDrive\Desktop\Astro Planner\Astro-Planner\lib\presentation\screens\equipment\equipment_selection_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Add _selectedBitDepth
bitdepth_var = """    final rotationCtrl = TextEditingController(
        text: existing?.rotation != null
            ? existing!.rotation!.toString()
            : '');
    int _selectedBitDepth = existing?.bitDepth ?? 14;"""

content = re.sub(
    r"    final rotationCtrl = TextEditingController\(\s*text: existing\?\.rotation != null\s*\? existing!\.rotation!\.toString\(\)\s*: ''\);",
    bitdepth_var,
    content
)

# 2. Wrap builder in StatefulBuilder
content = content.replace(
    "    await showDialog(\n      context: context,\n      builder: (context) {\n        return AlertDialog(",
    "    await showDialog(\n      context: context,\n      builder: (context) {\n        return StatefulBuilder(builder: (context, setDialogState) {\n          return AlertDialog("
)

content = content.replace(
    "              child: Text(isEdit ? 'Save Changes' : 'Save'),\n            ),\n          ],\n        );\n      },\n    );",
    "              child: Text(isEdit ? 'Save Changes' : 'Save'),\n            ),\n          ],\n        );\n        });\n      },\n    );"
)

# 3. Add Dropdown at the end of Camera Sensor section
sensor_end = """                  const SizedBox(height: 20),
                  // ── Optics Section"""

dropdown = """                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: _selectedBitDepth,
                    decoration: const InputDecoration(
                      labelText: 'RAW Bit Depth',
                    ),
                    items: const [
                      DropdownMenuItem(value: 8, child: Text('8-bit')),
                      DropdownMenuItem(value: 10, child: Text('10-bit')),
                      DropdownMenuItem(value: 12, child: Text('12-bit')),
                      DropdownMenuItem(value: 14, child: Text('14-bit')),
                      DropdownMenuItem(value: 16, child: Text('16-bit')),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        setDialogState(() => _selectedBitDepth = v);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  // ── Optics Section"""

content = content.replace(sensor_end, dropdown)

# 4. Save into EquipmentProfile
save_block = """                  opticalMultiplier:
                      double.tryParse(multiplierCtrl.text) ?? 1.0,
                  rotation: rotationCtrl.text.trim().isEmpty
                      ? null
                      : double.tryParse(rotationCtrl.text),
                );"""

save_new = """                  opticalMultiplier:
                      double.tryParse(multiplierCtrl.text) ?? 1.0,
                  rotation: rotationCtrl.text.trim().isEmpty
                      ? null
                      : double.tryParse(rotationCtrl.text),
                  bitDepth: _selectedBitDepth,
                );"""

content = content.replace(save_block, save_new)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Patch applied")
