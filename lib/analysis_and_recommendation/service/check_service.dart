import 'dart:convert';
import 'package:http/http.dart' as http;

class CheckService {
  static Future<String> improveResumeHtml(String cvText, String level) async {
    final prompt = """
You are a top HR professional who excels at improving resumes. Your task is to **rewrite and improve this HTML resume** for a ${level.toLowerCase()}-level position.

**Important:** Your response must be the **complete, improved HTML code of the resume**. Do not include any additional text, analysis, or markdown outside of the HTML structure. Ensure the HTML is well-formed and ready for direct use.

Original Resume HTML:
$cvText

Review the original HTML and apply improvements related to:
1.  **Structure**: Ensure all key sections are present and logically ordered (e.g., Contact Information, Professional Summary, Work Experience, Education, Skills, Projects, Awards/Certifications). Add missing sections if necessary.
2.  **Work Experience**: For each role, enhance descriptions with specific achievements, quantifiable results, and impact. Use action verbs.
3.  **Skills**: Ensure relevance to the target ${level.toLowerCase()}-level position. Group skills logically.
4.  **Clarity & Readability**: Improve grammar, conciseness, and formatting. Ensure consistency in styling.

Provide only the improved HTML.
""";

    final response = await http.post(
      Uri.parse('https://api.deepseek.com/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer Your Api-key',
      },
      body: jsonEncode({
        'model': 'deepseek-chat',
        'messages': [{'role': 'user', 'content': prompt}],
        'temperature': 0.7,
        'max_tokens': 8192,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final content = data['choices'][0]['message']['content'];

      final start = content.toLowerCase().indexOf('<html');
      final end = content.toLowerCase().lastIndexOf('</html>');

      if (start != -1 && end != -1 && end >= start) {
        return content.substring(start, end + 7);
      }

      final match = RegExp(r'(<html[\s\S]*<\/html>)|(<body[\s\S]*<\/body>)|(<div[\s\S]*<\/div>)', caseSensitive: false).firstMatch(content);
      return match?.group(0) ?? content.trim();
    } else {
      throw Exception("API error: ${response.statusCode} ${response.body}");
    }
  }
}
