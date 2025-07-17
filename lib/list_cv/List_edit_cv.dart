import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class PdfFile {
  final String name;
  final String path;
  PdfFile({required this.name, required this.path});
}

class EditList extends StatelessWidget {
  final List<PdfFile> pdfFiles;

  const EditList({Key? key, required this.pdfFiles}) : super(key: key);

  Future<void> _downloadFile(BuildContext context, PdfFile pdfFile) async {
    try {
      final downloadsDir = await getApplicationDocumentsDirectory();
      final savePath = '${downloadsDir.path}/${pdfFile.name}';

      final sourceFile = File(pdfFile.path);
      final savedFile = await sourceFile.copy(savePath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File saved: ${savedFile.path}')),
      );


      final result = await OpenFile.open(savedFile.path);

      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open the file.: ${result.message}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving file: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit PDF List'),
      ),
      body: ListView.builder(
        itemCount: pdfFiles.length,
        itemBuilder: (context, index) {
          final pdfFile = pdfFiles[index];
          return ListTile(
            title: Text(pdfFile.name),
            trailing: IconButton(
              icon: const Icon(Icons.download),
              onPressed: () => _downloadFile(context, pdfFile),
              tooltip: 'Скачать PDF',
            ),
          );
        },
      ),
    );
  }
}