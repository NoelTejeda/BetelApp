import 'package:cloud_firestore/cloud_firestore.dart';

class ExamResultModel {
  final String id;
  final String studentId;
  final String sectionId;
  final String examId;
  final double score;
  final DateTime date;

  ExamResultModel({
    required this.id,
    required this.studentId,
    required this.sectionId,
    required this.examId,
    required this.score,
    required this.date,
  });

  factory ExamResultModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ExamResultModel(
      id: documentId,
      studentId: map['studentId'] ?? '',
      sectionId: map['sectionId'] ?? '',
      examId: map['examId'] ?? '',
      score: (map['score'] ?? 0).toDouble(),
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'sectionId': sectionId,
      'examId': examId,
      'score': score,
      'date': Timestamp.fromDate(date),
    };
  }
}
