import 'package:flutter/material.dart';
import '../../../domain/models/exam_model.dart';

class ReviewExamScreen extends StatelessWidget {
  final ExamModel exam;
  final Map<int, int> selectedAnswers;

  const ReviewExamScreen({
    super.key, 
    required this.exam, 
    required this.selectedAnswers
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Revisión: ${exam.title}'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: exam.questions.length,
        itemBuilder: (context, index) {
          final question = exam.questions[index];
          final selectedOption = selectedAnswers[index];
          final correctOption = question.correctOptionIndex;
          final isCorrect = selectedOption == correctOption;

          return Card(
            margin: const EdgeInsets.only(bottom: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 0,
            color: Theme.of(context).cardColor,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: isCorrect ? Colors.green : Colors.red,
                        child: Icon(
                          isCorrect ? Icons.check : Icons.close, 
                          size: 16, 
                          color: Colors.white
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Pregunta ${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isCorrect ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    question.text,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),
                  ...question.options.asMap().entries.map((entry) {
                    final optIndex = entry.key;
                    final optText = entry.value;
                    
                    Color? bgColor;
                    Color? borderColor;
                    IconData? icon;

                    if (optIndex == correctOption) {
                      bgColor = Colors.green.withOpacity(0.1);
                      borderColor = Colors.green;
                      icon = Icons.check_circle;
                    } else if (optIndex == selectedOption && !isCorrect) {
                      bgColor = Colors.red.withOpacity(0.1);
                      borderColor = Colors.red;
                      icon = Icons.cancel;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: bgColor ?? Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: borderColor ?? Colors.grey.withOpacity(0.3),
                          width: borderColor != null ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              optText,
                              style: TextStyle(
                                fontWeight: borderColor != null ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (icon != null) Icon(icon, color: borderColor, size: 20),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
