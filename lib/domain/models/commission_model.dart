class CommissionModel {
  final String id;
  final String name;
  final String mission;
  final String function;
  final String imageUrl;

  CommissionModel({
    required this.id,
    required this.name,
    required this.mission,
    required this.function,
    required this.imageUrl,
  });

  factory CommissionModel.fromMap(String id, Map<String, dynamic> map) {
    return CommissionModel(
      id: id,
      name: map['name'] ?? '',
      mission: map['mission'] ?? '',
      function: map['function'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'mission': mission,
      'function': function,
      'imageUrl': imageUrl,
    };
  }
}
