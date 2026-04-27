import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final _storage = FirebaseStorage.instance;

  Future<String> uploadEntryImage({
    required String userId,
    required String entryId,
    required String localPath,
  }) async {
    final file = File(localPath);
    final ref = _storage.ref('users/$userId/entries/$entryId.jpg');
    final task = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return await task.ref.getDownloadURL();
  }

  Future<void> deleteEntryImage(String userId, String entryId) async {
    try {
      await _storage.ref('users/$userId/entries/$entryId.jpg').delete();
    } catch (_) {}
  }
}