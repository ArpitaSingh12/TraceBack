import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/models.dart';

class ApiService {
  static const _storage = FlutterSecureStorage();

  // Change this to your computer's local IPv4 address
  // when connecting from a physical Android phone.
  static const String _physicalDeviceHost = '192.168.1.100';

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://$_physicalDeviceHost:8000';

      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.iOS:
      default:
        return 'http://127.0.0.1:8000';
    }
  }

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
      sendTimeout: const Duration(seconds: 8),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  static Future<String?> readToken() async {
    return _storage.read(key: 'traceback_token');
  }

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'traceback_token', value: token);
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: 'traceback_token');
  }

  static Map<String, String> _authHeaders(String? token) {
    if (token == null || token.isEmpty) {
      return {};
    }

    return {
      'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email.trim(),
          'password': password,
        },
      );

      final token = response.data['access_token'] as String;
      await saveToken(token);

      return {
        'token': token,
        'status': 'ok',
        'message': 'Login successful',
      };
    } on DioException catch (e) {
      debugPrint('Login API error: ${e.message}');
      debugPrint('Login response: ${e.response?.data}');

      // If backend is not running or credentials invalid, check if it's a known demo login
      return {
        'token': '',
        'status': 'error',
        'message': e.response?.data?['detail']?.toString() ??
            e.message ??
            'Unable to connect to the server',
      };
    } catch (e) {
      debugPrint('Unexpected login error: $e');

      return {
        'token': '',
        'status': 'error',
        'message': 'An unexpected error occurred',
      };
    }
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'name': name.trim(),
          'email': email.trim().toLowerCase(),
          'password': password,
          'role': role,
        },
      );

      return {
        'status': 'ok',
        'data': response.data,
        'message': 'Account created successfully',
      };
    } on DioException catch (e) {
      debugPrint('Register API error: ${e.response?.data}');
      return {
        'status': 'error',
        'message': e.response?.data?['detail']?.toString() ?? 'Registration failed',
      };
    } catch (e) {
      return {
        'status': 'error',
        'message': e.toString(),
      };
    }
  }

  static Future<UserProfile?> fetchMe() async {
    final token = await readToken();

    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final response = await _dio.get(
        '/auth/me',
        options: Options(headers: _authHeaders(token)),
      );

      return UserProfile.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('Fetch profile error: ${e.response?.data}');
      return null;
    }
  }

  static Future<List<Product>> fetchProducts() async {
    final token = await readToken();

    try {
      final response = await _dio.get(
        '/products',
        options: Options(headers: _authHeaders(token)),
      );

      final list = response.data as List;
      if (list.isNotEmpty) {
        return list.map((item) => Product.fromJson(item, isDemo: false)).toList();
      }
      return [];
    } on DioException catch (e) {
      debugPrint('Fetch products error: ${e.response?.data}');
      return [];
    } catch (_) {
      return [];
    }
  }

  static Future<List<Product>> fetchMyProducts() async {
    final token = await readToken();
    try {
      final response = await _dio.get(
        '/products/mine',
        options: Options(headers: _authHeaders(token)),
      );
      final list = response.data as List;
      return list.map((item) => Product.fromJson(item, isDemo: false)).toList();
    } on DioException catch (e) {
      debugPrint('Fetch producer products error: ${e.response?.data}');
      return [];
    }
  }

  static Future<Map<String, dynamic>> fetchAdminStats() async {
    final token = await readToken();
    try {
      final response = await _dio.get(
        '/admin/stats',
        options: Options(headers: _authHeaders(token)),
      );
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      debugPrint('Fetch admin stats error: ${e.response?.data}');
      return {};
    }
  }

  static Future<Product?> fetchProduct(int id) async {
    final token = await readToken();

    try {
      final response = await _dio.get(
        '/products/$id',
        options: Options(headers: _authHeaders(token)),
      );

      return Product.fromJson(response.data, isDemo: false);
    } on DioException catch (e) {
      debugPrint('Fetch product error: ${e.response?.data}');
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<List<SupplyEvent>> fetchJourney(int batchId) async {
    final token = await readToken();

    try {
      final response = await _dio.get(
        '/batches/$batchId',
        options: Options(headers: _authHeaders(token)),
      );

      final events = response.data['events'] as List;
      if (events.isNotEmpty) {
        return events.map((item) => SupplyEvent.fromJson(item)).toList();
      }
      return [];
    } on DioException catch (e) {
      debugPrint('Fetch journey error: ${e.response?.data}');
      return [];
    } catch (_) {
      return [];
    }
  }

  static Future<List<DocumentItem>> fetchDocuments(int productId) async {
    final token = await readToken();

    try {
      final response = await _dio.get(
        '/products/$productId/documents',
        options: Options(headers: _authHeaders(token)),
      );

      final documents = response.data as List;
      return documents
          .map((item) => DocumentItem.fromJson(item, isDemo: false))
          .toList();
    } on DioException catch (e) {
      debugPrint('Fetch documents error: ${e.response?.data}');
      return [];
    } catch (_) {
      return [];
    }
  }

  static Future<List<DocumentItem>> fetchMyDocuments() async {
    final token = await readToken();
    try {
      final response = await _dio.get(
        '/documents/mine',
        options: Options(headers: _authHeaders(token)),
      );
      final documents = response.data as List;
      return documents
          .map((item) => DocumentItem.fromJson(item, isDemo: false))
          .toList();
    } on DioException catch (e) {
      debugPrint('Fetch producer documents error: ${e.response?.data}');
      return [];
    }
  }

  // Admin Endpoints
  static Future<List<UserRecord>> fetchAdminUsers() async {
    final token = await readToken();

    try {
      final response = await _dio.get(
        '/admin/users',
        options: Options(headers: _authHeaders(token)),
      );

      final list = response.data as List;
      if (list.isNotEmpty) {
        return list.map((item) => UserRecord.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Admin users fetch error: $e');
      return [];
    }
  }

  static Future<List<DocumentItem>> fetchAdminDocuments() async {
    final token = await readToken();

    try {
      final response = await _dio.get(
        '/admin/documents',
        options: Options(headers: _authHeaders(token)),
      );

      final list = response.data as List;
      if (list.isNotEmpty) {
        return list.map((item) => DocumentItem.fromJson(item, isDemo: false)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Admin documents fetch error: $e');
      return [];
    }
  }

  static Future<bool> verifyDocument({
    required int documentId,
    required String status,
    String? remarks,
  }) async {
    final token = await readToken();

    try {
      await _dio.post(
        '/admin/documents/$documentId/verify',
        data: {
          'status': status.toLowerCase(),
          'remarks': remarks,
        },
        options: Options(headers: _authHeaders(token)),
      );
      return true;
    } catch (e) {
      debugPrint('Verify document API error: $e');
      return false;
    }
  }

  static Future<List<ActivityRecord>> fetchAuditLogs() async {
    final token = await readToken();

    try {
      final response = await _dio.get(
        '/admin/audit-logs',
        options: Options(headers: _authHeaders(token)),
      );

      final list = response.data as List;
      if (list.isNotEmpty) {
        return list
            .map((item) => ActivityRecord(
                  id: item['id'].toString(),
                  title: item['action'] ?? 'Audit Event',
                  subtitle: '${item['entity_type'] ?? 'Entity'} #${item['entity_id'] ?? ''}: ${item['details'] ?? ''}',
                  timestamp: item['created_at']?.toString().split('T').first ?? 'Today',
                  type: item['action']?.toString().contains('verify') == true ? 'verify' : 'update',
                ))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Audit logs fetch error: $e');
      return [];
    }
  }

  static Future<int?> createProduct(Product product) async {
    final token = await readToken();

    try {
      final response = await _dio.post(
        '/products',
        data: {
          'name': product.name,
          'description': product.description,
          'category': product.category,
          'brand': product.brand,
          'batch_number': product.batchNumber,
          'manufacturing_date': product.manufacturingDate,
          'expiry_date': product.expiryDate,
          'origin_location': product.origin,
          'current_status': product.status,
          'image_url': product.imageUrl.isNotEmpty ? product.imageUrl : null,
        },
        options: Options(headers: _authHeaders(token)),
      );

      if (response.statusCode == 201) {
        return response.data['id'] as int;
      }
      return null;
    } on DioException catch (e) {
      debugPrint('Create product API error: $e');
      if (e.response == null) {
        final existing = await fetchMyProducts();
        for (final savedProduct in existing) {
          if (savedProduct.batchNumber == product.batchNumber &&
              savedProduct.name == product.name) {
            return savedProduct.id;
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('Unexpected create product error: $e');
      return null;
    }
  }

  static String _mimeType(String fileName) {
    switch (fileName.split('.').last.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'pdf':
        return 'application/pdf';
      default:
        throw ArgumentError('Unsupported file type: $fileName');
    }
  }

  static MultipartFile _multipartFile(PlatformFile file) {
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      throw ArgumentError('The selected file could not be read.');
    }
    return MultipartFile.fromBytes(
      bytes,
      filename: file.name,
      contentType: DioMediaType.parse(_mimeType(file.name)),
    );
  }

  static Future<bool> uploadProductImage({
    required int productId,
    required PlatformFile image,
    void Function(double progress)? onProgress,
  }) async {
    final token = await readToken();
    try {
      await _dio.post(
        '/products/$productId/image',
        data: FormData.fromMap({'image': _multipartFile(image)}),
        options: Options(headers: _authHeaders(token)),
        onSendProgress: (sent, total) {
          if (total > 0) onProgress?.call(sent / total);
        },
      );
      return true;
    } on DioException catch (e) {
      debugPrint('Product image upload error: ${e.response?.data}');
      return false;
    }
  }

  static Future<bool> deleteProductImage(int productId) async {
    final token = await readToken();
    try {
      await _dio.delete(
        '/products/$productId/image',
        options: Options(headers: _authHeaders(token)),
      );
      return true;
    } on DioException catch (e) {
      debugPrint('Product image removal error: ${e.response?.data}');
      return false;
    }
  }

  static Future<bool> uploadDocument({
    required int productId,
    required String title,
    required String documentType,
    required PlatformFile file,
    void Function(double progress)? onProgress,
  }) async {
    final token = await readToken();
    try {
      await _dio.post(
        '/documents',
        data: FormData.fromMap({
          'product_id': productId.toString(),
          'title': title,
          'document_type': documentType,
          'file': _multipartFile(file),
        }),
        options: Options(headers: _authHeaders(token)),
        onSendProgress: (sent, total) {
          if (total > 0) onProgress?.call(sent / total);
        },
      );
      return true;
    } on DioException catch (e) {
      debugPrint('Document upload error: ${e.response?.data}');
      return false;
    }
  }

  static Future<Uint8List> downloadDocument(int documentId) async {
    final token = await readToken();
    final response = await _dio.get<List<int>>(
      '/documents/$documentId/file',
      options: Options(
        headers: _authHeaders(token),
        responseType: ResponseType.bytes,
      ),
    );
    return Uint8List.fromList(response.data ?? const []);
  }

  static Future<bool> updateProduct(Product product) async {
    final token = await readToken();
    try {
      await _dio.put(
        '/products/${product.id}',
        data: {
          'name': product.name,
          'description': product.description,
          'category': product.category,
          'brand': product.brand,
          'batch_number': product.batchNumber,
          'manufacturing_date': product.manufacturingDate,
          'expiry_date': product.expiryDate,
          'origin_location': product.origin,
          'current_status': product.status,
          'image_url': product.imageUrl.isNotEmpty ? product.imageUrl : null,
        },
        options: Options(headers: _authHeaders(token)),
      );
      return true;
    } on DioException catch (e) {
      debugPrint('Update product API error: ${e.response?.data}');
      return false;
    }
  }

  static Future<String> generateQrValue(int batchId) async {
    return base64Url.encode(
      utf8.encode('traceback-batch-$batchId'),
    );
  }
}
