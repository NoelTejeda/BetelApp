class SubjectModel {
  final String id;
  final String name;
  final String description;

  SubjectModel({
    required this.id,
    required this.name,
    required this.description,
  });

  factory SubjectModel.fromMap(Map<String, dynamic> map, String documentId) {
    return SubjectModel(
      id: documentId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
    };
  }
}
