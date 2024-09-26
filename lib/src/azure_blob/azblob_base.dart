library az_blob;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart' as crypto;
import 'package:http_parser/http_parser.dart';

/// Blob type
enum BlobType {
  blockBlob('BlockBlob'),
  appendBlob('AppendBlob'),
  ;

  const BlobType(this.displayName);

  final String displayName;
}

/// Azure Storage Exception
class AzureStorageException implements Exception {
  final String message;
  final int statusCode;
  final Map<String, String> headers;

  AzureStorageException(this.message, this.statusCode, this.headers);
}

/// Azure Storage Client
class AzureStorage {
  late Map<String, String> config;
  late Uint8List accountKey;

  static const String defaultEndpointsProtocol = 'DefaultEndpointsProtocol';
  static const String endpointSuffix = 'EndpointSuffix';
  static const String accountName = 'AccountName';

  // ignore: non_constant_identifier_names
  static const String accountKeyString = 'AccountKey';

  /// Initialize with connection string.
  AzureStorage.parse(String connectionString) {
    try {
      var m = <String, String>{};
      var items = connectionString.split(';');
      for (var item in items) {
        var i = item.indexOf('=');
        var key = item.substring(0, i);
        var val = item.substring(i + 1);
        m[key] = val;
      }
      config = m;
      accountKey = base64Decode(config[accountKeyString]!);
    } catch (e) {
      throw Exception('Parse error.');
    }
  }

  @override
  String toString() {
    return config.toString();
  }

// keep '/' for azure path do not replace with Platform.pathSeparator
  Uri uri({String path = '/', Map<String, String>? queryParameters}) {
    var scheme = config[defaultEndpointsProtocol] ?? 'https';
    var suffix = config[endpointSuffix] ?? 'core.windows.net';
    var name = config[accountName];
    return Uri(
        scheme: scheme,
        host: '$name.blob.$suffix',
        path: path,
        queryParameters: queryParameters);
  }

  String _canonicalHeaders(Map<String, String> headers) {
    var keys = headers.keys
        .where((i) => i.startsWith('x-ms-'))
        .map((i) => '$i:${headers[i]}\n')
        .toList();
    keys.sort();
    return keys.join();
  }

  String _canonicalResources(Map<String, String> items) {
    if (items.isEmpty) {
      return '';
    }
    var keys = items.keys.toList();
    keys.sort();
    return keys.map((i) => '\n$i:${items[i]}').join();
  }

  void sign(http.Request request) {
    request.headers['x-ms-date'] = formatHttpDate(DateTime.now());
    request.headers['x-ms-version'] = '2019-12-12';
    var ce = request.headers['Content-Encoding'] ?? '';
    var cl = request.headers['Content-Language'] ?? '';
    var cz = request.contentLength == 0 ? '' : '${request.contentLength}';
    var cm = request.headers['Content-MD5'] ?? '';
    var ct = request.headers['Content-Type'] ?? '';
    var dt = request.headers['Date'] ?? '';
    var ims = request.headers['If-Modified-Since'] ?? '';
    var imt = request.headers['If-Match'] ?? '';
    var inm = request.headers['If-None-Match'] ?? '';
    var ius = request.headers['If-Unmodified-Since'] ?? '';
    var ran = request.headers['Range'] ?? '';
    var chs = _canonicalHeaders(request.headers);
    var crs = _canonicalResources(request.url.queryParameters);
    var name = config[accountName];
    var path = request.url.path;
    var sig =
        '${request.method}\n$ce\n$cl\n$cz\n$cm\n$ct\n$dt\n$ims\n$imt\n$inm\n$ius\n$ran\n$chs/$name$path$crs';
    var mac = crypto.Hmac(crypto.sha256, accountKey);
    var digest = base64Encode(mac.convert(utf8.encode(sig)).bytes);
    var auth = 'SharedKey $name:$digest';
    request.headers['Authorization'] = auth;
    //print(sig);
  }

  List<String?> _splitPathSegment(String path) {
    final twoStupidString = <String?>[];
    final p = path.startsWith('/') ? path.substring(1) : path;
    final i = p.indexOf('/');
    if (i < 0 || p.length < i + 2) {
      twoStupidString.add(p);
      twoStupidString.add(null);
    } else {
      twoStupidString.add(p.substring(0, i));
      twoStupidString.add(p.substring(i + 1));
    }
    return twoStupidString;
  }

  Stream<T> onDone<T>(Stream<T> stream, void Function() onDone,
          void Function() onConnectionClosed) =>
      stream.transform(StreamTransformer.fromHandlers(handleDone: (sink) {
        sink.close();
        onDone();
      }, handleError: (error, stackTrace, sink) {
        if (error is http.ClientException) {
          if (error.message == 'Connection closed while receiving data') {
            sink.addError(error);
            // throw http.ClientException(
            //     'Connection closed while receiving data');
          }
        }
      }));

  /// List Blobs. (Raw API)
  ///
  /// You can use `await response.stream.bytesToString();` to get blob listing as XML format.
  Future<http.StreamedResponse> listBlobsRaw(
      String path, http.Client client) async {
    final stuff = _splitPathSegment(path);
    var request = http.Request(
        'GET',
        uri(path: stuff.first ?? '', queryParameters: {
          "restype": "container",
          "comp": "list",
          if (stuff.last != null) "prefix": stuff.last ?? '',
        }));
    sign(request);
    return await _sendRequest(request, client);
  }

  Future<http.StreamedResponse> _sendRequest(
      http.Request request, http.Client client) async {
    // copy paste from http package to use a single that can be closed
    http.StreamedResponse response =
        http.StreamedResponse(const http.ByteStream(Stream.empty()), 400);
    try {
      response = await client.send(request);
    } on http.ClientException catch (e) {
      if (e.message.contains('Connection closed while') == false) {
        debugPrint(e.message);
      }
    }
    final stream = onDone(response.stream, client.close, () {});
    return http.StreamedResponse(http.ByteStream(stream), response.statusCode,
        contentLength: response.contentLength,
        request: response.request,
        headers: response.headers,
        isRedirect: response.isRedirect,
        persistentConnection: response.persistentConnection,
        reasonPhrase: response.reasonPhrase);
  }

  /// Get Blob.
  Future<http.StreamedResponse> getBlob(String path, http.Client client) async {
    var request = http.Request('GET', uri(path: path));
    sign(request);
    return await _sendRequest(request, client);
  }

  /// Delete Blob
  Future<http.StreamedResponse> deleteBlob(String path) async {
    var request = http.Request('DELETE', uri(path: path));
    sign(request);
    return request.send();
  }

  String _signedExpiry(DateTime? expiry) {
    var str = (expiry ?? DateTime.now().add(const Duration(hours: 1)))
        .toUtc()
        .toIso8601String();
    return '${str.substring(0, str.indexOf('.'))}Z';
  }

  /// Get Blob Link.
  Future<Uri> getBlobLink(String path, {DateTime? expiry}) async {
    var signedPermissions = 'r';
    var signedStart = '';
    var signedExpiry = _signedExpiry(expiry);
    var signedIdentifier = '';
    var signedVersion = '2012-02-12';
    var name = config[accountName];
    var canonicalizedResource = '/$name$path';
    var str = '$signedPermissions\n'
        '$signedStart\n'
        '$signedExpiry\n'
        '$canonicalizedResource\n'
        '$signedIdentifier\n'
        '$signedVersion';
    var mac = crypto.Hmac(crypto.sha256, accountKey);
    var sig = base64Encode(mac.convert(utf8.encode(str)).bytes);
    return uri(path: path, queryParameters: {
      'sr': 'b',
      'sp': signedPermissions,
      'se': signedExpiry,
      'sv': signedVersion,
      'spr': 'https',
      'sig': sig,
    });
  }

  /// Put Blob.
  ///
  /// `body` and `bodyBytes` are exclusive and mandatory.
  Future<bool> putBlob(String path, http.Client client,
      {String? body,
      Uint8List? bodyBytes,
      String? contentType,
      BlobType type = BlobType.blockBlob,
      Map<String, String>? headers}) async {
    var request = http.Request('PUT', uri(path: path));
    request.headers['x-ms-blob-type'] = type.displayName;
    if (headers != null) {
      headers.forEach((key, value) {
        request.headers['x-ms-meta-$key'] = value;
      });
    }
    if (contentType != null) request.headers['content-type'] = contentType;
    if (type == BlobType.blockBlob) {
      if (bodyBytes != null) {
        request.bodyBytes = bodyBytes;
      } else if (body != null) {
        request.body = body;
      }
    } else {
      request.body = '';
    }
    sign(request);

    try {
      var res = await client.send(request);
      if (res.statusCode == 201) {
        await res.stream.drain();
        if (type == BlobType.appendBlob &&
            (body != null || bodyBytes != null)) {
          await appendBlock(path, body: body, bodyBytes: bodyBytes);
        }
        return true;
      }

      var message = await res.stream.bytesToString();
      throw AzureStorageException(message, res.statusCode, res.headers);
    } on http.ClientException catch (e) {
      if (e.message.contains('Connection closed while') == false) {
        debugPrint(e.message);
      }
      return false;
    }
  }

  /// Append block to blob.
  Future<bool> appendBlock(String path,
      {String? body, Uint8List? bodyBytes}) async {
    var request = http.Request(
        'PUT', uri(path: path, queryParameters: {'comp': 'appendblock'}));
    if (bodyBytes != null) {
      request.bodyBytes = bodyBytes;
    } else if (body != null) {
      request.body = body;
    }
    sign(request);
    try {
      var res = await request.send();
      if (res.statusCode == 201) {
        await res.stream.drain();
        return true;
      }
      var message = await res.stream.bytesToString();
      throw AzureStorageException(message, res.statusCode, res.headers);
    } on http.ClientException catch (e) {
      if (e.message.contains('Connection closed while') == false) {
        debugPrint(e.message);
      }
      return false;
    }
  }
}
