import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/screen/splash_screen.dart';
import 'package:quiz_app/services/quiz_provider.dart';

class EndQuizScreen extends StatelessWidget {
  const EndQuizScreen(
      {super.key,
      required this.score,
      required this.totalQuestions,
      required this.questions,
      required this.correctAnswers,
      required this.percentage});

  final int score;
  final int totalQuestions;
  final List<String> questions;
  final List<String> correctAnswers;
  final double percentage;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Color(0xff1BFFFF), Color(0xff2E3192)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              percentage >= 50
                  ? 'Congratulation you score'
                  : 'Oops you scored: ',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
            ),
            Center(
              child: Text(
                '${percentage.toString()}%',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              'Correct Answer: ${score}',
              style: TextStyle(
                  color: Color.fromARGB(255, 25, 133, 29),
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
            Text(
              'Incorrect Answer: ${questions.length - score}',
              style: TextStyle(
                  color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () {
                final quizProvider =
                    Provider.of<QuizProvider>(context, listen: false);
                quizProvider.resetQuiz();
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SplashScreen()));
              },
              child: Container(
                height: 50,
                width: 180,
                child: Center(child: Text('Back to Home')),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
