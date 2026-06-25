import 'dart:io';
import 'dart:math';

// Convert all relative imports to package imports
// This is the cleanest fix for deep nesting issues after refactoring

const packageName = 'motolog_mobile';

String resolveRelativeImport(String fromFilePath, String relativePath) {
  // fromFilePath: e.g. lib/features/auth/screens/login_screen.dart
  // relativePath: e.g. ../../core/constants/app_colors.dart
  
  // Normalize separators
  fromFilePath = fromFilePath.replaceAll('\\', '/');
  
  // Get the directory of the current file relative to lib/
  var fromDir = fromFilePath.replaceAll('\\', '/');
  // Remove 'lib/' prefix for calculation
  if (fromDir.startsWith('lib/')) {
    fromDir = fromDir.substring(4);
  }
  // Get directory (remove filename)
  final lastSlash = fromDir.lastIndexOf('/');
  fromDir = lastSlash >= 0 ? fromDir.substring(0, lastSlash) : '';
  
  // Split current dir into parts
  final parts = fromDir.isEmpty ? <String>[] : fromDir.split('/');
  
  // Resolve relative path
  final relParts = relativePath.split('/');
  final resolvedParts = List<String>.from(parts);
  
  for (final part in relParts) {
    if (part == '..') {
      if (resolvedParts.isNotEmpty) resolvedParts.removeLast();
    } else if (part != '.') {
      resolvedParts.add(part);
    }
  }
  
  return resolvedParts.join('/');
}

void main() {
  var count = 0;
  var updated = 0;
  
  final libDir = Directory('lib');
  for (final entity in libDir.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    count++;
    
    final filePath = entity.path.replaceAll('\\', '/');
    var content = entity.readAsStringSync();
    final original = content;
    
    final lines = content.split('\n');
    final newLines = lines.map((line) {
      // Match relative imports: import '../...'.dart' or import './...dart'
      final relImportMatch = RegExp(r"^import '(\.\.?/[^']+\.dart)';").firstMatch(line);
      if (relImportMatch != null) {
        final relPath = relImportMatch.group(1)!;
        final resolved = resolveRelativeImport(filePath, relPath);
        return "import 'package:$packageName/$resolved';";
      }
      return line;
    }).toList();
    
    content = newLines.join('\n');
    
    if (content != original) {
      entity.writeAsStringSync(content);
      updated++;
      print('Updated: ${entity.path}');
    }
  }
  
  print('\nScanned $count files, updated $updated files.');
}
