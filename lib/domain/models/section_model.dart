class SectionModel {
  final String id;
  final String subjectId;
  final String teacherId;
  final String name; // Ej: "Sección A - 2025"
  final String accessCode;
  final bool isClosed;
  final List<String> studentIds;

  SectionModel({
    required this.id,
    required this.subjectId,
    required this.teacherId,
    required this.name,
    required this.accessCode,
    this.isClosed = false,
    this.studentIds = const [],
  });

  factory SectionModel.fromMap(Map<String, dynamic> map, String documentId) {
    return SectionModel(
      id: documentId,
      subjectId: map['subjectId'] ?? '',
      teacherId: map['teacherId'] ?? '',
      name: map['name'] ?? '',
      accessCode: map['accessCode'] ?? '',
      isClosed: map['isClosed'] ?? false,
      studentIds: List<String>.from(map['studentIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'subjectId': subjectId,
      'teacherId': teacherId,
      'name': name,
      'accessCode': accessCode,
      'isClosed': isClosed,
      'studentIds': studentIds,
    };
  }
}
