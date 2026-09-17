import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../domain/models/image_metadata.dart';
import '../../../domain/services/metadata_extractor.dart';
import '../../widgets/planner_summary_card.dart';

class MetadataImportScreen extends StatefulWidget {
  const MetadataImportScreen({super.key});

  @override
  State<MetadataImportScreen> createState() => _MetadataImportScreenState();
}

class _MetadataImportScreenState extends State<MetadataImportScreen> {
  File? _selectedImage;
  ImageMetadata? _metadata;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _isLoading = true;
        _selectedImage = File(pickedFile.path);
      });

      final metadata = await MetadataExtractor.extractFromFile(_selectedImage!);

      setState(() {
        _metadata = metadata;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metadata Import'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo_library),
              label: const Text('Select Image from Gallery'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_selectedImage != null && _metadata == null)
              const Center(child: Text('No EXIF metadata found in this image.'))
            else if (_metadata != null)
              Expanded(
                child: ListView(
                  children: [
                    PlannerSummaryCard(
                      title: 'Camera Information',
                      data: {
                        'Make': _metadata!.cameraMake ?? 'Unknown',
                        'Model': _metadata!.cameraModel ?? 'Unknown',
                        'Date/Time': _metadata!.dateTimeOriginal ?? 'Unknown',
                      },
                    ),
                    PlannerSummaryCard(
                      title: 'Shooting Parameters',
                      data: {
                        'Exposure Time': _metadata!.exposureTime != null ? '${_metadata!.exposureTime} s' : 'Unknown',
                        'Focal Length': _metadata!.focalLength != null ? '${_metadata!.focalLength} mm' : 'Unknown',
                        'Aperture': _metadata!.aperture != null ? 'f/${_metadata!.aperture}' : 'Unknown',
                        'ISO': _metadata!.iso ?? 'Unknown',
                      },
                    ),
                    if (_metadata!.rawTags.isNotEmpty)
                      Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ExpansionTile(
                          title: const Text('Raw EXIF Data', style: TextStyle(fontWeight: FontWeight.bold)),
                          children: _metadata!.rawTags.entries
                              .map((e) => ListTile(
                                    title: Text(e.key, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    subtitle: Text(e.value, style: const TextStyle(fontSize: 12)),
                                  ))
                              .toList(),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
