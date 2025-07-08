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
  String? analysisResult;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _analyzeWithDeepSeek();
  }

  Future<void> _analyzeWithDeepSeek() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });


      final prompt = """
You are a professional HR analyst. Analyze the resume and provide recommendations:

Resume Analysis:
${widget.cvText}

Analyze the following:
1. Structure (Does it include all key sections?)
2. Work Experience (Specific achievements and impact)
3. Skills (Relevance to the target position)
4. Clarity & Readability (Grammar, conciseness, formatting)

Structure your response as:
- Strengths
- Weaknesses
- Improvement Recommendations""";



      final response = await http.post(
        Uri.parse('https://api.deepseek.com/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer Your api-key',
        },
        body: jsonEncode({
          'model': 'deepseek-chat',
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'temperature': 0.7,
          'max_tokens': 2000,
        }),
      );


      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          analysisResult = data['choices'][0]['message']['content'];
        });
      } else {
        throw Exception('API Error: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Analysis error: ${e.toString()}';
      });
      debugPrint('Full error details: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Analysis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _analyzeWithDeepSeek,
          ),
        ],
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _analyzeWithDeepSeek,
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Text(
        analysisResult ?? 'Failed to get analysis',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}