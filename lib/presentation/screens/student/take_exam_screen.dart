import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../domain/models/exam_model.dart';

class TakeExamScreen extends StatefulWidget {
  final ExamModel exam;
  const TakeExamScreen({super.key, required this.exam});

  @override
  State<TakeExamScreen> createState() => _TakeExamScreenState();
}

class _TakeExamScreenState extends State<TakeExamScreen> {
  int _currentQuestionIndex = 0;
  final Map<int, int> _selectedAnswers = {}; // Map<QuestionIndex, SelectedOptionIndex>
  bool _isFinished = false;
  double _finalGrade = 0.0;

  void _submitExam() async {
    int correctCount = 0;
    for (int i = 0; i < widget.exam.questions.length; i++) {
      if (_selectedAnswers[i] == widget.exam.questions[i].correctOptionIndex) {
        correctCount++;
      }
    }

    _finalGrade = (correctCount / widget.exam.questions.length) * 100;

    // Guardar resultado en Firestore
    final user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance.collection('exam_results').add({
      'studentId': user!.uid,
      'studentName': user.displayName ?? 'Alumno',
      'sectionId': widget.exam.sectionId,
      'examId': widget.exam.id,
      'examTitle': widget.exam.title,
      'grade': _finalGrade,
      'date': FieldValue.serverTimestamp(),
    });

    setState(() => _isFinished = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isFinished) return _buildResultScreen();

    final question = widget.exam.questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exam.title),
        actions: [
          Center(child: Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Text('${_currentQuestionIndex + 1} / ${widget.exam.questions.length}', 
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          )),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / widget.exam.questions.length,
            backgroundColor: Colors.grey[800],
            color: Colors.greenAccent,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.text,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  ...question.options.asMap().entries.map((entry) {
                    final index = entry.key;
                    final text = entry.value;
                    final isSelected = _selectedAnswers[_currentQuestionIndex] == index;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: InkWell(
                        onTap: () => setState(() => _selectedAnswers[_currentQuestionIndex] = index),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blueAccent.withOpacity(0.2) : Colors.grey[900],
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: isSelected ? Colors.blueAccent : Colors.grey[700]!,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 15,
                                backgroundColor: isSelected ? Colors.blueAccent : Colors.grey[800],
                                child: Text(String.fromCharCode(65 + index), // A, B, C...
                                  style: const TextStyle(color: Colors.white, fontSize: 12)),
                              ),
                              const SizedBox(width: 16),
                              Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
                              if (isSelected) const Icon(Icons.check_circle, color: Colors.blueAccent),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentQuestionIndex > 0)
                  TextButton(
                    onPressed: () => setState(() => _currentQuestionIndex--),
                    child: const Text('Anterior'),
                  )
                else
                  const SizedBox(),
                
                ElevatedButton(
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
                  onPressed: _selectedAnswers.containsKey(_currentQuestionIndex)
                    ? () {
                        if (_currentQuestionIndex < widget.exam.questions.length - 1) {
                          setState(() => _currentQuestionIndex++);
                        } else {
                          _submitExam();
                        }
                      }
                    : null,
                  child: Text(_currentQuestionIndex < widget.exam.questions.length - 1 ? 'Siguiente' : 'Finalizar Examen'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline, size: 100, color: Colors.greenAccent),
              const SizedBox(height: 24),
              const Text('¡Examen Completado!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text('Tu calificación es:', style: TextStyle(fontSize: 18, color: Colors.grey[400])),
              Text('${_finalGrade.toStringAsFixed(1)} / 100', 
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Regresar a la Clase'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
