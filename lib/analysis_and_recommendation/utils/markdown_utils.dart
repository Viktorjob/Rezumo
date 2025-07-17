String cleanMarkdown(String input) {
  return input
      .replaceAll(RegExp(r'\\\d'), '')
      .replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'\1')
      .replaceAll(RegExp(r'#+\s*'), '')
      .replaceAll(RegExp(r'^\s*-\s*', multiLine: true), '')
      .replaceAll(RegExp(r'`{3}.*?`{3}', dotAll: true), '')
      .replaceAll(RegExp(r'[•\-–●▪◉❌✅✔️➤]'), '')
      .replaceAll(RegExp(r'\n{2,}'), '\n\n')
      .trim();
}
