import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:rezumo/download_files/ui/check.dart';
import '../bloc/file_picker_bloc.dart';

class FilePickerScreen extends StatefulWidget {
  const FilePickerScreen({Key? key}) : super(key: key);

  @override
  State<FilePickerScreen> createState() => _FilePickerScreenState();
}

class _FilePickerScreenState extends State<FilePickerScreen> {
  bool _isConverting = false;
  String? _conversionError;
  String? _selectedLevel;
  String _cleanHtmlPreservingStructure(String html) {

    html = html.replaceAll(RegExp(r'<(script|style)[^>]*>[\s\S]*?<\/\1>', caseSensitive: false), '');


    html = html.replaceAllMapped(RegExp(r'<(?!img\b)[^>]+>', caseSensitive: false), (match) {
      return '';
    });

    html = html.replaceAll(RegExp(r'<(style|script|head|meta|link)[^>]*>[\s\S]*?<\/\1>', caseSensitive: false), '');
    html = html.replaceAll(RegExp(r'<(meta|link)[^>]*\/?>', caseSensitive: false), '');


    html = html.replaceAll(RegExp(r'(style|class|id)="[^"]*"', caseSensitive: false), '');


    html = html.replaceAll(RegExp(r'<!--[\s\S]*?-->', multiLine: true), '');


    html = html.replaceAllMapped(RegExp(r'<\/?(div|span)[^>]*>', caseSensitive: false), (match) => '');


    html = html.replaceAll(RegExp(r'<(\w+)>\s*<\/\1>', caseSensitive: false), '');


    html = html.replaceAll(RegExp(r'\s{2,}'), ' ');


    html = html.replaceAll(RegExp(r'<[^>]+>'), '');

    return html.trim();
  }




  Future<String> _convertPdfToHtml(String filePath) async {
    setState(() {
      _isConverting = true;
      _conversionError = null;
    });

    try {
      final pdfFile = File(filePath);
      if (!await pdfFile.exists()) {
        throw Exception('Файл не существует: $filePath');
      }

      final fileSize = await pdfFile.length();
      if (fileSize == 0) throw Exception('PDF файл пустой');
      print("Размер файла: $fileSize байт");

      final uri = Uri.parse('https://v2.convertapi.com/convert/pdf/to/html');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer LKHfjqi7eZw9cFUTsRzqYp7ytxPTjKM7'
        ..fields['StoreFile'] = 'true'
        ..files.add(await http.MultipartFile.fromPath(
          'File',
          filePath,
          filename: 'document.pdf',
        ));

      print("Отправка запроса в ConvertAPI...");
      final response = await request.send();

      if (response.statusCode == 200) {
        final jsonResponse = await response.stream.bytesToString();
        print("Ответ API: $jsonResponse");

        final jsonMap = json.decode(jsonResponse);
        final files = jsonMap['Files'] as List;
        if (files.isEmpty) throw Exception('Нет файлов в ответе API');

        final fileUrl = files.first['Url'] as String;
        print("URL HTML-файла: $fileUrl");

        final htmlResponse = await http.get(Uri.parse(fileUrl));
        if (htmlResponse.statusCode != 200) {
          throw Exception('Ошибка загрузки HTML: ${htmlResponse.statusCode}');
        }

        String htmlContent = htmlResponse.body;
        print("До очистки: ${htmlContent.length} символов");

        final cleanedHtml = _cleanHtmlPreservingStructure(htmlContent);
        print("После очистки: ${cleanedHtml.length} символов");

        return cleanedHtml;
      } else {
        final errorBody = await response.stream.bytesToString();
        throw Exception('Ошибка API (${response.statusCode}): $errorBody');
      }
    } catch (e) {
      print("Ошибка конвертации: $e");
      setState(() {
        _conversionError = e.toString();
      });
      rethrow;
    } finally {
      setState(() {
        _isConverting = false;
      });
    }
  }

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
                onPressed: () => context.read<FilePickerBloc>().add(PickFileEvent()),
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
                      border: Border.all(color: Colors.black, width: 5),
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

                  if (_isConverting) ...[
                    const CircularProgressIndicator(),
                    const SizedBox(height: 10),
                    const Text('Конвертация в процессе...'),
                    const SizedBox(height: 20),
                  ],

                  if (_conversionError != null) ...[
                    const Icon(Icons.error, color: Colors.red, size: 40),
                    const SizedBox(height: 10),
                    Text(
                      'Ошибка конвертации:',
                      style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        _conversionError!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => context.read<FilePickerBloc>().add(PickFileEvent()),
                        child: Text('Выбрать другой файл'),
                      ),
                      SizedBox(width: 20),

                      // Кнопка с выпадающим меню для выбора уровня
                      ElevatedButton(
                        onPressed: _isConverting
                            ? null
                            : () async {
                          if (_selectedLevel == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Пожалуйста, выберите уровень')),
                            );
                            return;
                          }
                          try {
                            final htmlContent = await _convertPdfToHtml(state.filePath);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Check(
                                  cvText: htmlContent,
                                  level: _selectedLevel!,
                                ),
                              ),
                            );
                          } catch (e) {
                            // Ошибка уже обработана
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Анализировать PDF'),
                            const SizedBox(width: 12),
                            // Отображаем выбранный уровень (если есть)
                            if (_selectedLevel != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _selectedLevel!,
                                  style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold),
                                ),
                              ),
                            const SizedBox(width: 8),
                            PopupMenuButton<String>(
                              tooltip: 'Выбрать уровень',
                              onSelected: (value) {
                                setState(() {
                                  _selectedLevel = value;
                                });
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(value: 'Junior', child: Text('Junior')),
                                PopupMenuItem(value: 'Mid', child: Text('Mid')),
                                PopupMenuItem(value: 'Senior', child: Text('Senior')),
                              ],
                              child: const Icon(Icons.arrow_drop_down),
                            ),
                          ],
                        ),
                      ),

                    ],
                  ),

                ],
              );
            } else if (state is FilePickerError) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Ошибка: ${state.message}', style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => context.read<FilePickerBloc>().add(PickFileEvent()),
                    child: const Text('Попробовать снова'),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}