// 高德地图数据模型。
//
// 职责边界（W3，技术方案 §7.2）：定义地图相关值对象——BFF
// /api/map/nearby-summary 与 /api/map/commute 的请求/响应模型
// （POI 分半径统计、通勤时长/步行距离/换乘次数/摘要）。仅数据结构，
// 不含网络调用（那是 MapRepository / AMapBffClient）。

class MapPoint {
  const MapPoint({required this.lat, required this.lng});

  final double lat;
  final double lng;

  Map<String, Object> toJson() => {'lat': lat, 'lng': lng};

  factory MapPoint.fromJson(Map<String, Object?> json) {
    return MapPoint(
      lat: _asDouble(json['lat']) ?? 0,
      lng: _asDouble(json['lng']) ?? 0,
    );
  }
}

class MapDestination {
  const MapDestination({
    required this.id,
    required this.lat,
    required this.lng,
    this.label,
  });

  final String id;
  final double lat;
  final double lng;
  final String? label;

  Map<String, Object> toJson() {
    return {
      'id': id,
      'lat': lat,
      'lng': lng,
      if (label != null && label!.isNotEmpty) 'label': label!,
    };
  }

  factory MapDestination.fromJson(Map<String, Object?> json) {
    return MapDestination(
      id: _asString(json['id']) ?? '',
      lat: _asDouble(json['lat']) ?? 0,
      lng: _asDouble(json['lng']) ?? 0,
      label: _asString(json['label']),
    );
  }
}

class NearbyPoi {
  const NearbyPoi({
    required this.name,
    required this.category,
    required this.distanceMeters,
  });

  final String name;
  final String category;
  final int distanceMeters;

  Map<String, Object> toJson() {
    return {
      'name': name,
      'category': category,
      'distanceMeters': distanceMeters,
    };
  }

  factory NearbyPoi.fromJson(Map<String, Object?> json) {
    return NearbyPoi(
      name: _asString(json['name']) ?? '',
      category: _asString(json['category']) ?? '',
      distanceMeters: _asInt(json['distanceMeters']) ?? 0,
    );
  }
}

class NearbySummaryResponse {
  const NearbySummaryResponse({
    required this.provider,
    this.fetchedAt,
    this.summary = const {},
    this.topPois = const [],
  });

  final String provider;
  final String? fetchedAt;
  final Map<String, Map<String, int>> summary;
  final List<NearbyPoi> topPois;

  Map<String, Object?> toJson() {
    return {
      'provider': provider,
      if (fetchedAt != null) 'fetchedAt': fetchedAt,
      'summary': summary,
      'topPois': [for (final poi in topPois) poi.toJson()],
    };
  }

  factory NearbySummaryResponse.fromJson(Map<String, Object?> json) {
    return NearbySummaryResponse(
      provider: _asString(json['provider']) ?? 'amap',
      fetchedAt: _asString(json['fetchedAt']),
      summary: _summaryFromJson(json['summary']),
      topPois: [
        for (final item in _asList(json['topPois']))
          if (item is Map) NearbyPoi.fromJson(Map<String, Object?>.from(item)),
      ],
    );
  }
}

class CommuteResult {
  const CommuteResult({
    required this.destinationId,
    required this.mode,
    required this.durationMinutes,
    this.walkingMeters,
    this.transferCount,
    this.summary,
  });

  final String destinationId;
  final String mode;
  final int durationMinutes;
  final int? walkingMeters;
  final int? transferCount;
  final String? summary;

  Map<String, Object?> toJson() {
    return {
      'destinationId': destinationId,
      'mode': mode,
      'durationMinutes': durationMinutes,
      if (walkingMeters != null) 'walkingMeters': walkingMeters,
      if (transferCount != null) 'transferCount': transferCount,
      if (summary != null) 'summary': summary,
    };
  }

  factory CommuteResult.fromJson(Map<String, Object?> json) {
    return CommuteResult(
      destinationId: _asString(json['destinationId']) ?? '',
      mode: _asString(json['mode']) ?? 'transit',
      durationMinutes: _asInt(json['durationMinutes']) ?? 0,
      walkingMeters: _asInt(json['walkingMeters']),
      transferCount: _asInt(json['transferCount']),
      summary: _asString(json['summary']),
    );
  }
}

class CommuteSummaryResponse {
  const CommuteSummaryResponse({
    required this.provider,
    this.results = const [],
  });

  final String provider;
  final List<CommuteResult> results;

  Map<String, Object?> toJson() {
    return {
      'provider': provider,
      'results': [for (final result in results) result.toJson()],
    };
  }

  factory CommuteSummaryResponse.fromJson(Map<String, Object?> json) {
    return CommuteSummaryResponse(
      provider: _asString(json['provider']) ?? 'amap',
      results: [
        for (final item in _asList(json['results']))
          if (item is Map)
            CommuteResult.fromJson(Map<String, Object?>.from(item)),
      ],
    );
  }
}

Map<String, Map<String, int>> _summaryFromJson(Object? raw) {
  if (raw is! Map) return const {};
  final result = <String, Map<String, int>>{};
  for (final entry in raw.entries) {
    final value = entry.value;
    if (value is! Map) continue;
    result[entry.key.toString()] = {
      for (final category in value.entries)
        category.key.toString(): _asInt(category.value) ?? 0,
    };
  }
  return result;
}

List<Object?> _asList(Object? value) {
  return value is List ? value : const [];
}

String? _asString(Object? value) {
  return value is String ? value : null;
}

int? _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.round();
  if (value is String) return int.tryParse(value);
  return null;
}

double? _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
