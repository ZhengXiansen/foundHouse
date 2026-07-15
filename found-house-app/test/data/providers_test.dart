import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:found_house_app/data/providers.dart';
import 'package:found_house_app/data/repositories/village_repository.dart';
import 'package:found_house_app/integrations/amap/amap_client.dart';

void main() {
  test('villageRepositoryProvider wires VillageRepository', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(villageRepositoryProvider), isA<VillageRepository>());
  });

  test('mapApiClientProvider defaults to offline failure when BFF is not set',
      () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final client = container.read(mapApiClientProvider);

    expect(client, isNot(isA<AMapBffClient>()));
    await expectLater(
      () => client.fetchNearbySummary(
        lat: 22.5431,
        lng: 114.0579,
        radii: const [300],
        categories: const ['metro'],
      ),
      throwsA(
        isA<MapClientException>()
            .having((e) => e.statusCode, 'statusCode', 0)
            .having((e) => e.code, 'code', 'MAP_BFF_NOT_CONFIGURED'),
      ),
    );
  });
}
