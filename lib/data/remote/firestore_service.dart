import 'package:cloud_firestore/cloud_firestore.dart';
import '../local/models/entry_model.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  Future<void> saveEntry(EntryModel entry) async {
    await _db
        .collection('users')
        .doc(entry.userId)
        .collection('entries')
        .doc(entry.id)
        .set(entry.toFirestore());
  }

  Future<void> deleteEntry(String userId, String entryId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('entries')
        .doc(entryId)
        .delete();
  }

  Future<List<EntryModel>> fetchEntries(String userId) async {
    final snap = await _db
        .collection('users')
        .doc(userId)
        .collection('entries')
        .orderBy('createdAt', descending: true)
        .get();

    return snap.docs.map((doc) {
      final data = doc.data();
      return EntryModel(
        id: doc.id,
        userId: userId,
        title: data['title'] ?? '',
        note: data['note'],
        category: data['category'],
        mood: data['mood'],
        latitude: data['latitude']?.toDouble(),
        longitude: data['longitude']?.toDouble(),
        locationName: data['locationName'],
        remoteImageUrl: data['remoteImageUrl'],
        createdAt: DateTime.parse(data['createdAt']),
        isSynced: true,
      );
    }).toList();
  }

  Future<void> updateEntry(String userId, String entryId,
      Map<String, dynamic> data) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('entries')
        .doc(entryId)
        .update(data);
  }
}