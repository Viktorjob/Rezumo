import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'html_cleaner_service.dart';

class PdfConverterService {
  final String apiKey;
  final HtmlCleanerService _cleaner;

  PdfConverterService({required this.apiKey, HtmlCleanerService? cleaner})
      : _cleaner = cleaner ?? HtmlCleanerService();

  Future<String> convertPdfToHtml(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File does not exist: $filePath');
    }

    final uri = Uri.parse('https://v2.convertapi.com/convert/pdf/to/html');

    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $apiKey'
      ..fields['StoreFile'] = 'true'
      ..files.add(await http.MultipartFile.fromPath('File', filePath));

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception('Conversion failed: $body');
    }

    final result = json.decode(body);
    final files = result['Files'] as List;
    if (files.isEmpty) throw Exception('No files returned.');

    final fileUrl = files.first['Url'];
    final htmlResponse = await http.get(Uri.parse(fileUrl));

    if (htmlResponse.statusCode != 200) {
      throw Exception('Failed to fetch converted HTML.');
    }

    return _cleaner.clean(htmlResponse.body);
  }
}
