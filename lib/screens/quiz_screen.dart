import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/quiz_service.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuizService _quizService = QuizService();
  List<Question>? _questions;
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  bool _showResult = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final questions = await _quizService.fetchQuestions();
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _handleAnswer(int selectedIndex) {
    if (_questions == null) return;

    final currentQuestion = _questions![_currentQuestionIndex];
    final isCorrect = selectedIndex == currentQuestion.correctOptionIndex;

    if (isCorrect) {
      setState(() {
        _score++;
      });
    }

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCorrect ? 'Correct!' : 'Incorrect!',
          style: const TextStyle(fontSize: 16),
        ),
        backgroundColor: isCorrect ? Colors.green : Colors.red,
        duration: const Duration(milliseconds: 1500),
      ),
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        if (_currentQuestionIndex < _questions!.length - 1) {
          _currentQuestionIndex++;
        } else {
          _showResult = true;
        }
      });
    });
  }

  void _restartQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _showResult = false;
    });
    _loadQuestions();
  }

  Widget _buildQuestionView() {
    if (_questions == null) return const SizedBox.shrink();

    final currentQuestion = _questions![_currentQuestionIndex];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Question ${_currentQuestionIndex + 1} of ${_questions!.length}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentQuestion.description,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...currentQuestion.options.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton(
                    onPressed: () => _handleAnswer(entry.key),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      entry.value.description,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _questions!.length,
            backgroundColor: Colors.grey[200],
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.celebration,
                size: 64,
                color: Colors.amber,
              ),
              const SizedBox(height: 16),
              const Text(
                'Quiz Completed!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your Score: $_score/${_questions?.length ?? 0}',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _restartQuiz,
                icon: const Icon(Icons.replay),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz App'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _showResult
              ? _buildResultView()
              : _buildQuestionView(),
    );
  }
}
