import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Check extends StatefulWidget {
  final String cvText;

  const Check({Key? key, required this.cvText}) : super(key: key);

  @override
  _CheckState createState() => _CheckState();
}

class _CheckState extends State<Check> {
  String? feedback;
  bool loading = false;

  Future<void> checkCv() async {
    setState(() {
      loading = true;
    });

    final apiKey = 'AIzaSyBVlXR1qoHjSC2siPwsqxhLghx_iuAaIPE'; // Замени на .env или безопасный способ
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent?key=$apiKey',
    );


    final prompt = """
Ты карьерный консультант. Проанализируй это резюме и предложи улучшения:
${widget.cvText}
""";

    try {
      print('Запрос отправляется на: $url');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt}
              ]
            }
          ]
        }),
      );

      print('Код ответа: ${response.statusCode}');
      print('Тело ответа: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final result = data['candidates'][0]['content']['parts'][0]['text'];

        if (!mounted) return;
        setState(() {
          feedback = result;
          loading = false;
        });
      } else {
        throw Exception('Ошибка Gemini API: ${response.body}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        feedback = 'Произошла ошибка: $e';
        loading = false;
      });
    }
  }


  @override
  void initState() {
    super.initState();
    checkCv();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Проверка резюме')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : feedback == null
            ? const Text('Нет данных')
            : SingleChildScrollView(
          child: Text(feedback!),
        ),
      ),
    );
  }
}
