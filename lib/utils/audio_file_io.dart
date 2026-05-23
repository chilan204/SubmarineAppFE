import 'dart:io';

Future<List<int>> readAudioBytes(String path) => File(path).readAsBytes();

Future<void> deleteAudioFile(String path) async {
  try {
    await File(path).delete();
  } catch (_) {}
}
