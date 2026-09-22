import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/site_time_context.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CalendarDate', () {
    test('rejects dates that do not exist', () {
      expect(() => CalendarDate(2026, 2, 29), throwsArgumentError);
      expect(() => CalendarDate(2026, 13, 1), throwsArgumentError);
      expect(CalendarDate(2028, 2, 29).day, 29);
    });

    test('ISO round trip', () {
      final d = CalendarDate(2026, 9, 21);
      expect(d.toIso8601String(), '2026-09-21');
      expect(CalendarDate.parse('2026-09-21'), d);
      expect(() => CalendarDate.parse('2026-9-21'), throwsFormatException);
      expect(() => CalendarDate.parse('2026-02-30'), throwsArgumentError);
    });

    test('addDays crosses month and year boundaries', () {
      expect(CalendarDate(2026, 12, 31).addDays(1), CalendarDate(2027, 1, 1));
      expect(CalendarDate(2026, 3, 1).addDays(-1), CalendarDate(2026, 2, 28));
    });

    test('ordering and equality', () {
      final a = CalendarDate(2026, 9, 21);
      final b = CalendarDate(2026, 9, 22);
      expect(a.compareTo(b), lessThan(0));
      expect(a, CalendarDate(2026, 9, 21));
      expect(a.hashCode, CalendarDate(2026, 9, 21).hashCode);
    });
  });

  group('SiteTimeContext ids', () {
    test('fixed offsets', () {
      expect(const FixedOffsetTimeContext(Duration(hours: 14)).id, 'UTC+14:00');
      expect(
        const FixedOffsetTimeContext(Duration(hours: -9, minutes: -30)).id,
        'UTC-09:30',
      );
      expect(const FixedOffsetTimeContext(Duration.zero).id, 'UTC+00:00');
    });

    test('mean solar', () {
      final ctx = MeanSolarTimeContext(-122.4194);
      expect(ctx.id, 'solar');
      expect(
        ctx.offsetAt(DateTime.utc(2026)),
        const Duration(milliseconds: -29380656),
      );
    });
  });
}
