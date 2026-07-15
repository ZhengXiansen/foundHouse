import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:found_house_app/data/crypto/field_cipher.dart';
import 'package:found_house_app/data/db/app_database.dart';
import 'package:found_house_app/data/local_files/photo_store.dart';
import 'package:found_house_app/data/repositories/house_repository.dart';
import 'package:found_house_app/data/repositories/map_repository.dart';
import 'package:found_house_app/integrations/amap/amap_client.dart';
import 'package:found_house_app/integrations/amap/amap_models.dart';

void main() {
  late AppDatabase db;
  late HouseRepository houseRepo;
  late _FakeMapApiClient client;
  late MapRepository mapRepo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.customStatement('PRAGMA foreign_keys = ON');
    houseRepo = HouseRepository(
      db: db,
      cipher: const NoopFieldCipher(),
      photoStore: PhotoStore(baseDirOverride: Directory.systemTemp),
    );
    client = _FakeMapApiClient();
    mapRepo = MapRepository(
      client: client,
      houses: houseRepo,
      now: () => DateTime.fromMillisecondsSinceEpoch(1760000000000),
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('refreshHouseSnapshot fetches BFF map data and persists MapSnapshot',
      () async {
    final houseId = await houseRepo.create(
      title: '科技园单间',
      latitude: 22.5431,
      longitude: 114.0579,
    );
    client.nearby = const NearbySummaryResponse(
      provider: 'amap',
      fetchedAt: '2026-07-03T00:00:00.000Z',
      summary: {
        '300': {'metro': 1},
      },
      topPois: [
        NearbyPoi(name: '科技园站', category: 'metro', distanceMeters: 260),
      ],
    );
    client.commute = const CommuteSummaryResponse(
      provider: 'amap',
      results: [
        CommuteResult(
          destinationId: 'work',
          mode: 'transit',
          durationMinutes: 36,
          walkingMeters: 540,
          transferCount: 1,
          summary: '步行 7 分钟 + 公交/地铁 1 次换乘',
        ),
      ],
    );

    await mapRepo.refreshHouseSnapshot(
      houseId,
      destinations: const [
        MapDestination(id: 'work', lat: 22.5333, lng: 114.0666),
      ],
      modes: const ['transit'],
      city: '深圳',
    );

    final house = await houseRepo.getById(houseId);
    expect(house?.mapSnapshot, isNotNull);
    expect(house!.mapSnapshot!.provider, 'amap');
    expect(house.mapSnapshot!.fetchedAt, 1760000000000);
    expect(jsonDecode(house.mapSnapshot!.poiSummaryJson!), {
      'provider': 'amap',
      'fetchedAt': '2026-07-03T00:00:00.000Z',
      'summary': {
        '300': {'metro': 1},
      },
      'topPois': [
        {'name': '科技园站', 'category': 'metro', 'distanceMeters': 260},
      ],
    });
    expect(
      jsonDecode(house.mapSnapshot!.commuteJson!)['results'].single['mode'],
      'transit',
    );
    expect(client.nearbyRequests.single.lat, 22.5431);
    expect(client.commuteRequests.single.destinations.single.id, 'work');
  });

  test('refreshHouseSnapshot keeps local record when house has no coordinates',
      () async {
    final houseId = await houseRepo.create(title: '无坐标房源');

    await expectLater(
      () => mapRepo.refreshHouseSnapshot(houseId),
      throwsA(isA<MapSnapshotRefreshException>()),
    );

    expect(client.nearbyRequests, isEmpty);
    expect((await houseRepo.getById(houseId))?.mapSnapshot, isNull);
  });
}

class _FakeMapApiClient implements MapApiClient {
  NearbySummaryResponse? nearby;
  CommuteSummaryResponse? commute;
  final nearbyRequests = <_NearbyRequest>[];
  final commuteRequests = <_CommuteRequest>[];

  @override
  Future<NearbySummaryResponse> fetchNearbySummary({
    required double lat,
    required double lng,
    required List<int> radii,
    required List<String> categories,
  }) async {
    nearbyRequests.add(
      _NearbyRequest(lat, lng, radii, categories),
    );
    return nearby!;
  }

  @override
  Future<CommuteSummaryResponse> fetchCommute({
    required MapPoint origin,
    required List<MapDestination> destinations,
    required List<String> modes,
    String? city,
  }) async {
    commuteRequests.add(
      _CommuteRequest(origin, destinations, modes, city),
    );
    return commute ?? const CommuteSummaryResponse(provider: 'amap');
  }
}

class _NearbyRequest {
  const _NearbyRequest(this.lat, this.lng, this.radii, this.categories);

  final double lat;
  final double lng;
  final List<int> radii;
  final List<String> categories;
}

class _CommuteRequest {
  const _CommuteRequest(this.origin, this.destinations, this.modes, this.city);

  final MapPoint origin;
  final List<MapDestination> destinations;
  final List<String> modes;
  final String? city;
}
