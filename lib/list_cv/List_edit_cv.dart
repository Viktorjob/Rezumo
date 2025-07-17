
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

import 'package:rezumo/list_cv/helper_for_save.dart';
import 'package:rezumo/list_cv/models/pdf_file.dart';




class EditList extends StatefulWidget {
  const EditList({Key? key, required List<PdfFile> pdfFiles}) : super(key: key);

  @override
  State<EditList> createState() => _EditListState();
}

class _EditListState extends State<EditList> {
  List<PdfFile> _pdfFiles = [];

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }
  void _editFileName(int index) async {
    final TextEditingController controller = TextEditingController(text: _pdfFiles[index].name);

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename File'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter new name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Save')),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty) {
      setState(() {
        _pdfFiles[index] = PdfFile(name: newName, path: _pdfFiles[index].path);
      });


      await PdfStorage.saveFiles(_pdfFiles);
    }
  }

  void _loadFiles() async {
    final loaded = await PdfStorage.loadFiles();
    setState(() {
      _pdfFiles = loaded.cast<PdfFile>();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('List of resumes')),
      body: _pdfFiles.isEmpty
          ? const Center(child: Text('List is empty'))
          : ListView.builder(
        itemCount: _pdfFiles.length,
        itemBuilder: (context, index) {
          final file = _pdfFiles[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              title: Text(file.name),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editFileName(index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.open_in_new),
                    onPressed: () => OpenFile.open(file.path),
                  ),
                ],
              ),
            ),

          );

        },
      ),
    );
  }
}
