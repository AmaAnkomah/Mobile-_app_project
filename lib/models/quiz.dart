class Question {
  final String text;
  final List<String> options;
  final int correctOptionIndex;

  Question({
    required this.text,
    required this.options,
    required this.correctOptionIndex,
  });

  factory Question.fromJson(Map<String, dynamic> json) => Question(
    text: json['text'] ?? '',
    options: List<String>.from(json['options'] ?? []),
    correctOptionIndex: json['correct_option_index'] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'text': text,
    'options': options,
    'correct_option_index': correctOptionIndex,
  };
}

class Quiz {
  final String id;
  final String courseId;
  final List<Question> questions;

  Quiz({required this.id, required this.courseId, required this.questions});

  factory Quiz.fromJson(Map<String, dynamic> json, String docId) => Quiz(
    id: docId,
    courseId: json['course_id'] ?? '',
    questions: (json['questions'] as List? ?? [])
        .map((q) => Question.fromJson(q as Map<String, dynamic>))
        .toList(),
  );
}
