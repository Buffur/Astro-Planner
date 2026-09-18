import re

with open(r'c:\Users\zalub\OneDrive\Desktop\Astro Planner\Astro-Planner\lib\presentation\screens\equipment\equipment_selection_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Add formKey
content = content.replace(
    'final isEdit = existing != null;',
    'final isEdit = existing != null;\n    final formKey = GlobalKey<FormState>();'
)

# Wrap Column in Form
content = content.replace(
    '''            child: SingleChildScrollView(
              child: Column(''',
    '''            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column('''
)

# End Form
content = content.replace(
    '''                  ),
                ],
              ),
            ),
          ),
          actions: [''',
    '''                  ),
                ],
              ),
              ),
            ),
          ),
          actions: ['''
)

# Replace TextField with TextFormField
content = content.replace('TextField(', 'TextFormField(')

# Add validators to nameCtrl
content = content.replace(
    '''                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Profile Name',
                      hintText: 'e.g. ZWO ASI2600MC + 400mm Refractor',
                    ),
                  ),''',
    '''                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Profile Name',
                      hintText: 'e.g. ZWO ASI2600MC + 400mm Refractor',
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),'''
)

# Add validators to resWCtrl
content = content.replace(
    '''                    fieldW: TextFormField(
                      controller: resWCtrl,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      onChanged: (_) => autoSensorSize(),
                      decoration: const InputDecoration(hintText: '6248'),
                    ),''',
    '''                    fieldW: TextFormField(
                      controller: resWCtrl,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      onChanged: (_) => autoSensorSize(),
                      decoration: const InputDecoration(hintText: '6248'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        final n = int.tryParse(v);
                        if (n == null) return 'Invalid';
                        if (n <= 0) return '> 0';
                        return null;
                      },
                    ),'''
)

# Add validators to resHCtrl
content = content.replace(
    '''                    fieldH: TextFormField(
                      controller: resHCtrl,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      onChanged: (_) => autoSensorSize(),
                      decoration: const InputDecoration(hintText: '4176'),
                    ),''',
    '''                    fieldH: TextFormField(
                      controller: resHCtrl,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      onChanged: (_) => autoSensorSize(),
                      decoration: const InputDecoration(hintText: '4176'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        final n = int.tryParse(v);
                        if (n == null) return 'Invalid';
                        if (n <= 0) return '> 0';
                        return null;
                      },
                    ),'''
)

# Add validators to pixelCtrl (W and H)
content = content.replace(
    '''                    fieldW: TextFormField(
                      controller: pixelCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      textAlign: TextAlign.center,
                      onChanged: (_) => autoSensorSize(),
                      decoration: const InputDecoration(hintText: '3.76'),
                    ),''',
    '''                    fieldW: TextFormField(
                      controller: pixelCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      textAlign: TextAlign.center,
                      onChanged: (_) => autoSensorSize(),
                      decoration: const InputDecoration(hintText: '3.76'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        final n = double.tryParse(v);
                        if (n == null) return 'Invalid';
                        if (n <= 0) return '> 0';
                        return null;
                      },
                    ),'''
)

content = content.replace(
    '''                    fieldH: TextFormField(
                      controller: pixelCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      textAlign: TextAlign.center,
                      onChanged: (_) => autoSensorSize(),
                      decoration: const InputDecoration(hintText: '3.76'),
                    ),''',
    '''                    fieldH: TextFormField(
                      controller: pixelCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      textAlign: TextAlign.center,
                      onChanged: (_) => autoSensorSize(),
                      decoration: const InputDecoration(hintText: '3.76'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        final n = double.tryParse(v);
                        if (n == null) return 'Invalid';
                        if (n <= 0) return '> 0';
                        return null;
                      },
                    ),'''
)

# Add validators to sensorWCtrl and sensorHCtrl
content = content.replace(
    '''                    fieldW: TextFormField(
                      controller: sensorWCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(hintText: '23.50'),
                    ),''',
    '''                    fieldW: TextFormField(
                      controller: sensorWCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(hintText: '23.50'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        final n = double.tryParse(v);
                        if (n == null) return 'Invalid';
                        if (n <= 0) return '> 0';
                        return null;
                      },
                    ),'''
)

content = content.replace(
    '''                    fieldH: TextFormField(
                      controller: sensorHCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(hintText: '15.70'),
                    ),''',
    '''                    fieldH: TextFormField(
                      controller: sensorHCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(hintText: '15.70'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        final n = double.tryParse(v);
                        if (n == null) return 'Invalid';
                        if (n <= 0) return '> 0';
                        return null;
                      },
                    ),'''
)

# Add validators to focalCtrl and apertureCtrl
content = content.replace(
    '''                        child: TextFormField(
                          controller: focalCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(
                              labelText: 'Focal Length (mm)'),
                        ),''',
    '''                        child: TextFormField(
                          controller: focalCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(
                              labelText: 'Focal Length (mm)'),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Required';
                            final n = double.tryParse(v);
                            if (n == null) return 'Invalid';
                            if (n <= 0) return 'Must be > 0';
                            return null;
                          },
                        ),'''
)

content = content.replace(
    '''                        child: TextFormField(
                          controller: apertureCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration:
                              const InputDecoration(labelText: 'Aperture (f/)'),
                        ),''',
    '''                        child: TextFormField(
                          controller: apertureCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration:
                              const InputDecoration(labelText: 'Aperture (f/)'),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Required';
                            final n = double.tryParse(v);
                            if (n == null) return 'Invalid';
                            if (n <= 0) return 'Must be > 0';
                            return null;
                          },
                        ),'''
)

# Add validators to multiplierCtrl
content = content.replace(
    '''                        child: TextFormField(
                          controller: multiplierCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Optical Multiplier',
                            hintText: '1.0',
                          ),
                        ),''',
    '''                        child: TextFormField(
                          controller: multiplierCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Optical Multiplier',
                            hintText: '1.0',
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Required';
                            final n = double.tryParse(v);
                            if (n == null) return 'Invalid';
                            if (n <= 0) return 'Must be > 0';
                            return null;
                          },
                        ),'''
)

# Add validator to rotationCtrl (optional)
content = content.replace(
    '''                        child: TextFormField(
                          controller: rotationCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true, signed: true),
                          decoration: const InputDecoration(
                            labelText: 'Rotation (В°)',
                            hintText: 'Optional',
                          ),
                        ),''',
    '''                        child: TextFormField(
                          controller: rotationCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true, signed: true),
                          decoration: const InputDecoration(
                            labelText: 'Rotation (В°)',
                            hintText: 'Optional',
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return null;
                            if (double.tryParse(v) == null) return 'Invalid';
                            return null;
                          },
                        ),'''
)

# Update save button to check form validation
content = content.replace(
    '''            ElevatedButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;''',
    '''            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;'''
)

# Make _StellariumRow vertically align to top to handle error messages gracefully
content = content.replace(
    '''    return Row(
      children: [''',
    '''    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: ['''
)

# The text and multiplier characters in _StellariumRow need padding to align with the fields properly now that they are top-aligned
content = content.replace(
    '''        SizedBox(
          width: 90,
          child: Text(label,
              style: Theme.of(context).textTheme.bodyMedium),
        ),''',
    '''        SizedBox(
          width: 90,
          child: Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Text(label,
                style: Theme.of(context).textTheme.bodyMedium),
          ),
        ),'''
)
content = content.replace(
    '''        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text('Г—',
              style: Theme.of(context).textTheme.titleMedium),
        ),''',
    '''        Padding(
          padding: const EdgeInsets.only(left: 6, right: 6, top: 12),
          child: Text('Г—',
              style: Theme.of(context).textTheme.titleMedium),
        ),'''
)
content = content.replace(
    '''        const SizedBox(width: 6),
        SizedBox(
          width: 30,
          child: Text(unit,
              style: Theme.of(context).textTheme.bodySmall),
        ),''',
    '''        const SizedBox(width: 6),
        SizedBox(
          width: 30,
          child: Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Text(unit,
                style: Theme.of(context).textTheme.bodySmall),
          ),
        ),'''
)


with open(r'c:\Users\zalub\OneDrive\Desktop\Astro Planner\Astro-Planner\lib\presentation\screens\equipment\equipment_selection_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
