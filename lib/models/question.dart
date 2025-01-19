class Option {
  final int id;
  final String description;
  final bool isCorrect;

  Option({
    required this.id,
    required this.description,
    required this.isCorrect,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      id: json['id'] as int,
      description: json['description'] as String,
      isCorrect: json['is_correct'] as bool? ?? false,
    );
  }
}

class Question {
  final int id;
  final String description;
  final String? topic;
  final List<Option> options;

  Question({
    required this.id,
    required this.description,
    this.topic,
    required this.options,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    try {
      return Question(
        id: json['id'] as int,
        description: json['description'] as String,
        topic: json['topic'] as String?,
        options: (json['options'] as List)
            .map((option) => Option.fromJson(option as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      print('Error parsing question: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  int get correctOptionIndex {
    final index = options.indexWhere((option) => option.isCorrect);
    return index >= 0 ? index : 0; // Default to first option if no correct answer found
  }
}
