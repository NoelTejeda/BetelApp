import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../domain/models/section_model.dart';
import '../../../services/classroom_service.dart';
import 'student_section_detail_screen.dart';

class StudentClassesScreen extends StatefulWidget {
  const StudentClassesScreen({super.key});

  @override
  State<StudentClassesScreen> createState() => _StudentClassesScreenState();
}

class _StudentClassesScreenState extends State<StudentClassesScreen> {
  final _classroomService = ClassroomService();
  final _codeController = TextEditingController();

  void _showJoinCodeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Unirse a una Clase'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ingresa el código de 6 dígitos que te proporcionó tu maestro.'),
            const SizedBox(height: 20),
            TextField(
              controller: _codeController,
              textAlign: TextAlign.center,
              maxLength: 6,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 8),
              decoration: InputDecoration(
                counterText: '',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                hintText: '000000',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              try {
                final studentId = FirebaseAuth.instance.currentUser!.uid;
                await _classroomService.joinSectionByCode(_codeController.text, studentId);
                if (mounted) {
                  Navigator.pop(context);
                  _codeController.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ ¡Bienvenido a la clase!'), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Unirse'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(String sectionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Abandonar clase?'),
        content: const Text('Ya no verás esta clase en tu lista. Podrás unirte de nuevo con el código si lo deseas.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              try {
                final studentId = FirebaseAuth.instance.currentUser!.uid;
                // Intentamos borrar de 'sections'
                await FirebaseFirestore.instance.collection('sections').doc(sectionId).update({
                  'studentIds': FieldValue.arrayRemove([studentId])
                });
              } catch (e) {
                print('Nota: El documento no existe en sections, probablemente es antiguo.');
                // Si falla, es que es de las viejas o ya no existe, 
                // así que simplemente cerramos el diálogo
              }
              
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Abandonar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final studentId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Text('Mis Clases', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('sections')
                  .where('studentIds', arrayContains: studentId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                final courses = snapshot.data!.docs
                    .map((doc) => SectionModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
                    .toList();

                if (courses.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.school_outlined, size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text('Aún no te has unido a ninguna clase.', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('subjects').doc(course.subjectId).get(),
                      builder: (context, subSnap) {
                        final subjectName = subSnap.hasData ? subSnap.data!['name'] : 'Cargando materia...';
                        
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StudentSectionDetailScreen(section: course),
                                ),
                              );
                            },
                            onLongPress: () {
                              _showDeleteConfirmation(course.id);
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.blueAccent.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.class_outlined, color: Colors.blueAccent),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(subjectName, 
                                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                            Text(course.name, 
                                              style: TextStyle(fontSize: 14, color: Colors.blueAccent.withOpacity(0.8))),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  const LinearProgressIndicator(
                                    value: 0.3, 
                                    backgroundColor: Colors.grey, 
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green)
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showJoinCodeDialog,
        icon: const Icon(Icons.add),
        label: const Text('Unirse con Código'),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
