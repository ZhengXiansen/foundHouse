// 地图仓库。
//
// 职责边界（W3 · E6，技术方案 §7/§8）：调用后端 BFF 地图代理
// （/api/map/nearby-summary、/api/map/commute）→ 将结果落本地 MapSnapshot →
// 列表与评分从本地快照读取（不实时依赖网络）。

import 'dart:convert';

import '../../integrations/amap/amap_client.dart';
import '../../integrations/amap/amap_models.dart';
import '../models/house_models.dart' as domain;
import 'house_repository.dart';

class MapSnapshotRefreshException implements Exception {
  const MapSnapshotRefreshException(this.message);

  final String message;

  @override
  String toString() => 'MapSnapshotRefreshException($message)';
}

class MapRepository {
  MapRepository({
    required MapApiClient client,
    required HouseRepository houses,
    DateTime Function()? now,
  })  : _client = client,
        _houses = houses,
        _now = now ?? DateTime.now;

  static const List<int> defaultRadii = [300, 800, 1500];
  static const List<String> defaultCategories = [
    'metro',
    'bus',
    'supermarket',
    'market',
    'pharmacy',
    'hospital',
    'restaurant',
    'police',
  ];

  final MapApiClient _client;
  final HouseRepository _houses;
  final DateTime Function() _now;

  Future<void> refreshHouseSnapshot(
    String houseId, {
    List<MapDestination> destinations = const [],
    List<String> modes = const ['transit'],
    String? city,
  }) async {
    final house = await _houses.getById(houseId);
    if (house == null) {
      throw const MapSnapshotRefreshException('房源不存在');
    }

    final lat = house.latitude;
    final lng = house.longitude;
    if (lat == null || lng == null) {
      throw const MapSnapshotRefreshException('房源缺少坐标');
    }

    final nearby = await _client.fetchNearbySummary(
      lat: lat,
      lng: lng,
      radii: defaultRadii,
      categories: defaultCategories,
    );
    final commute = destinations.isEmpty
        ? null
        : await _client.fetchCommute(
            origin: MapPoint(lat: lat, lng: lng),
            destinations: destinations,
            modes: modes.isEmpty ? const ['transit'] : modes,
            city: city,
          );

    await _houses.updateMapSnapshot(
      houseId,
      domain.MapSnapshot(
        provider: nearby.provider,
        poiSummaryJson: jsonEncode(nearby.toJson()),
        commuteJson: commute == null ? null : jsonEncode(commute.toJson()),
        fetchedAt: _now().millisecondsSinceEpoch,
      ),
    );
  }
}
