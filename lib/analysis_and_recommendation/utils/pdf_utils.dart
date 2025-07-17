import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';


class PdfUtils {
  static Future<String?> generateAndSavePdf(String htmlContent) async {
    final uri = Uri.parse('https://uk-v2.convertapi.com/convert/html/to/pdf');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer Your api-key '
      ..fields['StoreFile'] = 'true'
      ..files.add(http.MultipartFile.fromString('File', htmlContent, filename: 'resume.html'));

    final response = await request.send();

    if (response.statusCode == 200) {
      final json = await response.stream.bytesToString();
      final url = jsonDecode(json)['Files'][0]['Url'];
      final bytes = await http.readBytes(Uri.parse(url));
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/updated_resume.pdf';
      await File(path).writeAsBytes(bytes);
      return path;
    } else {
      return null;
    }
  }
}
