import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:found_house_app/integrations/amap/amap_client.dart';
import 'package:found_house_app/integrations/amap/amap_models.dart';

void main() {
  late HttpServer server;
  late List<_RecordedRequest> requests;

  setUp(() async {
    requests = [];
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  });

  tearDown(() async {
    await server.close(force: true);
  });

  Uri serverUri() => Uri.parse('http://${server.address.host}:${server.port}');

  test('fetchNearbySummary posts BFF body with anon device header', () async {
    server.listen((request) async {
      final body = await utf8.decoder.bind(request).join();
      requests.add(_RecordedRequest(request, body));
      request.response.headers.contentType = ContentType.json;
      request.response.write(
        jsonEncode({
          'provider': 'amap',
          'fetchedAt': '2026-07-03T00:00:00.000Z',
          'summary': {
            '300': {'metro': 1},
            '800': {'metro': 1, 'bus': 3},
          },
          'topPois': [
            {'name': '科技园站', 'category': 'metro', 'distanceMeters': 260},
          ],
        }),
      );
      await request.response.close();
    });

    final client = AMapBffClient(
      baseUri: serverUri(),
      anonDeviceToken: 'device-123456',
    );
    addTearDown(client.close);

    final result = await client.fetchNearbySummary(
      lat: 22.5431,
      lng: 114.0579,
      radii: const [300, 800],
      categories: const ['metro', 'bus'],
    );

    expect(requests.single.method, 'POST');
    expect(requests.single.path, '/api/map/nearby-summary');
    expect(requests.single.anonDevice, 'device-123456');
    expect(jsonDecode(requests.single.body), {
      'lat': 22.5431,
      'lng': 114.0579,
      'radii': [300, 800],
      'categories': ['metro', 'bus'],
    });
    expect(result.provider, 'amap');
    expect(result.summary['300']?['metro'], 1);
    expect(result.topPois.single.name, '科技园站');
  });

  test('fetchCommute posts origin destinations modes and parses results',
      () async {
    server.listen((request) async {
      final body = await utf8.decoder.bind(request).join();
      requests.add(_RecordedRequest(request, body));
      request.response.headers.contentType = ContentType.json;
      request.response.write(
        jsonEncode({
          'provider': 'amap',
          'results': [
            {
              'destinationId': 'work',
              'mode': 'transit',
              'durationMinutes': 36,
              'walkingMeters': 540,
              'transferCount': 1,
              'summary': '步行 7 分钟 + 公交/地铁 1 次换乘',
            },
          ],
        }),
      );
      await request.response.close();
    });

    final client = AMapBffClient(
      baseUri: serverUri(),
      anonDeviceToken: 'device-abcdef',
    );
    addTearDown(client.close);

    final result = await client.fetchCommute(
      origin: const MapPoint(lat: 22.5431, lng: 114.0579),
      destinations: const [
        MapDestination(id: 'work', lat: 22.5333, lng: 114.0666),
      ],
      modes: const ['transit', 'driving'],
      city: '深圳',
    );

    expect(requests.single.method, 'POST');
    expect(requests.single.path, '/api/map/commute');
    expect(requests.single.anonDevice, 'device-abcdef');
    expect(jsonDecode(requests.single.body), {
      'origin': {'lat': 22.5431, 'lng': 114.0579},
      'destinations': [
        {'id': 'work', 'lat': 22.5333, 'lng': 114.0666},
      ],
      'modes': ['transit', 'driving'],
      'city': '深圳',
    });
    expect(result.provider, 'amap');
    expect(result.results.single.destinationId, 'work');
    expect(result.results.single.durationMinutes, 36);
  });

  test('non-2xx BFF response throws MapClientException with code', () async {
    server.listen((request) async {
      await utf8.decoder.bind(request).join();
      request.response.statusCode = HttpStatus.tooManyRequests;
      request.response.headers.contentType = ContentType.json;
      request.response.write(
        jsonEncode({
          'code': 'MAP_RATE_LIMITED',
          'message': '请求过于频繁，请稍后再试。',
        }),
      );
      await request.response.close();
    });

    final client = AMapBffClient(
      baseUri: serverUri(),
      anonDeviceToken: 'device-rate',
    );
    addTearDown(client.close);

    expect(
      () => client.fetchNearbySummary(
        lat: 22.5431,
        lng: 114.0579,
        radii: const [300],
        categories: const ['metro'],
      ),
      throwsA(
        isA<MapClientException>()
            .having((e) => e.statusCode, 'statusCode', 429)
            .having((e) => e.code, 'code', 'MAP_RATE_LIMITED'),
      ),
    );
  });
}

class _RecordedRequest {
  _RecordedRequest(HttpRequest request, this.body)
      : method = request.method,
        path = request.uri.path,
        anonDevice = request.headers.value('x-anon-device');

  final String method;
  final String path;
  final String? anonDevice;
  final String body;
}
