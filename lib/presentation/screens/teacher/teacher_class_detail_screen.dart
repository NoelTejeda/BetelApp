import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../../domain/models/section_model.dart';
import '../../../domain/models/exam_model.dart';
import '../../../services/classroom_service.dart';
import 'exam_editor_screen.dart';

class TeacherClassDetailScreen extends StatefulWidget {
  final SectionModel section;
  const TeacherClassDetailScreen({super.key, required this.section});

  @override
  State<TeacherClassDetailScreen> createState() => _TeacherClassDetailScreenState();
}

class _TeacherClassDetailScreenState extends State<TeacherClassDetailScreen> {
  final ClassroomService _classroomService = ClassroomService();
  late bool _isClosed;
  String _subjectName = 'Cargando...';

  @override
  void initState() {
    super.initState();
    _isClosed = widget.section.isClosed;
    _loadSubjectName();
  }

  Future<void> _loadSubjectName() async {
    final doc = await FirebaseFirestore.instance.collection('subjects').doc(widget.section.subjectId).get();
    if (mounted && doc.exists) {
      setState(() => _subjectName = doc['name']);
    }
  }

  void _shareCode() {
    final message = '🙌 ¡Hola! Únete a la clase de "$_subjectName" en la App Betel.\n\n'
                    '📍 Sección: ${widget.section.name}\n'
                    '🔑 Código de Acceso: ${widget.section.accessCode}\n\n'
                    '¡Te esperamos!';
    Share.share(message);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5, // AHORA 5 PESTAÑAS
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
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.info_outline), text: 'Info'),
              Tab(icon: Icon(Icons.people_outline), text: 'Alumnos'),
              Tab(icon: Icon(Icons.library_books_outlined), text: 'Material'),
              Tab(icon: Icon(Icons.assignment_outlined), text: 'Exámenes'),
              Tab(icon: Icon(Icons.analytics_outlined), text: 'Notas'), // NUEVA PESTAÑA
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildInfoTab(),
            _buildStudentsTab(),
            _buildMaterialTab(),
            _buildExamsTab(),
            _buildGradesTab(), // NUEVO MÉTODO
          ],
        ),
      ),
    );
  }

  // --- INFO TAB ---
  Widget _buildInfoTab() {
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        const Text('Información de la Clase', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        _infoItem('Materia', _subjectName, Icons.book),
        _infoItem('Sección', widget.section.name, Icons.layers),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blueAccent),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('CÓDIGO DE ACCESO', style: TextStyle(fontSize: 12, color: Colors.blueAccent, fontWeight: FontWeight.bold)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.section.accessCode, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 4)),
                  IconButton(icon: const Icon(Icons.share, color: Colors.blueAccent), onPressed: _shareCode),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        ListTile(
          title: const Text('Inscripciones Abiertas'),
          trailing: Switch(
            value: !_isClosed,
            onChanged: (val) async {
              setState(() => _isClosed = !val);
              await _classroomService.toggleSectionStatus(widget.section.id, !val);
            },
          ),
        ),
      ],
    );
  }

  Widget _infoItem(String label, String value, IconData icon) {
    return ListTile(leading: Icon(icon, color: Colors.blueAccent), title: Text(label, style: const TextStyle(fontSize: 12)), subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)));
  }

  // --- ALUMNOS TAB ---
  Widget _buildStudentsTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _classroomService.getSectionStudents(widget.section.studentIds),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final students = snapshot.data!;
        return ListView.builder(
          itemCount: students.length,
          itemBuilder: (context, index) => ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(students[index]['name']),
            subtitle: Text(students[index]['email']),
          ),
        );
      },
    );
  }

  // --- MATERIAL TAB ---
  Widget _buildMaterialTab() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('sections').doc(widget.section.id).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final data = snapshot.data!.data() as Map<String, dynamic>;
        final List materials = data['studyMaterials'] ?? [];
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: materials.length,
                itemBuilder: (context, index) {
                  final m = materials[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text(m['title'] ?? 'Sin título', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            Row(children: [
                              IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showMaterialDialog(index, m)),
                              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _confirmDeleteMaterial(index, materials)),
                            ]),
                          ]),
                          Text(m['description'] ?? '', style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(onPressed: () => _showMaterialDialog(-1, null), icon: const Icon(Icons.add), label: const Text('AÑADIR MATERIAL')),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteMaterial(int index, List materials) {
    showDialog(context: context, builder: (context) => AlertDialog(title: const Text('¿Borrar material?'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('No')), TextButton(onPressed: () async { materials.removeAt(index); await FirebaseFirestore.instance.collection('sections').doc(widget.section.id).update({'studyMaterials': materials}); Navigator.pop(context); }, child: const Text('Sí'))]));
  }

  void _showMaterialDialog(int index, Map? existing) {
    final title = TextEditingController(text: existing?['title']);
    final desc = TextEditingController(text: existing?['description']);
    final url = TextEditingController(text: existing?['url']);
    showDialog(context: context, builder: (context) => AlertDialog(title: Text(index == -1 ? 'Nuevo Material' : 'Editar'), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: title, decoration: const InputDecoration(labelText: 'Título')), TextField(controller: desc, decoration: const InputDecoration(labelText: 'Descripción')), TextField(controller: url, decoration: const InputDecoration(labelText: 'URL'))]), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')), ElevatedButton(onPressed: () async { final docRef = FirebaseFirestore.instance.collection('sections').doc(widget.section.id); final snap = await docRef.get(); List mats = List.from(snap.data()?['studyMaterials'] ?? []); final item = {'title': title.text, 'description': desc.text, 'url': url.text}; if (index == -1) mats.add(item); else mats[index] = item; await docRef.update({'studyMaterials': mats}); Navigator.pop(context); }, child: const Text('Guardar'))]));
  }

  // --- EXAMS TAB ---
  Widget _buildExamsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('exams').where('sectionId', isEqualTo: widget.section.id).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final exams = snapshot.data!.docs.map((doc) => ExamModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: exams.length,
                itemBuilder: (context, index) => Card(
                  child: ListTile(
                    title: Text(exams[index].title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(exams[index].isVisible ? '🟢 Habilitado' : '🔴 Deshabilitado'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(value: exams[index].isVisible, onChanged: (val) async => await FirebaseFirestore.instance.collection('exams').doc(exams[index].id).update({'isVisible': val})),
                        IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ExamEditorScreen(exam: exams[index])))),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(onPressed: _createNewExam, icon: const Icon(Icons.add), label: const Text('NUEVO EXAMEN')),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createNewExam() async {
    final doc = await FirebaseFirestore.instance.collection('exams').add({'sectionId': widget.section.id, 'title': 'Nuevo Examen', 'description': '', 'isVisible': false, 'questions': []});
    final snap = await doc.get();
    Navigator.push(context, MaterialPageRoute(builder: (_) => ExamEditorScreen(exam: ExamModel.fromMap(snap.data() as Map<String, dynamic>, doc.id))));
  }

  // --- NUEVA PESTAÑA: NOTAS ---
  Widget _buildGradesTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _classroomService.getSectionStudents(widget.section.studentIds),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final students = snapshot.data!;

        if (students.isEmpty) return const Center(child: Text('No hay alumnos para calificar.'));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: students.length,
          itemBuilder: (context, index) {
            final student = students[index];
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('exam_results')
                  .where('sectionId', isEqualTo: widget.section.id)
                  .where('studentId', isEqualTo: student['id']) // CORREGIDO: Usar 'id'
                  .snapshots(),
              builder: (context, resSnap) {
                double average = 0;
                int completed = 0;
                if (resSnap.hasData && resSnap.data!.docs.isNotEmpty) {
                  completed = resSnap.data!.docs.length;
                  double total = 0;
                  for (var doc in resSnap.data!.docs) {
                    total += (doc['grade'] as num).toDouble();
                  }
                  average = total / completed;
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: average >= 70 ? Colors.green : (completed > 0 ? Colors.orange : Colors.grey),
                      child: Text(average.toStringAsFixed(0), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(student['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Exámenes realizados: $completed'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showStudentAcademicDetails(student, resSnap.data?.docs ?? []),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showStudentAcademicDetails(Map<String, dynamic> student, List<QueryDocumentSnapshot> results) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),
            Row(
              children: [
                const CircleAvatar(radius: 30, child: Icon(Icons.person, size: 30)),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student['name'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    Text(student['email'], style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text('Desglose de Calificaciones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: results.isEmpty 
                ? const Center(child: Text('El alumno aún no ha realizado exámenes.'))
                : ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final res = results[index];
                      return ListTile(
                        leading: const Icon(Icons.assignment_turned_in, color: Colors.green),
                        title: Text(res['examTitle'] ?? 'Examen'),
                        trailing: Text('${(res['grade'] as num).toStringAsFixed(1)}', 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
