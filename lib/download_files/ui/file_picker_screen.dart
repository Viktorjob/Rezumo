import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:rezumo/download_files/ui/check.dart';
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
                child: const Text('Выбрать PDF'),
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
                        color: Colors.black,   // цвет рамки
                        width: 5,             // толщина рамки
                      ),
                      borderRadius: BorderRadius.circular(8),  // скругление углов (по желанию)
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
                    child: const Text('Выбрать другой файл'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final filePath = state.filePath; // Путь к PDF

                      // 1. Прочитай файл
                      final bytes = File(filePath).readAsBytesSync();

                      // 2. Загрузи PDF документ
                      final document = PdfDocument(inputBytes: bytes);

                      // 3. Извлеки текст
                      final extractedText = PdfTextExtractor(document).extractText();

                      // 4. Освободи ресурсы
                      document.dispose();

                      // 5. Перейди к экрану Check, передав текст
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Check(cvText: extractedText),
                        ),
                      );
                    },
                    child: const Text('Проверка'),
                  ),

                ],
              );
            } else if (state is FilePickerError) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Ошибка: ${state.message}',
                      style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      context.read<FilePickerBloc>().add(PickFileEvent());
                    },
                    child: const Text('Попробовать снова'),
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