import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/api_data_provider.dart';
import 'package:flutter_app/widgets/common_appbar_view.dart';
import 'package:flutter_app/utils/themes.dart';
import 'package:flutter_app/widgets/remove_focuse.dart';

class ApiDemoScreen extends StatefulWidget {
  const ApiDemoScreen({Key? key}) : super(key: key);

  @override
  _ApiDemoScreenState createState() => _ApiDemoScreenState();
}

class _ApiDemoScreenState extends State<ApiDemoScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // استرجاع البيانات عند بدء الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ApiDataProvider>(context, listen: false).fetchPosts();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RemoveFocuse(
        onClick: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Column(
          children: [
            CommonAppbarView(
              iconData: Icons.arrow_back,
              onBackClick: () {
                Navigator.pop(context);
              },
              titleText: 'API Demo - استرجاع وتعديل البيانات',
            ),
            Expanded(
              child: Consumer<ApiDataProvider>(
                builder: (context, apiProvider, child) {
                  if (apiProvider.isLoading && apiProvider.posts.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (apiProvider.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, size: 60, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            'خطأ: ${apiProvider.error}',
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              apiProvider.clearError();
                              apiProvider.fetchPosts();
                            },
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      // قسم إضافة بيانات جديدة
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.grey[100],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'إضافة منشور جديد:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _titleController,
                              decoration: const InputDecoration(
                                labelText: 'العنوان',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _bodyController,
                              decoration: const InputDecoration(
                                labelText: 'المحتوى',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: apiProvider.isLoading ? null : _addPost,
                              child: apiProvider.isLoading 
                                ? const SizedBox(
                                    width: 20, 
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('إضافة منشور'),
                            ),
                          ],
                        ),
                      ),
                      
                      // قائمة البيانات
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () => apiProvider.fetchPosts(),
                          child: apiProvider.posts.isEmpty
                            ? const Center(child: Text('لا توجد بيانات'))
                            : ListView.builder(
                                itemCount: apiProvider.posts.length,
                                itemBuilder: (context, index) {
                                  final post = apiProvider.posts[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 16, 
                                      vertical: 8,
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        post.title,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                        post.body,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.edit, color: AppTheme.primaryColor),
                                            onPressed: () => _showEditDialog(context, index, post.title, post.body),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () => _showDeleteDialog(context, index),
                                          ),
                                        ],
                                      ),
                                      leading: CircleAvatar(
                                        backgroundColor: AppTheme.primaryColor,
                                        child: Text('${post.id}', style: const TextStyle(color: Colors.white)),
                                      ),
                                    ),
                                  );
                                },
                              ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addPost() {
    if (_titleController.text.trim().isEmpty || _bodyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى ملء جميع الحقول')),
      );
      return;
    }

    Provider.of<ApiDataProvider>(context, listen: false)
        .createPost(_titleController.text.trim(), _bodyController.text.trim());
    
    _titleController.clear();
    _bodyController.clear();
  }

  void _showEditDialog(BuildContext context, int index, String currentTitle, String currentBody) {
    final titleController = TextEditingController(text: currentTitle);
    final bodyController = TextEditingController(text: currentBody);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل المنشور'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'العنوان',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bodyController,
              decoration: const InputDecoration(
                labelText: 'المحتوى',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty && 
                  bodyController.text.trim().isNotEmpty) {
                Provider.of<ApiDataProvider>(context, listen: false)
                    .updatePost(index, titleController.text.trim(), bodyController.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا المنشور؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<ApiDataProvider>(context, listen: false).deletePost(index);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}