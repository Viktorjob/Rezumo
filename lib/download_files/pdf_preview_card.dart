import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PdfPreviewCard extends StatelessWidget {
  final String filePath;

  const PdfPreviewCard({required this.filePath, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 2,
      width: 300,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: PDFView(
        filePath: filePath,
        enableSwipe: false,
        autoSpacing: false,
        pageSnap: false,
        fitEachPage: true,
        fitPolicy: FitPolicy.BOTH,
      ),
    );
  }
}
