import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:found_house_app/data/local_files/photo_store.dart';
import 'package:found_house_app/data/models/house_models.dart' as domain;
import 'package:found_house_app/integrations/oss/oss_photo_uploader.dart';

void main() {
  test('OfflinePhotoUploader throws stable not-configured error', () async {
    final file = await _tempImageFile();

    await expectLater(
      () => const OfflinePhotoUploader().uploadPhoto(
        ownerType: domain.PhotoOwnerType.house,
        ownerId: 'house-1',
        tag: PhotoTag.room,
        localPath: file.path,
      ),
      throwsA(
        isA<PhotoUploadException>()
            .having((e) => e.statusCode, 'statusCode', 0)
            .having((e) => e.code, 'code', 'OSS_PHOTO_UPLOAD_NOT_CONFIGURED'),
      ),
    );
  });

  test('OssPhotoUploader obtains intent then uploads multipart form to OSS', () async {
    final file = await _tempImageFile();
    late Uri serverBase;
    var signerCalled = false;
    var uploadCalled = false;
    String uploadBody = '';

    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    serverBase = Uri.parse('http://${server.address.host}:${server.port}');
    final sub = server.listen((request) async {
      if (request.uri.path == '/api/photos/upload-intent') {
        signerCalled = true;
        expect(request.method, 'POST');
        final body = jsonDecode(await utf8.decoder.bind(request).join())
            as Map<String, Object?>;
        expect(body['ownerType'], domain.PhotoOwnerType.house);
        expect(body['ownerId'], 'house-1');
        expect(body['tag'], PhotoTag.room);
        expect(body['contentType'], 'image/jpeg');
        expect(body['contentLength'], file.lengthSync());

        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode({
          'method': 'POST',
          'uploadUrl': serverBase.resolve('/oss').toString(),
          'formFields': {
            'key': 'photos/house/house-1/photo-a.jpg',
            'OSSAccessKeyId': 'test-key-id',
            'policy': 'test-policy',
            'Signature': 'test-signature',
            'success_action_status': '201',
            'Content-Type': 'image/jpeg',
          },
          'publicUrl': 'https://cdn.example.com/photos/house/house-1/photo-a.jpg',
          'objectKey': 'photos/house/house-1/photo-a.jpg',
          'expiresAt': '2026-07-08T10:00:00.000Z',
        }),);
        await request.response.close();
        return;
      }

      if (request.uri.path == '/oss') {
        uploadCalled = true;
        expect(request.method, 'POST');
        expect(request.headers.contentType?.mimeType, 'multipart/form-data');
        final bytes = await request.expand((chunk) => chunk).toList();
        uploadBody = utf8.decode(bytes, allowMalformed: true);
        request.response.statusCode = 201;
        await request.response.close();
        return;
      }

      request.response.statusCode = 404;
      await request.response.close();
    });
    addTearDown(sub.cancel);

    final uploader = OssPhotoUploader(
      signerUri: serverBase.resolve('/api/photos/upload-intent'),
      httpClient: HttpClient(),
    );
    addTearDown(uploader.close);

    final result = await uploader.uploadPhoto(
      ownerType: domain.PhotoOwnerType.house,
      ownerId: 'house-1',
      tag: PhotoTag.room,
      localPath: file.path,
    );

    expect(signerCalled, isTrue);
    expect(uploadCalled, isTrue);
    expect(uploadBody, contains('name="key"'));
    expect(uploadBody, contains('photos/house/house-1/photo-a.jpg'));
    expect(uploadBody, contains('name="file"'));
    expect(result.storageProvider, domain.PhotoStorageProvider.oss);
    expect(result.remoteUrl, 'https://cdn.example.com/photos/house/house-1/photo-a.jpg');
    expect(result.objectKey, 'photos/house/house-1/photo-a.jpg');
  });
}

Future<File> _tempImageFile() async {
  final dir = await Directory.systemTemp.createTemp('found_house_oss_test_');
  final file = File('${dir.path}${Platform.pathSeparator}room.jpg');
  await file.writeAsBytes(<int>[0xFF, 0xD8, 0xFF, 0xD9]);
  return file;
}
