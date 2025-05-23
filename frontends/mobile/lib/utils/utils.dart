import 'package:flutter/material.dart';

String toTitleCase(String text) {
  if (text.isEmpty) {
    return '';
  }

  String cleanedText = text.replaceAll(RegExp(r'\s+'), ' ').trim();

  if (cleanedText.isEmpty) {
    return '';
  }

  List<String> words = cleanedText.split(' ');
  List<String> titleCaseWords = words
      .map(
        (word) => word.isEmpty
            ? ''
            : word[0].toUpperCase() + word.substring(1).toLowerCase(),
      )
      .toList();

  return titleCaseWords.join(' ');
}

IconData getFileIconFromFileName(String fileName) {
  final extension = fileName.split('.').last.toLowerCase();
  switch (extension) {
    case 'pdf':
      return Icons.picture_as_pdf;
    case 'jpg':
    case 'jpeg':
      return Icons.image;
    case 'png':
      return Icons.image;
    case 'doc':
    case 'docx':
      return Icons.description;
    case 'xls':
    case 'xlsx':
      return Icons.grid_on;
    case 'txt':
      return Icons.text_snippet;
    default:
      return Icons.insert_drive_file;
  }
}
