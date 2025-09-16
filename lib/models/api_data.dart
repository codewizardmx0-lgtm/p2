// نموذج بيانات بسيط للتعامل مع API
class ApiDataModel {
  final int id;
  String title;
  String body;
  final int userId;

  ApiDataModel({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
  });

  // تحويل البيانات من JSON إلى Model
  factory ApiDataModel.fromJson(Map<String, dynamic> json) {
    return ApiDataModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      userId: json['userId'] ?? 0,
    );
  }

  // تحويل البيانات من Model إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'userId': userId,
    };
  }

  // نسخ البيانات مع إمكانية تعديل بعض القيم
  ApiDataModel copyWith({
    int? id,
    String? title,
    String? body,
    int? userId,
  }) {
    return ApiDataModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      userId: userId ?? this.userId,
    );
  }
}