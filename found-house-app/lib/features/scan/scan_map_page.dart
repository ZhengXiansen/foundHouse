import 'village_home_page.dart';

/// Compatibility alias for old imports.
///
/// The former map-based scan workspace has been retired; the scan/home entry now
/// uses the manual village workflow implemented by [VillageHomePage].
@Deprecated('Use VillageHomePage for the manual village workflow.')
class ScanMapPage extends VillageHomePage {
  const ScanMapPage({super.key});
}
