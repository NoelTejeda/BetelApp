class CourseModel {
  final String id;
  final String title;
  final String description;
  final String teacherId;
  final String accessCode;
  final bool isEnrollmentClosed;
  final List<String> enrolledStudentsIds;
  final List<Map<String, String>> studyMaterials;

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.teacherId,
    required this.accessCode,
    this.isEnrollmentClosed = false,
    this.enrolledStudentsIds = const [],
    this.studyMaterials = const [],
  });

  factory CourseModel.fromMap(Map<String, dynamic> map, String documentId) {
    return CourseModel(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      teacherId: map['teacherId'] ?? '',
      accessCode: map['accessCode'] ?? '',
      isEnrollmentClosed: map['isEnrollmentClosed'] ?? false,
      enrolledStudentsIds: List<String>.from(map['enrolledStudentsIds'] ?? []),
      studyMaterials: (map['studyMaterials'] as List? ?? [])
          .map((item) => Map<String, String>.from(item))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'teacherId': teacherId,
      'accessCode': accessCode,
      'isEnrollmentClosed': isEnrollmentClosed,
      'enrolledStudentsIds': enrolledStudentsIds,
      'studyMaterials': studyMaterials,
    };
  }
}
