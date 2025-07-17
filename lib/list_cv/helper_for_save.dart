import 'dart:convert';

import 'package:rezumo/list_cv/models/pdf_file.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PdfStorage {
  static const _key = 'saved_pdfs';

  static Future<void> saveFiles(List<PdfFile> files) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = files.map((f) => f.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  static Future<List<PdfFile>> loadFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];

    final List<dynamic> decoded = jsonDecode(jsonString);
    return decoded.map((item) => PdfFile.fromJson(item)).toList();
  }
}
