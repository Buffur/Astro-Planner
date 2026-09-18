import re

path = r'c:\Users\zalub\OneDrive\Desktop\Astro Planner\Astro-Planner\lib\presentation\screens\equipment\equipment_selection_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# Let's find the broken _StellariumRow block and replace it cleanly
# The broken block starts from:
#                    // Sensor Size W × H mm — auto-calculated or manual
#                    _StellariumRow(
#                      label: 'Sensor Size',
#                      unit: 'mm',
#                          final n = double.tryParse(v);
#                          if (n == null) return 'Invalid';
#                          if (n <= 0) return '> 0';
#                          return null;
#                        },
#                      ),
#                    ),

broken_block_regex = r"// Sensor Size W.*?_StellariumRow\([\s\S]*?label: 'Sensor Size',.*?unit: 'mm',\s*final n = double.*?return null;\s*},\s*\),\s*\),"

fixed_block = """// Sensor Size W × H mm — auto-calculated
                    _StellariumRow(
                      label: 'Sensor Size',
                      unit: 'mm',
                      fieldW: TextFormField(
                        controller: sensorWCtrl,
                        readOnly: true,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Theme.of(context).disabledColor),
                        decoration: const InputDecoration(
                          hintText: '23.50',
                          filled: true,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          final n = double.tryParse(v);
                          if (n == null) return 'Invalid';
                          if (n <= 0) return '> 0';
                          return null;
                        },
                      ),
                      fieldH: TextFormField(
                        controller: sensorHCtrl,
                        readOnly: true,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Theme.of(context).disabledColor),
                        decoration: const InputDecoration(
                          hintText: '15.70',
                          filled: true,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          final n = double.tryParse(v);
                          if (n == null) return 'Invalid';
                          if (n <= 0) return '> 0';
                          return null;
                        },
                      ),
                    ),"""

content = re.sub(broken_block_regex, fixed_block, content, flags=re.MULTILINE)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Fixed")
