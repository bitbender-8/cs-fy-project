import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

/// Confirmation dialog with improved spacing, typography, and styled buttons
Future<bool> showConfirmationDialog(
  BuildContext context,
  String title,
  String message, {
  String confirmButtonText = 'Confirm',
  String cancelButtonText = 'Cancel',
  Color? confirmButtonColor,
  Color? iconColor,
  IconData icon = Icons.help_outline,
}) async {
  if (!context.mounted) {
    debugPrint('showConfirmationDialog: Context is not mounted.');
    return false;
  }

  return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          final ColorScheme colorScheme = Theme.of(dialogContext).colorScheme;

          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            title: Row(
              children: [
                Icon(icon, color: iconColor ?? colorScheme.primary, size: 30),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            content: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            actions: [
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    foregroundColor:
                        colorScheme.onSurface.withValues(alpha: 0.6),
                    side: BorderSide(color: colorScheme.scrim),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(cancelButtonText),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: confirmButtonColor ?? colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(confirmButtonText),
                ),
              ),
            ],
          );
        },
      ) ??
      false;
}

/// Success dialog with updated layout and button styling
Future<void> showSuccessDialog(BuildContext context, String message) async {
  if (!context.mounted) return;

  final colorScheme = Theme.of(context).colorScheme;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 30),
            SizedBox(width: 10),
            Text(
              'Success',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.green,
              ),
            ),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ),
        ],
      );
    },
  );
}

String formatDate(DateTime? date, {bool isShort = true}) {
  if (date == null) return 'N/A';
  return isShort
      ? DateFormat("dd/mm/yy").format(date)
      : DateFormat('MMM dd, yyyy').format(date);
}
