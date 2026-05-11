import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/models/section_model.dart';
import '../domain/models/exam_result_model.dart';

class ClassroomService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Unirse a una sección por código
  Future<void> joinSectionByCode(String code, String studentId) async {
    try {
      final query = await _firestore
          .collection('sections')
          .where('accessCode', isEqualTo: code)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw '❌ El código de acceso no es válido.';
      }

      final doc = query.docs.first;
      final section = SectionModel.fromMap(doc.data(), doc.id);

      if (section.isClosed) {
        throw '🔒 Las inscripciones para esta sección están cerradas.';
      }

      if (section.studentIds.contains(studentId)) {
        throw 'ℹ️ Ya estás inscrito en esta sección.';
      }

      await doc.reference.update({
        'studentIds': FieldValue.arrayUnion([studentId])
      });
    } catch (e) {
      rethrow;
    }
  }

  // Calcular promedio acumulado de un alumno en una sección
  Future<double> calculateStudentAverage(String studentId, String sectionId) async {
    final results = await _firestore.collection('exam_results')
        .where('studentId', isEqualTo: studentId)
        .where('sectionId', isEqualTo: sectionId)
        .get();

    if (results.docs.isEmpty) return 0.0;

    double total = 0;
    for (var doc in results.docs) {
      total += (doc.data()['grade'] ?? 0.0).toDouble();
    }
    return total / results.docs.length;
  }

  // Obtener alumnos de una sección con sus nombres reales
  Stream<List<Map<String, dynamic>>> getSectionStudents(List<String> studentIds) {
    if (studentIds.isEmpty) return Stream.value([]);
    
    return _firestore
        .collection('users')
        .where(FieldPath.documentId, whereIn: studentIds)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {
          'id': doc.id,
          'name': doc.data()['name'] ?? 'Sin nombre',
          'email': doc.data()['email'] ?? '',
        }).toList());
  }

  // Cerrar/Abrir sección
  Future<void> toggleSectionStatus(String sectionId, bool isClosed) async {
    await _firestore.collection('sections').doc(sectionId).update({
      'isClosed': isClosed,
    });
  }
}
