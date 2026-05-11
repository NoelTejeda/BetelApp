import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../domain/models/section_model.dart';
import '../../../domain/models/subject_model.dart';
import 'teacher_class_detail_screen.dart';
import 'dart:math';

class TeacherClassesScreen extends StatefulWidget {
  const TeacherClassesScreen({super.key});

  @override
  State<TeacherClassesScreen> createState() => _TeacherClassesScreenState();
}

class _TeacherClassesScreenState extends State<TeacherClassesScreen> {
  String _generateCode() {
    return (Random().nextInt(900000) + 100000).toString();
  }

  Future<void> _createNewSection(BuildContext context) async {
    String? selectedSubjectId;
    final nameController = TextEditingController(text: 'Sección A - 2025');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Abrir Nueva Sección'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('1. Elige la Materia:', style: TextStyle(fontWeight: FontWeight.bold)),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('subjects').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const CircularProgressIndicator();
                  final subjects = snapshot.data!.docs;
                  return DropdownButton<String>(
                    isExpanded: true,
                    value: selectedSubjectId,
                    hint: const Text('Seleccionar Materia'),
                    items: subjects.map((doc) {
                      return DropdownMenuItem(
                        value: doc.id,
                        child: Text(doc['name']),
                      );
                    }).toList(),
                    onChanged: (val) => setDialogState(() => selectedSubjectId = val),
                  );
                },
              ),
              const SizedBox(height: 16),
              const Text('2. Nombre de la Sección:', style: TextStyle(fontWeight: FontWeight.bold)),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: 'Ej: Grupo A - 2025'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: selectedSubjectId == null 
                ? null 
                : () async {
                  final user = FirebaseAuth.instance.currentUser;
                  final newSection = SectionModel(
                    id: '',
                    subjectId: selectedSubjectId!,
                    teacherId: user!.uid,
                    name: nameController.text,
                    accessCode: _generateCode(),
                  );
                  await FirebaseFirestore.instance.collection('sections').add(newSection.toMap());
                  if (context.mounted) Navigator.pop(context);
                },
              child: const Text('Abrir Sección'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteSectionDialog(BuildContext context, String sectionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar Sección?'),
        content: const Text('Esta acción borrará la sección y todas sus notas asociadas permanentemente.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('sections').doc(sectionId).delete();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Text('Mis Secciones Activas', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('sections')
                  .where('teacherId', isEqualTo: user?.uid)
                  .where('isClosed', isEqualTo: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                final sections = snapshot.data!.docs
                    .map((doc) => SectionModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
                    .toList();

                if (sections.isEmpty) {
                  return const Center(child: Text('No tienes secciones activas.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: sections.length,
                  itemBuilder: (context, index) {
                    final section = sections[index];
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('subjects').doc(section.subjectId).get(),
                      builder: (context, subSnap) {
                        final subjectName = subSnap.hasData ? subSnap.data!['name'] : 'Cargando...';
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            title: Text(subjectName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(section.name),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TeacherClassDetailScreen(section: section),
                                ),
                              );
                            },
                            onLongPress: () {
                              _showDeleteSectionDialog(context, section.id);
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createNewSection(context),
        label: const Text('Abrir Sección'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
