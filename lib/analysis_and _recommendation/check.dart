import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rezumo/list_cv/List_edit_cv.dart';


class Check extends StatefulWidget {
  final String cvText;
  final String level;
  const Check({
    Key? key,
    required this.cvText,
    required this.level,
  }) : super(key: key);

  @override
  _CheckState createState() => _CheckState();
}

String cleanMarkdown(String input) {
  return input
      .replaceAll(RegExp(r'\\\d'), '')
      .replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'\1')
      .replaceAll(RegExp(r'#+\s*'), '')
      .replaceAll(RegExp(r'^\s*-\s*', multiLine: true), '')
      .replaceAll(RegExp(r'`{3}.*?`{3}', dotAll: true), '')
      .replaceAll(RegExp(r'[•\-–●▪◉❌✅✔️➤]'), '')
      .replaceAll(RegExp(r'\n{2,}'), '\n\n')
      .trim();
}

class _CheckState extends State<Check> {
  String? updatedHtml;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _improveCv();
  }

  Future<void> _improveCv() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final prompt = """
You are a top HR professional who excels at improving resumes. Your task is to **rewrite and improve this HTML resume** for a ${widget.level.toLowerCase()}-level position.

**Important:** Your response must be the **complete, improved HTML code of the resume**. Do not include any additional text, analysis, or markdown outside of the HTML structure. Ensure the HTML is well-formed and ready for direct use.

Original Resume HTML:
${widget.cvText}

Review the original HTML and apply improvements related to:
1.  **Structure**: Ensure all key sections are present and logically ordered (e.g., Contact Information, Professional Summary, Work Experience, Education, Skills, Projects, Awards/Certifications). Add missing sections if necessary.
2.  **Work Experience**: For each role, enhance descriptions with specific achievements, quantifiable results, and impact. Use action verbs.
3.  **Skills**: Ensure relevance to the target ${widget.level.toLowerCase()}-level position. Group skills logically.
4.  **Clarity & Readability**: Improve grammar, conciseness, and formatting. Ensure consistency in styling.

Provide only the improved HTML.
""";

      final response = await http.post(
        Uri.parse('https://api.deepseek.com/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer sk-adeb63c7fce543729d6359e9e081d557', // Replace with your actual DeepSeek API key
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
        final rawResponse = data['choices'][0]['message']['content'];

        final startIndex = rawResponse.toLowerCase().indexOf('<html');
        final endIndex = rawResponse.toLowerCase().lastIndexOf('</html>');

        String? cleanedHtml;
        if (startIndex != -1 && endIndex != -1 && endIndex >= startIndex) {
          cleanedHtml = rawResponse.substring(startIndex, endIndex + '</html>'.length);
        } else {
          final htmlMatch = RegExp(r'(<html[\s\S]*<\/html>)|(<body[\s\S]*<\/body>)|(<div[\s\S]*<\/div>)', caseSensitive: false).firstMatch(rawResponse);
          cleanedHtml = htmlMatch?.group(0) ?? rawResponse.trim();
        }

        setState(() {
          updatedHtml = cleanedHtml;
        });
      } else {
        throw Exception('API Error: ${response.body}');
      }
    } catch (e) {
      setState(() => errorMessage = 'Error: $e');
      debugPrint('Error improving CV: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _convertHtmlToPdf(String htmlContent) async {
    try {
      final uri = Uri.parse('https://uk-v2.convertapi.com/convert/html/to/pdf');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer LKHfjqi7eZw9cFUTsRzqYp7ytxPTjKM7' // Replace with your actual ConvertAPI key
        ..fields['StoreFile'] = 'true'
        ..files.add(http.MultipartFile.fromString('File', htmlContent, filename: 'updated_resume.html'));

      final response = await request.send();

      if (response.statusCode == 200) {
        final jsonResponse = await response.stream.bytesToString();
        final data = jsonDecode(jsonResponse);
        final fileUrl = data['Files'][0]['Url'];
        debugPrint("PDF created, URL: $fileUrl");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("PDF successfully created. You can download it from: $fileUrl"),
            duration: const Duration(seconds: 5),
          ),
        );
      } else {
        final errorBody = await response.stream.bytesToString();
        throw Exception('PDF conversion error (${response.statusCode}): $errorBody');
      }
    } catch (e) {
      debugPrint("Error creating PDF: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("PDF Error: $e")),
      );
    }
  }

  void _copyHtmlToClipboard() {
    if (updatedHtml != null && updatedHtml!.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: updatedHtml!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('HTML-код скопирован в буфер обмена!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нет HTML-кода для копирования.')),
      );
    }
  }
  Future<String?> _generateAndSavePdf(String htmlContent) async {
    try {
      // Генерация PDF - используем текущий код конвертации (через API)
      final uri = Uri.parse('https://uk-v2.convertapi.com/convert/html/to/pdf');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer LKHfjqi7eZw9cFUTsRzqYp7ytxPTjKM7'
        ..fields['StoreFile'] = 'true'
        ..files.add(http.MultipartFile.fromString('File', htmlContent, filename: 'updated_resume.html'));

      final response = await request.send();

      if (response.statusCode == 200) {
        final jsonResponse = await response.stream.bytesToString();
        final data = jsonDecode(jsonResponse);
        final fileUrl = data['Files'][0]['Url'];

        // Скачиваем PDF по URL и сохраняем локально
        final pdfBytes = await http.readBytes(Uri.parse(fileUrl));

        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/updated_resume.pdf';
        final file = File(filePath);
        await file.writeAsBytes(pdfBytes);

        return filePath;
      } else {
        final errorBody = await response.stream.bytesToString();
        throw Exception('PDF conversion error (${response.statusCode}): $errorBody');
      }
    } catch (e) {
      debugPrint("Error generating PDF: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("PDF generation error: $e")),
      );
      return null;
    }
  }

  Widget _buildHtmlContent(String htmlString) {
    if (htmlString.isEmpty) {
      return const Text('HTML content is empty or not received.', style: TextStyle(color: Colors.grey));
    }
    return Html(
      data: htmlString,
      style: {
        "body": Style(
          fontSize: FontSize(16.0),
          lineHeight: LineHeight(1.5),
          color: Colors.black87,
        ),
        "h1": Style(fontSize: FontSize(24.0), fontWeight: FontWeight.bold),
        "h2": Style(fontSize: FontSize(20.0), fontWeight: FontWeight.bold),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Improve Resume'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Обновить резюме',
            onPressed: () {
              _improveCv(); // Вызов метода для обновления резюме
            },
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Копировать HTML',
            onPressed: () {
              _copyHtmlToClipboard(); // Вызов метода для копирования HTML
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /*const Text(
              'Improved Resume (HTML):',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),*/
            _buildHtmlContent(updatedHtml ?? 'Failed to get improved resume.'),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () async {
                if (updatedHtml != null && updatedHtml!.isNotEmpty) {
                  final pdfPath = await _generateAndSavePdf(updatedHtml!);
                  if (pdfPath != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditList(
                          pdfFiles: [PdfFile(name: "MyResume.pdf", path: pdfPath)],
                        ),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("No HTML content to convert to PDF.")),
                  );
                }
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit my PDF'),
            ),

          ],
        ),
      ),
    );
  }
}