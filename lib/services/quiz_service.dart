import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question.dart';

class QuizService {
  static const String apiUrl = 'https://api.jsonserve.com/Uw5CrX';

  Future<List<Question>> fetchQuestions() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> questionsData = jsonData['questions'] as List;
        final validQuestions = questionsData.where((q) {
          final options = q['options'] as List?;
          return options != null && options.isNotEmpty;
        }).toList();

        if (validQuestions.isEmpty) {
          throw Exception('No valid questions found');
        }

        return validQuestions.map((questionJson) {
          final options = (questionJson['options'] as List).map((optionJson) {
            return Option(
              id: optionJson['id'] as int,
              description: optionJson['description'] as String,
              isCorrect: optionJson['is_correct'] as bool? ?? false,
            );
          }).toList();

          return Question(
            id: questionJson['id'] as int,
            description: questionJson['description'] as String,
            topic: questionJson['topic'] as String?,
            options: options,
          );
        }).toList();
      } else {
        throw Exception('Failed to load questions: ${response.statusCode}');
      }
    } catch (e) {
      return [
        Question(
          id: 1,
          description: 'What is the capital of France?',
          topic: 'Geography',
          options: [
            Option(id: 1, description: 'London', isCorrect: false),
            Option(id: 2, description: 'Paris', isCorrect: true),
            Option(id: 3, description: 'Berlin', isCorrect: false),
            Option(id: 4, description: 'Madrid', isCorrect: false),
          ],
        ),
        Question(
          id: 2,
          description: 'Which planet is known as the Red Planet?',
          topic: 'Science',
          options: [
            Option(id: 5, description: 'Venus', isCorrect: false),
            Option(id: 6, description: 'Jupiter', isCorrect: false),
            Option(id: 7, description: 'Mars', isCorrect: true),
            Option(id: 8, description: 'Saturn', isCorrect: false),
          ],
        ),
        Question(
          id: 3,
          description: 'What is 2 + 2?',
          topic: 'Math',
          options: [
            Option(id: 9, description: '3', isCorrect: false),
            Option(id: 10, description: '4', isCorrect: true),
            Option(id: 11, description: '5', isCorrect: false),
            Option(id: 12, description: '6', isCorrect: false),
          ],
        ),
      ];
    }
  }
}
