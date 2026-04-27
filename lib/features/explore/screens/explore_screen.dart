import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/local/models/entry_model.dart';
import '../../../shared/providers/entry_provider.dart';
import '../../detail/screens/detail_screen.dart';
import 'dart:io';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _query = '';
  String? _selectedCat;
  final _cats = ['Café', 'Kuliner', 'Nature', 'Hiburan', 'Lainnya'];

  @override
  Widget build(BuildContext context) {
    final all = context.watch<EntryProvider>().entries;
    final filtered = all.where((e) {
      final matchQ = _query.isEmpty ||
          e.title.toLowerCase().contains(_query.toLowerCase()) ||
          (e.note?.toLowerCase().contains(_query.toLowerCase()) ?? false);
      final matchC = _selectedCat == null || e.category == _selectedCat;
      return matchQ && matchC;
    }).toList();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Explore',
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 26, color: AppColors.textPrimary)),
                Text('discover your memories',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: AppColors.textMuted, size: 18),
                hintText: 'Search places, notes...',
                hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
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
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _catChip(null, 'All'),
                ..._cats.map((c) => _catChip(c, c)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text('No entries found.',
                        style: TextStyle(color: AppColors.textMuted)))
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => _GridCard(entry: filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _catChip(String? val, String label) {
    final sel = _selectedCat == val;
    return GestureDetector(
      onTap: () => setState(() => _selectedCat = val),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: sel ? AppColors.gold.withOpacity(0.15) : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: sel ? AppColors.gold.withOpacity(0.4) : Colors.white.withOpacity(0.08),
            width: 0.5,
          ),
        ),
        child: Text(label,
            style: TextStyle(
                color: sel ? AppColors.gold : AppColors.textMuted,
                fontSize: 11, fontWeight: FontWeight.w500)),
      ),
    );
  }
}

class _GridCard extends StatelessWidget {
  final EntryModel entry;
  const _GridCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => DetailScreen(entry: entry))),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: [Color(0xFF3D2B1A), Color(0xFF2A1E12)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            if (entry.remoteImageUrl != null || entry.localImagePath != null)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: entry.remoteImageUrl != null
                      ? Image.network(entry.remoteImageUrl!, fit: BoxFit.cover)
                      : Image.file(File(entry.localImagePath!), fit: BoxFit.cover),
                ),
              ),
              
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent, 
                      Colors.black.withOpacity(0.5), 
                      Colors.black.withOpacity(0.8), 
                    ],
                    
                    begin: Alignment.topCenter, 
                    end: Alignment.bottomCenter, 
                    stops: const [0.0, 0.6, 1.0], 
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 10, left: 10, right: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.title,
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 12, color: AppColors.textPrimary,
                          fontStyle: FontStyle.italic),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  if (entry.locationName != null)
                    Text(entry.locationName!,
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 9),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}