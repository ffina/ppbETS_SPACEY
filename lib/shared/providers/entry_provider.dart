import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../data/local/database_helper.dart';
import '../../data/local/models/entry_model.dart';
import '../../data/remote/firestore_service.dart';
import '../../data/remote/storage_service.dart';

class EntryProvider extends ChangeNotifier {
  final _db = DatabaseHelper.instance;
  final _firestore = FirestoreService();
  final _storage = StorageService();

  List<EntryModel> _entries = [];
  bool _isLoading = false;

  List<EntryModel> get entries => _entries;
  bool get isLoading => _isLoading;

  Future<void> loadEntries(String userId) async {
    _isLoading = true;
    notifyListeners();
    _entries = await _db.getEntriesByUser(userId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addEntry({
    required String userId,
    required String title,
    String? note,
    String? category,
    String? mood,
    double? latitude,
    double? longitude,
    String? locationName,
    String? localImagePath,
  }) async {
    final id = const Uuid().v4();
    final entry = EntryModel(
      id: id,
      userId: userId,
      title: title,
      note: note,
      category: category,
      mood: mood,
      latitude: latitude,
      longitude: longitude,
      locationName: locationName,
      localImagePath: localImagePath,
      createdAt: DateTime.now(),
      isSynced: false,
    );

    await _db.insertEntry(entry);
    _entries.insert(0, entry);
    notifyListeners();

    // Sync ke Firebase di background
    _syncEntry(entry);
  }

  Future<void> _syncEntry(EntryModel entry) async {
    final conn = await Connectivity().checkConnectivity();
    if (conn == ConnectivityResult.none) return;

    try {
      // SKIP IMAGE UPLOAD FOR NOW
      // String? remoteUrl;
      // if (entry.localImagePath != null) {
      //   remoteUrl = await _storage.uploadEntryImage(
      //     userId: entry.userId,
      //     entryId: entry.id,
      //     localPath: entry.localImagePath!,
      //   );
      // }

      final synced = entry.copyWith(
        remoteImageUrl: null, // remoteUrl,
        isSynced: true,
      );

      // Update di Firestore 
      await _firestore.saveEntry(synced);
      // Update di local DB
      await _db.updateEntry(synced);

      final idx = _entries.indexWhere((e) => e.id == entry.id);
      if (idx != -1) {
        _entries[idx] = synced;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Sync error: $e');
    }
  }

  Future<void> deleteEntry(String userId, String entryId) async {
    await _db.deleteEntry(entryId);
    await _firestore.deleteEntry(userId, entryId);
    await _storage.deleteEntryImage(userId, entryId);
    _entries.removeWhere((e) => e.id == entryId);
    notifyListeners();
  }

  Future<void> updateEntry(EntryModel updated) async {
    await _db.updateEntry(updated);
    final idx = _entries.indexWhere((e) => e.id == updated.id);
    if (idx != -1) {
      _entries[idx] = updated;
      notifyListeners();
    }
    final conn = await Connectivity().checkConnectivity();
    if (conn != ConnectivityResult.none) {
      await _firestore.updateEntry(updated.userId, updated.id, updated.toFirestore());
    }
  }
}