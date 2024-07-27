import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/screen/end_quiz_screen.dart';
import 'package:quiz_app/screen/splash_screen.dart';
import 'package:quiz_app/services/quiz_provider.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final quizProvider = Provider.of<QuizProvider>(context);
    if (quizProvider.questions == null) {
      quizProvider.fetchQuiz();
    } else if (quizProvider.currentQuestionIndex == 0 &&
        quizProvider.timeLeft == 20) {
      quizProvider.startTimer();
    }

    quizProvider.onQuizFinished = () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EndQuizScreen(
            score: quizProvider.score,
            totalQuestions: quizProvider.questions!.length,
            questions: quizProvider.questions!
                .map((q) => q['question'] as String)
                .toList(),
            correctAnswers: quizProvider.questions!
                .map((q) => q['correct_answer'] as String)
                .toList(),
            percentage:
                (quizProvider.score / quizProvider.questions!.length) * 100,
          ),
        ),
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);

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
        child: quizProvider.questions == null
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 60.0, left: 20, right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              final quizProvider = Provider.of<QuizProvider>(
                                  context,
                                  listen: false);
                              quizProvider.resetQuiz();
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SplashScreen()));
                            },
                            child: Container(
                              height: 60,
                              width: 60,
                              child: Center(
                                child: Icon(
                                  Icons.close,
                                  color: Colors.red,
                                ),
                              ),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.red, width: 2)),
                            ),
                          ),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Text(
                                "${quizProvider.timeLeft}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                ),
                              ),
                              SizedBox(
                                width: 70,
                                height: 70,
                                child: CircularProgressIndicator(
                                  backgroundColor: Colors.grey.withOpacity(0.3),
                                  value: quizProvider.timeLeft / 20,
                                  valueColor: const AlwaysStoppedAnimation(
                                      Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Center(
                      child: Image.asset(
                        'images/ideas.png',
                        height: 150,
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),

                    Text(
                      '  Question:${quizProvider.currentQuestionIndex + 1} out of ${quizProvider.questions?.length.toString()}',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    // Display the current question
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        quizProvider.getCurrentQuestion(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: List.generate(
                        quizProvider.getCurrentOptions().length,
                        (index) {
                          final option =
                              quizProvider.getCurrentOptions()[index];
                          return GestureDetector(
                            onTap: () {
                              quizProvider.answerQuestion(context, option);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5.0, horizontal: 2),
                              child: Container(
                                height: 60,
                                width: 380,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.black)),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Center(
                                        child: Text(
                                          option,
                                          maxLines: 2,
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontSize:
                                                option.length > 20 ? 14 : 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      quizProvider.getAnswerIcon(option),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
