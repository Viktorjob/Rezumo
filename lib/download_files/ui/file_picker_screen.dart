import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:rezumo/analysis_and%20_recommendation/check.dart';

import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../bloc/file_picker_bloc.dart';

class FilePickerScreen extends StatelessWidget {
  const FilePickerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: const Text('Rezumo')),
      body: Center(
        child: BlocBuilder<FilePickerBloc, FilePickerState>(
          builder: (context, state) {
            if (state is FilePickerInitial) {
              return ElevatedButton(
                onPressed: () {
                  context.read<FilePickerBloc>().add(PickFileEvent());
                },
                child: const Text('Select PDF'),
              );
            } else if (state is FilePickerLoading) {
              return const CircularProgressIndicator();
            } else if (state is FilePickerLoaded) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: screenHeight / 2,
                    width: 300,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                        width: 5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: PDFView(
                      filePath: state.filePath,
                      defaultPage: 0,
                      enableSwipe: false,
                      swipeHorizontal: false,
                      autoSpacing: false,
                      pageSnap: false,
                      fitEachPage: true,
                      fitPolicy: FitPolicy.BOTH,
                    ),
                  ),

                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      context.read<FilePickerBloc>().add(PickFileEvent());
                    },
                    child: const Text('Select another file'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final filePath = state.filePath;
                      final bytes = File(filePath).readAsBytesSync();
                      final document = PdfDocument(inputBytes: bytes);
                      final extractedText = PdfTextExtractor(document).extractText();
                      document.dispose();

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Check(cvText: extractedText),
                        ),
                      );
                    },
                    child: const Text('Examination'),
                  ),

                ],
              );
            } else if (state is FilePickerError) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Error: ${state.message}',
                      style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      context.read<FilePickerBloc>().add(PickFileEvent());
                    },
                    child: const Text('Try again'),
                  ),
                ],
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }
}