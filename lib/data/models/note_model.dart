import 'package:cloud_firestore/cloud_firestore.dart';

/// Mirrors a `notes/{noteId}` document (§21/§35).
class NoteModel {
  final String id;
  final String examId;
  final String subjectName;
  final String chapterName;
  final String topicName;
  final String title;
  final String content;
  final String contentType;
  final String? fileUrl;
  final String status;
  final int displayOrder;

  const NoteModel({
    required this.id,
    required this.examId,
    required this.subjectName,
    required this.chapterName,
    required this.topicName,
    required this.title,
    required this.content,
    required this.contentType,
    this.fileUrl,
    required this.status,
    required this.displayOrder,
  });

  factory NoteModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return NoteModel(
      id: doc.id,
      examId: data['examId'] ?? '',
      subjectName: data['subjectName'] ?? '',
      chapterName: data['chapterName'] ?? '',
      topicName: data['topicName'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      contentType: data['contentType'] ?? 'text',
      fileUrl: data['fileUrl'],
      status: data['status'] ?? 'draft',
      displayOrder: data['displayOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'examId': examId,
      'subjectName': subjectName,
      'chapterName': chapterName,
      'topicName': topicName,
      'title': title,
      'content': content,
      'contentType': contentType,
      'fileUrl': fileUrl,
      'status': status,
      'displayOrder': displayOrder,
    };
  }
}
