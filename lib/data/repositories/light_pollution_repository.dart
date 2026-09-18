
import 'package:http/http.dart' as http;

class LightPollutionRepository {
  Future<int?> fetchBortleClass(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse('https://clearoutside.com/forecast/\${lat.toStringAsFixed(4)}/\${lon.toStringAsFixed(4)}'),
        headers: {'User-Agent': 'AstroPlan/1.0'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        // Regex to find: "Class 5</strong> Bortle"
        final regex = RegExp(r'Class (\d+)<\/strong>\s*Bortle', caseSensitive: false);
        final match = regex.firstMatch(response.body);
        if (match != null) {
          return int.tryParse(match.group(1)!);
        }
      }
    } catch (e) {
      // Network not available, timeout, or parsing failed
      return null;
    }
    return null;
  }
}
