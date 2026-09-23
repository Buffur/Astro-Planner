import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:go_router/go_router.dart';

/// Every full path in [AppRouter.router], shell branches included (TASK
/// 12.2): nested `GoRoute` paths are joined to their parents'.
Set<String> allRoutePaths() {
  final out = <String>{};
  void walk(List<RouteBase> routes, String parent) {
    for (final r in routes) {
      if (r is GoRoute) {
        final path = r.path.startsWith('/')
            ? r.path
            : '${parent == '/' ? '' : parent}/${r.path}';
        out.add(path);
        walk(r.routes, path);
      } else {
        walk(r.routes, parent);
      }
    }
  }

  walk(AppRouter.router.configuration.routes, '/');
  return out;
}
