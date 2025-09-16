import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_data.dart';

// خدمة API بسيطة
class ApiService {
  // رابط API مجاني للاختبار (JSONPlaceholder)
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  // استرجاع قائمة البيانات من API
  static Future<List<ApiDataModel>> fetchPosts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/posts'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => ApiDataModel.fromJson(json)).toList();
      } else {
        throw Exception('فشل في استرجاع البيانات: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال بـ API: $e');
    }
  }

  // استرجاع عنصر واحد من API
  static Future<ApiDataModel> fetchSinglePost(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/posts/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return ApiDataModel.fromJson(json);
      } else {
        throw Exception('فشل في استرجاع البيانات: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال بـ API: $e');
    }
  }

  // إرسال بيانات جديدة إلى API
  static Future<ApiDataModel> createPost(ApiDataModel post) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/posts'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(post.toJson()),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return ApiDataModel.fromJson(json);
      } else {
        throw Exception('فشل في إنشاء البيانات: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في إرسال البيانات: $e');
    }
  }

  // تحديث بيانات موجودة في API
  static Future<ApiDataModel> updatePost(ApiDataModel post) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/posts/${post.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(post.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return ApiDataModel.fromJson(json);
      } else {
        throw Exception('فشل في تحديث البيانات: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في تحديث البيانات: $e');
    }
  }

  // حذف بيانات من API
  static Future<bool> deletePost(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/posts/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('خطأ في حذف البيانات: $e');
    }
  }
}