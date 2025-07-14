import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:rezumo/list_cv/List_edit_cv.dart';

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
  //final GlobalKey _contentKey = GlobalKey();

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
You are a professional HR analyst. Analyze the resume and provide detailed, actionable recommendations.

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
- Improvement Recommendations

For each Improvement Recommendation, do the following:
- Quote the **exact part** of the resume that needs to be changed (use quotation marks).
- Provide a **clear suggestion** for how to rewrite or improve that part.
- If a section is **missing**, clearly indicate what is missing and provide an example of what should be added.

Format your response like this:
Improvement Recommendation:
1. ❌ "Current quoted text from the resume"
   ✅ Suggested replacement or improvement

2. ❌ [Missing Section: e.g., 'Professional Summary']
   ✅ Suggested content to add: "Experienced software engineer with 5+ years..."

Make sure your response is structured, easy to follow, and uses bullet points or numbered lists for clarity.
""";

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
          if (analysisResult != null)
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: _copyAnalysisToClipboard,
              tooltip: 'Copy analysis',
            ),
        ],
      ),
      body: Stack(
        children: [
          _buildContent(),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0, top: 15),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => editlist()),
                  );
                },
                child: const Text('Edit my pdf'),
              ),
            ),
          ),
        ],
      ),

    );
  }

  Future<void> _copyAnalysisToClipboard() async {
    if (analysisResult == null) return;


    String cleanedText = analysisResult!
        .replaceAllMapped(RegExp(r'[^\x00-\x7F]+'), (match) => '')
        .replaceAll('*', '')
        .replaceAll('#', '')
        .replaceAll('❌', '[X] ')
        .replaceAll('✅', '[✓] ')
        .replaceAll('“', '"')
        .replaceAll('”', '"')
        .replaceAll('�', '');

    await Clipboard.setData(ClipboardData(text: cleanedText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Analysis copied to clipboard')),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (analysisResult != null) ...[
            _buildFormattedAnalysis(analysisResult!),
            const SizedBox(height: 20),
          ] else
            const Text('Failed to get analysis'),
        ],
      ),
    );
  }

  Widget _buildFormattedAnalysis(String text) {

    String cleanedText = text.replaceAllMapped(RegExp(r'[^\x00-\x7F]+'), (match) => '');


    cleanedText = cleanedText
        .replaceAll('*', '')
        .replaceAll('#', '')
        .replaceAll('❌', '')
        .replaceAll('✅', '')
        .replaceAll('“', '"')
        .replaceAll('”', '"')
        .replaceAll('�', '');

    final sections = cleanedText.split('\n');
    final List<Widget> widgets = [];

    for (var line in sections) {
      if (line.trim().isEmpty) continue;


      if (line.startsWith('Resume Analysis') ||
          line.startsWith('Suggested Improvement')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              line.trim(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
        );
        continue;
      }


      if (line.contains('"')) {
        widgets.add(
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              line.trim(),
              style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        );
        continue;
      }


      if (line.trim().startsWith('-')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 8, right: 8),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    line.replaceFirst('-', '').trim(),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            line.trim(),
            style: const TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}