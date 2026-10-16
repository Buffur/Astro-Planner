// S10.2: the driver for integration_test/perf_scenarios_test.dart. It writes
// the scenarios' frame summaries and timings to
// build/integration_response_data.json (see that file's header).

import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver();
