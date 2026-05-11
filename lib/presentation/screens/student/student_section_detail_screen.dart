import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../domain/models/section_model.dart';
import '../../../domain/models/exam_model.dart';
import 'take_exam_screen.dart';

class StudentSectionDetailScreen extends StatefulWidget {
  final SectionModel section;
  const StudentSectionDetailScreen({super.key, required this.section});

  @override
  State<StudentSectionDetailScreen> createState() => _StudentSectionDetailScreenState();
}

class _StudentSectionDetailScreenState extends State<StudentSectionDetailScreen> {
  String _subjectName = 'Cargando...';

  @override
  void initState() {
    super.initState();
    _loadSubjectName();
  }

  Future<void> _loadSubjectName() async {
    final doc = await FirebaseFirestore.instance.collection('subjects').doc(widget.section.subjectId).get();
    if (mounted && doc.exists) {
      setState(() => _subjectName = doc['name']);
    }
  }

  Future<void> _launchURL(String url) async {
    String cleanUrl = url.trim();
    if (!cleanUrl.startsWith('http')) {
      cleanUrl = 'https://$cleanUrl';
    }
    final Uri uri = Uri.parse(cleanUrl);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo abrir el enlace.'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_subjectName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(widget.section.name, style: const TextStyle(fontSize: 14, color: Colors.white70)),
            ],
          ),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.library_books_outlined), text: 'Contenido'),
              Tab(icon: Icon(Icons.assignment_outlined), text: 'Exámenes'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildContentTab(),
            _buildExamsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildContentTab() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('sections').doc(widget.section.id).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final sectionData = snapshot.data!.data() as Map<String, dynamic>;
        final List materials = sectionData['studyMaterials'] ?? [];

        return ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            const Text('Material de Estudio y Notas:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (materials.isEmpty)
              const Center(child: Text('Aún no hay material disponible.'))
            else
              ...materials.map((m) => Card(
                margin: const EdgeInsets.only(bottom: 20),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(backgroundColor: Colors.blueAccent, child: Icon(Icons.description, color: Colors.white)),
                          const SizedBox(width: 12),
                          Expanded(child: Text(m['title'] ?? 'Material', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(m['description'] ?? 'Sin notas adicionales', style: TextStyle(fontSize: 15, color: Colors.grey[300], height: 1.4)),
                      if (m['url'] != null && m['url'].toString().isNotEmpty) ...[
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _launchURL(m['url']),
                            icon: const Icon(Icons.open_in_new),
                            label: const Text('VISITAR ENLACE'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent.withOpacity(0.2),
                              foregroundColor: Colors.blueAccent,
                              side: const BorderSide(color: Colors.blueAccent),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              )).toList(),
          ],
        );
      },
    );
  }

  Widget _buildExamsTab() {
    final studentId = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('exams')
          .where('sectionId', isEqualTo: widget.section.id)
          .where('isVisible', isEqualTo: true)
          .snapshots(),
      builder: (context, examSnapshot) {
        if (!examSnapshot.hasData) return const Center(child: CircularProgressIndicator());
        final exams = examSnapshot.data!.docs.map((doc) => ExamModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();

        if (exams.isEmpty) return const Center(child: Text('No hay exámenes habilitados.'));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: exams.length,
          itemBuilder: (context, index) {
            final exam = exams[index];
            
            // BUSCAR SI EL ALUMNO YA HIZO ESTE EXAMEN
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('exam_results')
                  .where('studentId', isEqualTo: studentId)
                  .where('examId', isEqualTo: exam.id)
                  .snapshots(),
              builder: (context, resultSnapshot) {
                final hasCompleted = resultSnapshot.hasData && resultSnapshot.data!.docs.isNotEmpty;
                String gradeText = '';
                if (hasCompleted) {
                  final grade = resultSnapshot.data!.docs.first['grade'];
                  gradeText = 'Nota: ${grade.toStringAsFixed(1)} / 100';
                }

                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(exam.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(hasCompleted ? '✅ Completado - $gradeText' : '${exam.questions.length} preguntas • ${exam.description}'),
                    trailing: ElevatedButton(
                      onPressed: hasCompleted || exam.questions.isEmpty
                        ? null 
                        : () => Navigator.push(context, MaterialPageRoute(builder: (_) => TakeExamScreen(exam: exam))),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: hasCompleted ? Colors.green.withOpacity(0.2) : null,
                      ),
                      child: Text(hasCompleted ? 'LISTO' : 'EMPEZAR'),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
