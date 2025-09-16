import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// مثال API بسيط جداً في ملف واحد - مناسب لـ zapp.run
void main() {
  runApp(SimpleApiApp());
}

class SimpleApiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مثال API بسيط',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SimpleApiScreen(),
    );
  }
}

class SimpleApiScreen extends StatefulWidget {
  @override
  _SimpleApiScreenState createState() => _SimpleApiScreenState();
}

class _SimpleApiScreenState extends State<SimpleApiScreen> {
  List<dynamic> posts = [];
  bool isLoading = false;
  String? error;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  // استرجاع البيانات من API
  Future<void> fetchPosts() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/posts'),
      );

      if (response.statusCode == 200) {
        setState(() {
          posts = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('فشل في استرجاع البيانات');
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  // إضافة منشور جديد
  Future<void> addPost() async {
    if (titleController.text.isEmpty || bodyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى ملء جميع الحقول')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('https://jsonplaceholder.typicode.com/posts'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': titleController.text,
          'body': bodyController.text,
          'userId': 1,
        }),
      );

      if (response.statusCode == 201) {
        final newPost = json.decode(response.body);
        setState(() {
          posts.insert(0, newPost);
          titleController.clear();
          bodyController.clear();
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم إضافة المنشور بنجاح!')),
        );
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  // تحديث منشور
  Future<void> updatePost(int index) async {
    final post = posts[index];
    
    final titleEditController = TextEditingController(text: post['title']);
    final bodyEditController = TextEditingController(text: post['body']);

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تعديل المنشور'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleEditController,
              decoration: InputDecoration(labelText: 'العنوان'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: bodyEditController,
              decoration: InputDecoration(labelText: 'المحتوى'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, {
              'title': titleEditController.text,
              'body': bodyEditController.text,
            }),
            child: Text('حفظ'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() => isLoading = true);

      try {
        final response = await http.put(
          Uri.parse('https://jsonplaceholder.typicode.com/posts/${post['id']}'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'id': post['id'],
            'title': result['title'],
            'body': result['body'],
            'userId': post['userId'],
          }),
        );

        if (response.statusCode == 200) {
          setState(() {
            posts[index]['title'] = result['title'];
            posts[index]['body'] = result['body'];
            isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم تحديث المنشور بنجاح!')),
          );
        }
      } catch (e) {
        setState(() {
          error = e.toString();
          isLoading = false;
        });
      }
    }
  }

  // حذف منشور
  Future<void> deletePost(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد الحذف'),
        content: Text('هل تريد حذف هذا المنشور؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => isLoading = true);

      try {
        final response = await http.delete(
          Uri.parse('https://jsonplaceholder.typicode.com/posts/${posts[index]['id']}'),
        );

        if (response.statusCode == 200) {
          setState(() {
            posts.removeAt(index);
            isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم حذف المنشور بنجاح!')),
          );
        }
      } catch (e) {
        setState(() {
          error = e.toString();
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('مثال API بسيط'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // قسم إضافة منشور جديد
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('إضافة منشور جديد:', 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'العنوان',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: bodyController,
                  decoration: InputDecoration(
                    labelText: 'المحتوى',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: isLoading ? null : addPost,
                  child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('إضافة منشور'),
                ),
              ],
            ),
          ),
          
          // قائمة المنشورات
          Expanded(
            child: isLoading && posts.isEmpty
              ? Center(child: CircularProgressIndicator())
              : error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 60, color: Colors.red),
                        SizedBox(height: 16),
                        Text('خطأ: $error', 
                          style: TextStyle(color: Colors.red)),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: fetchPosts,
                          child: Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: fetchPosts,
                    child: posts.isEmpty
                      ? Center(child: Text('لا توجد منشورات'))
                      : ListView.builder(
                          itemCount: posts.length,
                          itemBuilder: (context, index) {
                            final post = posts[index];
                            return Card(
                              margin: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                              child: ListTile(
                                title: Text(post['title'], 
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(post['body'], 
                                  maxLines: 2, overflow: TextOverflow.ellipsis),
                                leading: CircleAvatar(
                                  child: Text('${post['id']}'),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => updatePost(index),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => deletePost(index),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    bodyController.dispose();
    super.dispose();
  }
}