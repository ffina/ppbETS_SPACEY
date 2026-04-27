import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spacey/data/remote/notification_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/entry_provider.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});
  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  final _titleCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String? _imagePath;
  String? _locationName;
  double? _lat, _lon;
  String _category = 'Café';
  String _mood = 'Tenang';
  bool _loading = false;
  bool _gettingLocation = false;

  final _categories = ['Café', 'Kuliner', 'Nature', 'Hiburan', 'Lainnya'];
  final _moods = ['Tenang', 'Excited', 'Nostalgic', 'Happy', 'Chill'];

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    setState(() => _gettingLocation = true);
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) return;

      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium);
      _lat = pos.latitude;
      _lon = pos.longitude;

      final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        setState(() {
          _locationName =
              '${p.subLocality ?? p.locality ?? ''}, ${p.administrativeArea ?? ''}';
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _gettingLocation = false);
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: source, imageQuality: 80);
    if (xFile != null) setState(() => _imagePath = xFile.path);
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Title cannot be empty')));
      return;
    }
    setState(() => _loading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await context.read<EntryProvider>().addEntry(
        userId: uid,
        title: _titleCtrl.text.trim(),
        note: _noteCtrl.text.trim(),
        category: _category,
        mood: _mood,
        // latitude: _lat,
        // longitude: _lon,
        latitude: null,
        longitude: null,
        locationName: _locationName,
        localImagePath: _imagePath,
      );
      // if (mounted) Navigator.pop(context);
      // NOTIFICATION ==============
      if (mounted) {
        await NotificationService.showInstant(
          title: 'Memory Captured! ✨',
          body: 'Momen berhargamu di ${_titleCtrl.text} sudah aman tersimpan.'
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save to Firebase: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0C0B),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImagePicker(),
                    const SizedBox(height: 20),
                    _buildField('Nama tempat', _titleCtrl,
                        hint: 'e.g., Kopitown Darmo'),
                    const SizedBox(height: 16),
                    _buildCategoryPicker(),
                    const SizedBox(height: 16),
                    _buildMoodPicker(),
                    const SizedBox(height: 16),
                    _buildNoteField(),
                    const SizedBox(height: 16),
                    _buildLocationChip(),
                    const SizedBox(height: 28),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
                border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
              ),
              child: const Icon(Icons.chevron_left,
                  color: AppColors.textPrimary, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('New memory',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 18, color: AppColors.textPrimary)),
              Text('capture this moment',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: () => _showImageSourceSheet(),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.bgCard,
          border: Border.all(color: Colors.white.withOpacity(0.08), width: 0.5),
        ),
        child: _imagePath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(File(_imagePath!), fit: BoxFit.cover))
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_outlined,
                      color: AppColors.gold, size: 32),
                  const SizedBox(height: 8),
                  Text('Tap to add photo',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  Text('Camera or Gallery',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                ],
              ),
      ),
    );
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: AppColors.gold),
              title: Text('Camera',
                  style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: AppColors.gold),
              title: Text('Gallery',
                  style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, {String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: TextStyle(
                color: AppColors.textMuted, fontSize: 9, letterSpacing: 1.5)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textMuted),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1), width: 0.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1), width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.gold, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildNoteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('CATATAN',
            style: TextStyle(color: AppColors.textMuted, fontSize: 9,
                letterSpacing: 1.5)),
        const SizedBox(height: 6),
        TextField(
          controller: _noteCtrl,
          maxLines: 4,
          style: GoogleFonts.playfairDisplay(
              color: AppColors.textSecondary, fontSize: 13,
              fontStyle: FontStyle.italic),
          decoration: InputDecoration(
            hintText: '"Ceritakan momen ini..."',
            hintStyle: GoogleFonts.playfairDisplay(
                color: AppColors.textMuted, fontStyle: FontStyle.italic),
            filled: true,
            fillColor: Colors.white.withOpacity(0.04),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.08), width: 0.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.08), width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.gold, width: 1),
            ),
            contentPadding: const EdgeInsets.all(14),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('KATEGORI',
            style: TextStyle(color: AppColors.textMuted, fontSize: 9,
                letterSpacing: 1.5)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: _categories.map((c) {
            final sel = c == _category;
            return GestureDetector(
              onTap: () => setState(() => _category = c),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: sel ? AppColors.gold.withOpacity(0.15) : Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    color: sel ? AppColors.gold.withOpacity(0.4) : Colors.white.withOpacity(0.08),
                    width: 0.5,
                  ),
                ),
                child: Text(c,
                    style: TextStyle(
                        color: sel ? AppColors.gold : AppColors.textSecondary,
                        fontSize: 12, fontWeight: FontWeight.w500)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMoodPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('MOOD',
            style: TextStyle(color: AppColors.textMuted, fontSize: 9,
                letterSpacing: 1.5)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: _moods.map((m) {
            final sel = m == _mood;
            return GestureDetector(
              onTap: () => setState(() => _mood = m),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: sel ? AppColors.gold.withOpacity(0.12) : Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    color: sel ? AppColors.gold.withOpacity(0.35) : Colors.white.withOpacity(0.07),
                    width: 0.5,
                  ),
                ),
                child: Text(m,
                    style: TextStyle(
                        color: sel ? AppColors.gold : AppColors.textMuted,
                        fontSize: 12)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLocationChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 0.5),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on_outlined, color: AppColors.gold, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: _gettingLocation
                ? Text('Getting location...',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12))
                : Text(_locationName ?? 'Location not available',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ),
          if (_gettingLocation)
            const SizedBox(width: 14, height: 14,
                child: CircularProgressIndicator(strokeWidth: 1.5,
                    color: AppColors.gold))
          else
            GestureDetector(
              onTap: _getLocation,
              child: Icon(Icons.refresh, color: AppColors.textMuted, size: 16),
            ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _loading ? null : _save,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.gold,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: _loading
              ? const SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Color(0xFF1A1714)))
              : Text('Save memory',
                  style: TextStyle(
                      color: const Color(0xFF1A1714),
                      fontSize: 15, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}