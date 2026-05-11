import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/models/exam_model.dart';

class ExamEditorScreen extends StatefulWidget {
  final ExamModel exam;
  const ExamEditorScreen({super.key, required this.exam});

  @override
  State<ExamEditorScreen> createState() => _ExamEditorScreenState();
}

class _ExamEditorScreenState extends State<ExamEditorScreen> {
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  List<QuestionModel> _questions = [];

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.exam.title);
    _descCtrl = TextEditingController(text: widget.exam.description);
    _questions = List.from(widget.exam.questions);
  }

  void _addQuestion() {
    setState(() {
      _questions.add(QuestionModel(
        text: 'Nueva Pregunta',
        options: ['Opción 1', 'Opción 2'],
        correctOptionIndex: 0,
      ));
    });
  }

  Future<void> _saveExam() async {
    final updatedExam = ExamModel(
      id: widget.exam.id,
      sectionId: widget.exam.sectionId,
      title: _titleCtrl.text,
      description: _descCtrl.text,
      isVisible: widget.exam.isVisible,
      questions: _questions,
    );

    await FirebaseFirestore.instance
        .collection('exams')
        .doc(widget.exam.id)
        .update(updatedExam.toMap());
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Examen guardado correctamente')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editor de Examen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveExam,
            tooltip: 'Guardar cambios',
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(labelText: 'Título del Examen', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descCtrl,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Instrucciones generales', border: OutlineInputBorder()),
          ),
          const Divider(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Preguntas (${_questions.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(onPressed: _addQuestion, icon: const Icon(Icons.add), label: const Text('Añadir')),
            ],
          ),
          const SizedBox(height: 16),
          ..._questions.asMap().entries.map((entry) => _buildQuestionCard(entry.key, entry.value)),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(int index, QuestionModel q) {
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(child: Text('${index + 1}')),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: q.text,
                    decoration: const InputDecoration(hintText: 'Escribe la pregunta aquí...'),
                    onChanged: (val) => _questions[index] = QuestionModel(
                      text: val,
                      options: q.options,
                      correctOptionIndex: q.correctOptionIndex,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => setState(() => _questions.removeAt(index)),
                )
              ],
            ),
            const SizedBox(height: 16),
            ...q.options.asMap().entries.map((optEntry) {
              int optIndex = optEntry.key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        q.correctOptionIndex == optIndex ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: q.correctOptionIndex == optIndex ? Colors.green : Colors.grey,
                      ),
                      onPressed: () => setState(() {
                        _questions[index] = QuestionModel(
                          text: q.text,
                          options: q.options,
                          correctOptionIndex: optIndex,
                        );
                      }),
                    ),
                    Expanded(
                      child: TextFormField(
                        initialValue: optEntry.value,
                        decoration: InputDecoration(
                          hintText: 'Opción ${optIndex + 1}',
                          filled: true,
                          fillColor: q.correctOptionIndex == optIndex ? Colors.green.withOpacity(0.05) : null,
                        ),
                        onChanged: (val) {
                          List<String> newOpts = List.from(q.options);
                          newOpts[optIndex] = val;
                          _questions[index] = QuestionModel(
                            text: q.text,
                            options: newOpts,
                            correctOptionIndex: q.correctOptionIndex,
                          );
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                      onPressed: () => setState(() {
                        List<String> newOpts = List.from(q.options);
                        newOpts.removeAt(optIndex);
                        _questions[index] = QuestionModel(
                          text: q.text,
                          options: newOpts,
                          correctOptionIndex: q.correctOptionIndex >= newOpts.length ? 0 : q.correctOptionIndex,
                        );
                      }),
                    )
                  ],
                ),
              );
            }),
            TextButton.icon(
              onPressed: () => setState(() {
                List<String> newOpts = List.from(q.options);
                newOpts.add('Nueva Opción');
                _questions[index] = QuestionModel(
                  text: q.text,
                  options: newOpts,
                  correctOptionIndex: q.correctOptionIndex,
                );
              }),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Añadir Opción'),
            )
          ],
        ),
      ),
    );
  }
}
