import 'dart:convert';

import 'package:http/http.dart' as http;

var apiLink = 'https://opentdb.com/api.php?amount=20&category=18';

class QuizService {
  Future<List<dynamic>> getQuizData() async {
    var res = await http.get(Uri.parse(apiLink));
    if (res.statusCode == 200) {
      var data = jsonDecode(res.body.toString());
      return data['results'];
    } else {
      throw Exception('Failed to load quiz data');
    }
  }
}
