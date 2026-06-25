import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true);
  for (var entity in files) {
    if (entity is File && entity.path.endsWith('.dart')) {
      var content = entity.readAsStringSync();
      var original = content;
      content = content.replaceAllMapped(RegExp(r'const\s+([A-Z])'), (m) => m.group(1)!);
      content = content.replaceAll(RegExp(r'const\s+\['), '[');
      content = content.replaceAll(RegExp(r'const\s+\{'), '{');
      if (content != original) {
        entity.writeAsStringSync(content);
      }
    }
  }
  print('Done');
}
