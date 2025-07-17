


class PdfFile {
  final String name;
  final String path;

  PdfFile({required this.name, required this.path});

  Map<String, String> toJson() => {'name': name, 'path': path};

  factory PdfFile.fromJson(Map<String, dynamic> json) =>
      PdfFile(name: json['name'], path: json['path']);
}
