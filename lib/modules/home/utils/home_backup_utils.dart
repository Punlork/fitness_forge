import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:forge/services/backup/backup_service.dart';

class HomeBackupUtils {
  const HomeBackupUtils._();

  static Future<String?> handleExportBackup({
    required BuildContext context,
    required String? lastBackupDirectory,
    required void Function(String message) showSnackBar,
  }) async {
    try {
      final initialDirectory = lastBackupDirectory ??
          await BackupService.instance.getDefaultBackupDirectoryPath();
      final suggestedName = BackupService.instance.buildBackupFileName();
      final backupBytes = await BackupService.instance.buildBackupBytes();
      final selectedPath = await FilePicker.saveFile(
        dialogTitle: 'Choose backup destination',
        fileName: suggestedName,
        initialDirectory: initialDirectory,
        bytes: backupBytes,
        type: FileType.custom,
        allowedExtensions: const ['json'],
      );

      if (selectedPath == null) {
        showSnackBar('Export cancelled.');
        return lastBackupDirectory;
      }

      showSnackBar('Backup exported successfully.');
      return initialDirectory;
    } on BackupException catch (error) {
      showSnackBar('Export failed: ${error.message}');
      return lastBackupDirectory;
    } catch (_) {
      showSnackBar('Export failed. Please try again.');
      return lastBackupDirectory;
    }
  }

  static Future<String?> handleImportBackup({
    required BuildContext context,
    required String? lastBackupDirectory,
    required void Function(String message) showSnackBar,
    required Future<void> Function() onImportApplied,
  }) async {
    final shouldImport = await _confirmImportBackup(context);
    if (!shouldImport) {
      return lastBackupDirectory;
    }

    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json'],
      initialDirectory: lastBackupDirectory,
    );
    final path = picked?.files.single.path;
    if (path == null) {
      return lastBackupDirectory;
    }

    try {
      await BackupService.instance.importBackupFromPath(path);
      await onImportApplied();
      showSnackBar('Backup restored successfully.');
      return lastBackupDirectory;
    } on BackupException catch (error) {
      showSnackBar('Import failed: ${error.message}');
      return lastBackupDirectory;
    } catch (_) {
      showSnackBar('Import failed. Please try again.');
      return lastBackupDirectory;
    }
  }

  static Future<bool> _confirmImportBackup(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Import backup'),
          content: const Text(
            'This will replace all local workout and profile data with the selected backup file.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Replace data'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }
}
