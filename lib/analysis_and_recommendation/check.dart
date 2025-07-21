import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:rezumo/analysis_and_recommendation/service/check_service.dart';
import 'package:rezumo/analysis_and_recommendation/utils/pdf_utils.dart';


import 'package:rezumo/list_cv/ListCv.dart';
import 'dart:io';

import 'package:rezumo/list_cv/PdfStorage.dart';
import 'package:rezumo/list_cv/models/pdf_file.dart';

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

class _CheckState extends State<Check> {
  String? updatedHtml;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadImprovedHtml();
  }

  Future<void> _loadImprovedHtml() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final html = await CheckService.improveResumeHtml(widget.cvText, widget.level);
      if (!mounted) return;
      setState(() {
        updatedHtml = html;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> _copyHtml() async {
    if (updatedHtml != null && updatedHtml!.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: updatedHtml!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('HTML copied')),
      );
    }
  }

  Widget _buildHtml(String html) {
    return Html(
      data: html,
      style: {
        "body": Style(fontSize: FontSize(16.0), lineHeight: LineHeight(1.5)),
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Improve Resume'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadImprovedHtml),
          IconButton(icon: const Icon(Icons.copy), onPressed: _copyHtml),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHtml(updatedHtml!),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () async {
                final path = await PdfUtils.generateAndSavePdf(updatedHtml!);
                if (path != null) {
                  final resume = PdfFile(name: 'MyResume.pdf', path: path);

                  
                  final existing = await PdfStorage.loadFiles();
                  final updatedList = [...existing, resume];
                  await PdfStorage.saveFiles(updatedList);

                  
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ListCv(pdfFiles: updatedList),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.edit),
              label: const Text("Edit my PDF"),
            )

          ],
        ),
      ),
    );
  }
}
