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
