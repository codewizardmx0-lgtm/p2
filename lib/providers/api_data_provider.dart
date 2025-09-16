import 'package:flutter/material.dart';
import '../models/api_data.dart';
import '../services/api_service.dart';

// Provider لإدارة بيانات API
class ApiDataProvider extends ChangeNotifier {
  List<ApiDataModel> _posts = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<ApiDataModel> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // استرجاع البيانات من API
  Future<void> fetchPosts() async {
    _setLoading(true);
    _error = null;
    
    try {
      _posts = await ApiService.fetchPosts();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // إضافة بيانات جديدة
  Future<void> createPost(String title, String body) async {
    _setLoading(true);
    _error = null;

    try {
      final newPost = ApiDataModel(
        id: 0, // سيتم تعيين ID من الخادم
        title: title,
        body: body,
        userId: 1, // مستخدم افتراضي
      );

      final createdPost = await ApiService.createPost(newPost);
      
      // إضافة البيانات الجديدة في بداية القائمة
      _posts.insert(0, createdPost);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // تحديث بيانات موجودة
  Future<void> updatePost(int index, String title, String body) async {
    if (index < 0 || index >= _posts.length) return;

    _setLoading(true);
    _error = null;

    try {
      final updatedPost = _posts[index].copyWith(
        title: title,
        body: body,
      );

      await ApiService.updatePost(updatedPost);
      _posts[index] = updatedPost;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // حذف بيانات
  Future<void> deletePost(int index) async {
    if (index < 0 || index >= _posts.length) return;

    _setLoading(true);
    _error = null;

    try {
      final postId = _posts[index].id;
      final success = await ApiService.deletePost(postId);
      
      if (success) {
        _posts.removeAt(index);
        notifyListeners();
      } else {
        _error = 'فشل في حذف البيانات';
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // مساعد لتعيين حالة التحميل
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // مسح رسائل الخطأ
  void clearError() {
    _error = null;
    notifyListeners();
  }
}