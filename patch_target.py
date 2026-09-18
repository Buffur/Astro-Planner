import re

with open(r'c:\Users\zalub\OneDrive\Desktop\Astro Planner\Astro-Planner\lib\presentation\screens\target\target_selection_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Add formKey
content = content.replace(
    'final isEdit = existing != null;',
    'final isEdit = existing != null;\n    final formKey = GlobalKey<FormState>();'
)

# Wrap Column in Form
content = content.replace(
    '''              content: SingleChildScrollView(
                child: Column(''',
    '''              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column('''
)

# End Form
content = content.replace(
    '''                  ],
                ),
              ),
              actions: [''',
    '''                  ],
                ),
                ),
              ),
              actions: ['''
)

# Replace ExpansionTile with normal Column and TextFormField
content = content.replace(
    '''                    const SizedBox(height: 16),
                    ExpansionTile(
                      title: const Text(
                        'Advanced Settings (Optional)',
                        style: TextStyle(fontSize: 14),
                      ),
                      childrenPadding:
                          const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                      tilePadding: EdgeInsets.zero,
                      children: [
                        TextField(
                          controller: raCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true, signed: true),
                          decoration: const InputDecoration(
                            labelText: 'Right Ascension (Degrees)',
                            hintText: '0.0',
                          ),
                        ),
                        TextField(
                          controller: decCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true, signed: true),
                          decoration: const InputDecoration(
                            labelText: 'Declination (Degrees)',
                            hintText: '0.0',
                          ),
                        ),
                      ],
                    ),''',
    '''                    const SizedBox(height: 16),
                    TextFormField(
                      controller: raCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: false),
                      decoration: const InputDecoration(
                        labelText: 'Right Ascension (Degrees) *',
                        hintText: '0.0 to 360.0',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        final n = double.tryParse(v);
                        if (n == null) return 'Must be a number';
                        if (n < 0.0 || n >= 360.0) return 'Must be 0.0 to 360.0';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: decCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      decoration: const InputDecoration(
                        labelText: 'Declination (Degrees) *',
                        hintText: '-90.0 to +90.0',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        final n = double.tryParse(v);
                        if (n == null) return 'Must be a number';
                        if (n < -90.0 || n > 90.0) return 'Must be -90.0 to +90.0';
                        return null;
                      },
                    ),'''
)

# Update TextField for nameCtrl to TextFormField
content = content.replace(
    '''                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Target Name',
                        hintText: 'e.g. Andromeda Galaxy',
                      ),
                    ),''',
    '''                    TextFormField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Target Name *',
                        hintText: 'e.g. Andromeda Galaxy',
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),'''
)


# Update save button to check form validation and parse safely
content = content.replace(
    '''                ElevatedButton(
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) return;
                    final repo = context.read<TargetRepository>();
                    final target = AstroTarget(
                      id: existing?.id ?? 0,
                      catalogId: name,
                      commonName: name,
                      type: selectedType,
                      rightAscension: double.tryParse(raCtrl.text) ?? 0.0,
                      declination: double.tryParse(decCtrl.text) ?? 0.0,
                    );''',
    '''                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) return;
                    final repo = context.read<TargetRepository>();
                    final target = AstroTarget(
                      id: existing?.id ?? 0,
                      catalogId: name,
                      commonName: name,
                      type: selectedType,
                      rightAscension: double.parse(raCtrl.text),
                      declination: double.parse(decCtrl.text),
                    );'''
)

with open(r'c:\Users\zalub\OneDrive\Desktop\Astro Planner\Astro-Planner\lib\presentation\screens\target\target_selection_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
