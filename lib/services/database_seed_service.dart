import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseSeedService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> seedDatabase() async {
    try {
      print('Iniciando siembra de base de datos...');

      // 1. Crear Materias (Subjects)
      final subjects = [
        {'name': 'Teología Sistemática I', 'description': 'Estudio de las doctrinas fundamentales.'},
        {'name': 'Historia de la Iglesia', 'description': 'Desde los apóstoles hasta la actualidad.'},
        {'name': 'Hermenéutica Bíblica', 'description': 'Principios de interpretación de las Escrituras.'},
        {'name': 'Liderazgo Cristiano', 'description': 'Formación para el servicio en la obra.'},
        {'name': 'Evangelismo Práctico', 'description': 'Estrategias para compartir la fe.'},
      ];

      for (var s in subjects) {
        final existing = await _firestore
            .collection('subjects')
            .where('name', isEqualTo: s['name'])
            .get();

        if (existing.docs.isEmpty) {
          await _firestore.collection('subjects').add(s);
          print('Materia "${s['name']}" creada.');
        } else {
          print('Materia "${s['name']}" ya existe, saltando...');
        }
      }

      // 2. Crear una Sección de prueba
      final subjectSnap = await _firestore.collection('subjects').limit(1).get();
      if (subjectSnap.docs.isNotEmpty) {
        final subjectId = subjectSnap.docs.first.id;
        await _firestore.collection('sections').add({
          'subjectId': subjectId,
          'teacherId': 'admin_test',
          'name': 'Sección A - 2024',
          'accessCode': '123456',
          'isClosed': false,
          'studentIds': [],
        });
        print('Sección de prueba creada.');
      }

      print('✅ Base de datos actualizada con Materias y Secciones.');
    } catch (e) {
      print('❌ Error al sembrar: $e');
      rethrow;
    }
  }
}
