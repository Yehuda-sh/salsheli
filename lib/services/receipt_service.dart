// lib/services/receipt_service.dart
//
// שירות קבלות עם http.Client, הגדרות ניתנות להזרקה,
// טיפול שגיאות עקבי, וניסיונות חוזרים עם backoff.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../models/receipt.dart';

/// חריג שירות הקבלות
class ReceiptServiceException implements Exception {
  final String message;
  final int? statusCode;
  final String? responseBody;

  ReceiptServiceException(this.message, {this.statusCode, this.responseBody});

  @override
  String toString() =>
      'ReceiptServiceException($message, code: $statusCode, body: $responseBody)';
}

/// תצורה לשירות
class ReceiptServiceConfig {
  final String baseUrl; // ללא / בסוף (e.g. https://api.example.com)
  final Duration requestTimeout;
  final int maxRetries;

  const ReceiptServiceConfig({
    required this.baseUrl,
    this.requestTimeout = const Duration(seconds: 30),
    this.maxRetries = 2, // נסיונות חוזרים מעבר לניסיון הראשון
  });

  ReceiptServiceConfig copyWith({
    String? baseUrl,
    Duration? requestTimeout,
    int? maxRetries,
  }) {
    return ReceiptServiceConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      requestTimeout: requestTimeout ?? this.requestTimeout,
      maxRetries: maxRetries ?? this.maxRetries,
    );
  }
}

class ReceiptService {
  final http.Client _client;
  ReceiptServiceConfig _config;

  /// אופציונלי: אסימון אימות (Bearer) לבקשות
  String? _authToken;

  ReceiptService({http.Client? client, ReceiptServiceConfig? config})
    : _client = client ?? http.Client(),
      _config =
          config ??
          const ReceiptServiceConfig(baseUrl: 'https://api.example.com');

  /// עדכון דינמי של baseUrl / טיימאאוטים / רטרייז
  void updateConfig(ReceiptServiceConfig config) {
    _config = config;
  }

  /// קביעת אסימון אימות
  void setAuthToken(String? token) {
    _authToken = token;
  }

  Map<String, String> _jsonHeaders() {
    final h = <String, String>{'Content-Type': 'application/json'};
    if (_authToken != null && _authToken!.isNotEmpty) {
      h['Authorization'] = 'Bearer $_authToken';
    }
    return h;
  }

  Map<String, String> _authOnlyHeaders() {
    final h = <String, String>{};
    if (_authToken != null && _authToken!.isNotEmpty) {
      h['Authorization'] = 'Bearer $_authToken';
    }
    return h;
  }

  Uri _u(String path) {
    // תומך גם ב-path שמתחיל ב'/' וגם בלי
    final normalized = path.startsWith('/') ? path : '/$path';
    return Uri.parse('${_config.baseUrl}$normalized');
  }

  // ---------------------------------------------------------------------------
  // API
  // ---------------------------------------------------------------------------

  /// מעלה תמונה ל־API ומחזיר Receipt מנותח (OCR)
  Future<Receipt> uploadAndParseReceipt(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw ReceiptServiceException('קובץ לא נמצא: $filePath');
    }

    final req = http.MultipartRequest('POST', _u('/receipts/upload'))
      ..headers.addAll(_authOnlyHeaders());

    // אם תרצה contentType מדויק – אפשר להכניס לפי הסיומת
    final filename = file.uri.pathSegments.isNotEmpty
        ? file.uri.pathSegments.last
        : 'receipt.jpg';

    req.files.add(
      await http.MultipartFile.fromPath(
        'file',
        filePath,
        filename: filename,
        // contentType: MediaType('image', 'jpeg'), // מאופשר אם מוסיפים http_parser
      ),
    );

    final res = await _sendWithRetryMultipart(req);
    final body = await res.stream.bytesToString();
    return _parseReceiptResponse(res.statusCode, body);
  }

  /// שומר קבלה לשרת ומחזיר את הגרסה השמורה (כולל מזהה מהשרת אם נוסף)
  Future<Receipt> saveReceipt(Receipt receipt) async {
    final res = await _sendWithRetry(
      () => _client.post(
        _u('/receipts'),
        headers: _jsonHeaders(),
        body: jsonEncode(receipt.toJson()),
      ),
    );
    return _parseReceiptResponse(res.statusCode, res.body);
  }

  /// אופציונלי: שליפה לפי מזהה (שימושי לעריכה/תצוגה)
  Future<Receipt> fetchReceipt(String id) async {
    final res = await _sendWithRetry(
      () => _client.get(_u('/receipts/$id'), headers: _authOnlyHeaders()),
    );
    return _parseReceiptResponse(res.statusCode, res.body);
  }

  /// אופציונלי: מחיקה
  Future<void> deleteReceipt(String id) async {
    final res = await _sendWithRetry(
      () => _client.delete(_u('/receipts/$id'), headers: _authOnlyHeaders()),
    );
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw ReceiptServiceException(
        'מחיקת הקבלה נכשלה',
        statusCode: res.statusCode,
        responseBody: res.body,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  // שליחת בקשה רגילה עם ניסיונות חוזרים ו-timeout
  Future<http.Response> _sendWithRetry(
    Future<http.Response> Function() send,
  ) async {
    int attempt = 0;
    while (true) {
      attempt++;
      try {
        final res = await send().timeout(_config.requestTimeout);
        return res;
      } on SocketException catch (e) {
        if (attempt > _config.maxRetries + 1) {
          throw ReceiptServiceException('אין חיבור לאינטרנט: $e');
        }
        await _backoff(attempt);
      } on TimeoutException {
        if (attempt > _config.maxRetries + 1) {
          throw ReceiptServiceException('הבקשה חרגה מהזמן המותר');
        }
        await _backoff(attempt);
      }
    }
  }

  // שליחת MultipartRequest עם ניסיונות חוזרים ו-timeout
  Future<http.StreamedResponse> _sendWithRetryMultipart(
    http.MultipartRequest request,
  ) async {
    int attempt = 0;
    while (true) {
      attempt++;
      try {
        final streamed = await _client
            .send(request)
            .timeout(_config.requestTimeout);
        return streamed;
      } on SocketException catch (e) {
        if (attempt > _config.maxRetries + 1) {
          throw ReceiptServiceException('אין חיבור לאינטרנט: $e');
        }
        await _backoff(attempt);
      } on TimeoutException {
        if (attempt > _config.maxRetries + 1) {
          throw ReceiptServiceException('העלאה חרגה מהזמן המותר');
        }
        await _backoff(attempt);
      }
    }
  }

  Future<void> _backoff(int attempt) async {
    // backoff ליניארי-קל: 400ms * attempt (אפשר להחליף לאקספוננציאלי)
    final delay = Duration(milliseconds: 400 * attempt);
    await Future.delayed(delay);
  }

  Receipt _parseReceiptResponse(int status, String body) {
    if (status == 200 || status == 201) {
      try {
        final data = jsonDecode(body);
        if (data is Map<String, dynamic>) {
          return Receipt.fromJson(data);
        } else {
          throw const FormatException('JSON root is not an object');
        }
      } on FormatException {
        throw ReceiptServiceException('פורמט JSON לא תקין', responseBody: body);
      }
    }

    // נסה לחלץ שגיאה מהשרת
    String? serverMsg;
    try {
      final data = jsonDecode(body);
      if (data is Map<String, dynamic>) {
        serverMsg = (data['message'] ?? data['error'])?.toString();
      }
    } catch (_) {
      // מתעלמים – נחזיר גוף גולמי
    }

    throw ReceiptServiceException(
      serverMsg ?? 'שגיאת שרת (${status})',
      statusCode: status,
      responseBody: body,
    );
  }

  /// סגירת הלקוח (מומלץ ב-Provider.dispose)
  void dispose() {
    _client.close();
  }
}
