import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quiz_app/screen/end_quiz_screen.dart';
import 'package:quiz_app/services/api_service.dart';

class QuizProvider with ChangeNotifier {
  List<dynamic>? _questions;
  int _currentQuestionIndex = 0;
  int _score = 0;
  final QuizService _quizService = QuizService();
  String? _selectedAnswer;

  Timer? _timer;
  int _timeLeft = 20; // Total time for each question
  bool _isTimeUp = false;
  List<String>? _currentOptionsCache;

  List<dynamic>? get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  int get score => _score;
  String? get selectedAnswer => _selectedAnswer;
  int get timeLeft => _timeLeft;
  bool get isTimeUp => _isTimeUp;

  double get progress => _timeLeft / 20.0;

  VoidCallback? onQuizFinished;

  void startTimer() {
    _timeLeft = 20;
    _isTimeUp = false;
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        _timeLeft--;
        notifyListeners();
      } else {
        _isTimeUp = true;
        _timer?.cancel();
        handleTimeUp();
      }
    });
  }

  void resetQuiz() {
    _questions = null;
    _currentQuestionIndex = 0;
    _score = 0;
    _selectedAnswer = null;
    _isTimeUp = false;
    _timeLeft = 20; // Reset time
    _timer?.cancel();
    _currentOptionsCache = null;
    notifyListeners();
  }

  void handleTimeUp() {
    if (_questions != null) {
      if (_currentQuestionIndex < _questions!.length - 1) {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _currentOptionsCache = null;
        startTimer();
      } else {
        _notifyQuizFinished();
      }
      notifyListeners();
    }
  }

  void _notifyQuizFinished() {
    if (onQuizFinished != null) {
      onQuizFinished!();
    }
  }

  Future<void> fetchQuiz() async {
    _questions = await _quizService.getQuizData();
    _currentQuestionIndex = 0;
    _score = 0;
    _currentOptionsCache = null;
    startTimer();
    notifyListeners();
  }

  void answerQuestion(BuildContext context, String selectedAnswer) {
    if (_questions != null && _currentQuestionIndex < _questions!.length) {
      _selectedAnswer = selectedAnswer;
      final currentQuestion = _questions?[_currentQuestionIndex];

      if (selectedAnswer == currentQuestion['correct_answer']) {
        _score++;
      }

      notifyListeners();

      Future.delayed(const Duration(seconds: 1), () {
        if (_currentQuestionIndex < _questions!.length - 1) {
          _currentQuestionIndex++;
          moveToNextQuestion(); // Clear the options cache
          startTimer();
        } else {
          navigateToEndQuiz(context);
        }
        notifyListeners();
      });
    }
  }

  void navigateToEndQuiz(BuildContext context) {
    final correctAnswers =
        _questions?.map((q) => q['correct_answer'] as String).toList();
    final questions = _questions?.map((q) => q['question'] as String).toList();
    double percentage = (_score / _questions!.length) * 100;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => EndQuizScreen(
          score: _score,
          totalQuestions: _questions!.length,
          questions: questions!,
          correctAnswers: correctAnswers!,
          percentage: percentage,
        ),
      ),
    );
  }

  String getCurrentQuestion() {
    if (_questions != null &&
        _currentQuestionIndex >= 0 &&
        _currentQuestionIndex < _questions!.length) {
      return _questions?[_currentQuestionIndex]['question'] ?? '';
    }
    return '';
  }

  List<String> getCurrentOptions() {
    if (_currentOptionsCache == null) {
      final currentQuestion = _questions?[_currentQuestionIndex] ?? '';
      List<String> options =
          List<String>.from(currentQuestion['incorrect_answers'] ?? []);

      // Add the correct answer
      options.add(currentQuestion['correct_answer']);
      options.shuffle();

      _currentOptionsCache = options;
    }

    return _currentOptionsCache!;
  }

  getAnswerIcon(String option) {
    if (_selectedAnswer != null) {
      if (option == _selectedAnswer) {
        if (_selectedAnswer ==
            _questions?[_currentQuestionIndex]['correct_answer']) {
          return Icon(
            Icons.check,
            color: Colors.green,
          );
        } else {
          return Icon(
            Icons.close,
            color: Colors.red,
          ); // Incorrect answer
        }
      }
    }
    return Icon(
      Icons.info,
      color: Colors.red,
      size: 0,
    );
  }

  void moveToNextQuestion() {
    _currentOptionsCache = null; // Clear cache when moving to next question
  }
}
