class QuestionModel {
  final String text;
  final List<String> options;
  final int correctOptionIndex;

  QuestionModel({
    required this.text,
    required this.options,
    required this.correctOptionIndex,
  });

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
    };
  }

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      text: map['text'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctOptionIndex: map['correctOptionIndex'] ?? 0,
    );
  }
}

class ExamModel {
  final String id;
  final String sectionId;
  final String title;
  final String description;
  final bool isVisible;
  final List<QuestionModel> questions;

  ExamModel({
    required this.id,
    required this.sectionId,
    required this.title,
    required this.description,
    this.isVisible = false,
    this.questions = const [],
  });

  factory ExamModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ExamModel(
      id: documentId,
      sectionId: map['sectionId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      isVisible: map['isVisible'] ?? false,
      questions: (map['questions'] as List? ?? [])
          .map((q) => QuestionModel.fromMap(q))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sectionId': sectionId,
      'title': title,
      'description': description,
      'isVisible': isVisible,
      'questions': questions.map((q) => q.toMap()).toList(),
    };
  }
}
