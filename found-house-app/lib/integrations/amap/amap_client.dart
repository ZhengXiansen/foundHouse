// 高德地图 BFF 客户端。
//
// 职责边界（W3 · E5/E6，技术方案 §4.2/§7）：客户端不直连高德
// WebService；POI 与通勤规划统一通过 BFF 代理，并携带 anon device token
// 仅用于服务端限流。

import 'dart:convert';
import 'dart:io';

import 'amap_models.dart';

abstract class MapApiClient {
  Future<NearbySummaryResponse> fetchNearbySummary({
    required double lat,
    required double lng,
    required List<int> radii,
    required List<String> categories,
  });

  Future<CommuteSummaryResponse> fetchCommute({
    required MapPoint origin,
    required List<MapDestination> destinations,
    required List<String> modes,
    String? city,
  });
}

class MapClientException implements Exception {
  const MapClientException({
    required this.statusCode,
    required this.code,
    required this.message,
  });

  final int statusCode;
  final String code;
  final String message;

  @override
  String toString() {
    return 'MapClientException($statusCode, $code, $message)';
  }
}

class OfflineMapApiClient implements MapApiClient {
  const OfflineMapApiClient();

  static const _exception = MapClientException(
    statusCode: 0,
    code: 'MAP_BFF_NOT_CONFIGURED',
    message: '地图服务未配置，可先离线记录；配置 BFF 地址后可刷新地图快照。',
  );

  @override
  Future<NearbySummaryResponse> fetchNearbySummary({
    required double lat,
    required double lng,
    required List<int> radii,
    required List<String> categories,
  }) async {
    throw _exception;
  }

  @override
  Future<CommuteSummaryResponse> fetchCommute({
    required MapPoint origin,
    required List<MapDestination> destinations,
    required List<String> modes,
    String? city,
  }) async {
    throw _exception;
  }
}

class AMapBffClient implements MapApiClient {
  AMapBffClient({
    required Uri baseUri,
    required String anonDeviceToken,
    HttpClient? httpClient,
  })  : _baseUri = baseUri,
        _anonDeviceToken = anonDeviceToken,
        _httpClient = httpClient ?? HttpClient();

  final Uri _baseUri;
  final String _anonDeviceToken;
  final HttpClient _httpClient;

  @override
  Future<NearbySummaryResponse> fetchNearbySummary({
    required double lat,
    required double lng,
    required List<int> radii,
    required List<String> categories,
  }) async {
    final json = await _postJson(
      '/api/map/nearby-summary',
      {
        'lat': lat,
        'lng': lng,
        'radii': radii,
        'categories': categories,
      },
    );
    return NearbySummaryResponse.fromJson(json);
  }

  @override
  Future<CommuteSummaryResponse> fetchCommute({
    required MapPoint origin,
    required List<MapDestination> destinations,
    required List<String> modes,
    String? city,
  }) async {
    final json = await _postJson(
      '/api/map/commute',
      {
        'origin': origin.toJson(),
        'destinations': [for (final d in destinations) d.toJson()],
        'modes': modes,
        if (city != null && city.trim().isNotEmpty) 'city': city.trim(),
      },
    );
    return CommuteSummaryResponse.fromJson(json);
  }

  void close() {
    _httpClient.close(force: true);
  }

  Future<Map<String, Object?>> _postJson(
    String path,
    Map<String, Object?> body,
  ) async {
    final request = await _httpClient.postUrl(_baseUri.resolve(path));
    request.headers.contentType = ContentType.json;
    request.headers.set(HttpHeaders.acceptHeader, ContentType.json.mimeType);
    request.headers.set('x-anon-device', _anonDeviceToken);
    request.write(jsonEncode(body));

    final response = await request.close();
    final text = await utf8.decoder.bind(response).join();
    final decoded = _decodeObject(text);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw MapClientException(
        statusCode: response.statusCode,
        code: _asString(decoded['code']) ?? 'MAP_REQUEST_FAILED',
        message: _asString(decoded['message']) ?? '地图服务请求失败',
      );
    }
    return decoded;
  }
}

Map<String, Object?> _decodeObject(String text) {
  if (text.trim().isEmpty) return const {};
  final decoded = jsonDecode(text);
  return decoded is Map ? Map<String, Object?>.from(decoded) : const {};
}

String? _asString(Object? value) {
  return value is String ? value : null;
}
