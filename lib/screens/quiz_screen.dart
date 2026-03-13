import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quiz.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class QuizScreen extends StatefulWidget {
  final Quiz quiz;
  final String courseTitle;

  QuizScreen({required this.quiz, required this.courseTitle});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  int? _selectedOptionIndex;
  bool _isFinished = false;
  final ApiService _api = ApiService();

  void _submitAnswer() {
    if (_selectedOptionIndex == null) return;

    if (_selectedOptionIndex ==
        widget.quiz.questions[_currentQuestionIndex].correctOptionIndex) {
      _score++;
    }

    if (_currentQuestionIndex < widget.quiz.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOptionIndex = null;
      });
    } else {
      _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await _api.submitScore(
      auth.userId ?? 'anonymous',
      widget.quiz.courseId,
      _score,
    );
    setState(() {
      _isFinished = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isFinished) {
      return _buildResultView();
    }

    final question = widget.quiz.questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(title: Text('Quiz: ${widget.courseTitle}')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / widget.quiz.questions.length,
              backgroundColor: Colors.grey[200],
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: 30),
            Text(
              'Question ${_currentQuestionIndex + 1} of ${widget.quiz.questions.length}',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 10),
            Text(
              question.text,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            ...List.generate(question.options.length, (index) {
              return Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _selectedOptionIndex = index;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: _selectedOptionIndex == index
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                        : Colors.transparent,
                    side: BorderSide(
                      color: _selectedOptionIndex == index
                          ? Theme.of(context).colorScheme.primary
                          : Color(0xFFE2E8F0),
                      width: 2,
                    ),
                    minimumSize: Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    question.options[index],
                    style: TextStyle(
                      color: _selectedOptionIndex == index
                          ? Theme.of(context).colorScheme.primary
                          : Color(0xFF1E293B),
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            }),
            Spacer(),
            ElevatedButton(
              onPressed: _selectedOptionIndex == null ? null : _submitAnswer,
              child: Text(
                _currentQuestionIndex == widget.quiz.questions.length - 1
                    ? 'Finish'
                    : 'Next',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView() {
    final percentage = (_score / widget.quiz.questions.length) * 100;
    final passed = percentage >= 70;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                passed ? Icons.check_circle : Icons.error_outline,
                size: 100,
                color: passed ? Colors.green : Colors.red,
              ),
              SizedBox(height: 20),
              Text(
                passed ? 'Congratulations!' : 'Keep Learning!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'You scored $_score out of ${widget.quiz.questions.length}',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Back to Course'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
