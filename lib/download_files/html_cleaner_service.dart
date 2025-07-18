class HtmlCleanerService {
  String clean(String html) {
    html = _removeScriptAndStyleTags(html);
    html = _stripAttributes(html);
    html = _removeEmptyTags(html);
    html = _stripAllTags(html);
    return html.trim();
  }

  String _removeScriptAndStyleTags(String html) {
    html = html.replaceAll(RegExp(r'<(script|style)[^>]*>[\s\S]*?<\/\1>', caseSensitive: false), '');
    html = html.replaceAll(RegExp(r'<(meta|link)[^>]*\/?>', caseSensitive: false), '');
    return html;
  }

  String _stripAttributes(String html) {
    return html.replaceAll(RegExp(r'(style|class|id)="[^"]*"', caseSensitive: false), '');
  }

  String _removeEmptyTags(String html) {
    return html.replaceAll(RegExp(r'<(\w+)>\s*<\/\1>', caseSensitive: false), '');
  }

  String _stripAllTags(String html) {
    return html.replaceAll(RegExp(r'<[^>]+>'), '');
  }
}
