import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/entry_provider.dart';
import '../../../data/local/models/entry_model.dart';
import '../../capture/screens/capture_screen.dart';
import '../../explore/screens/explore_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../detail/screens/detail_screen.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  final _pages = const [_HomeTab(), ExploreScreen(), ProfileScreen()];

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      context.read<EntryProvider>().loadEntries(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: _pages[_tab],
      bottomNavigationBar: _buildNav(),
    );
  }

  Widget _buildNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1714).withOpacity(0.97),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06), width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.home_outlined, 'Home'),
              _navItem(1, Icons.search_outlined, 'Explore'),
              _navPlus(),
              _navItem(2, Icons.person_outline, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int idx, IconData icon, String label) {
    final active = _tab == idx;
    return GestureDetector(
      onTap: () => setState(() => _tab = idx),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: active ? AppColors.gold.withOpacity(0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon,
                color: active ? AppColors.gold : AppColors.textMuted, size: 20),
          ),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  color: active ? AppColors.gold : AppColors.textMuted,
                  fontSize: 10, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _navPlus() {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const CaptureScreen())),
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.gold.withOpacity(0.12),
          border: Border.all(color: AppColors.gold.withOpacity(0.4), width: 1.5),
        ),
        child: const Icon(Icons.add, color: AppColors.gold, size: 22),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EntryProvider>();
    final entries = provider.entries;
    final now = DateFormat('EEEE, MMMM d').format(DateTime.now());

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('spacey',
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 24, color: AppColors.textPrimary)),
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                        colors: [Color(0xFFC9A96E), Color(0xFF8B6340)]),
                  ),
                  child: Center(
                    child: Text(
                      FirebaseAuth.instance.currentUser?.displayName
                          ?.substring(0, 1).toUpperCase() ?? 'S',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Text(now,
                style: TextStyle(color: AppColors.textMuted, fontSize: 11,
                    letterSpacing: 0.5)),
          ),
        ),
        if (entries.isNotEmpty)
          SliverToBoxAdapter(child: _FeaturedCard(entry: entries.first)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('RECENT LOGS',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 10,
                        letterSpacing: 1.5, fontWeight: FontWeight.w500)),
                Text('see all',
                    style: TextStyle(color: AppColors.gold, fontSize: 10)),
              ],
            ),
          ),
        ),
        if (provider.isLoading)
          const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(
                    strokeWidth: 1.5, color: AppColors.gold),
              ),
            ),
          )
        else if (entries.isEmpty)
          SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(children: [
                  Icon(Icons.photo_camera_outlined,
                      color: AppColors.textMuted, size: 40),
                  const SizedBox(height: 12),
                  Text('No memories yet.',
                      style: TextStyle(color: AppColors.textMuted)),
                  const SizedBox(height: 4),
                  Text('Tap + to add your first log.',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ]),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => _LogItem(entry: entries[i]),
              childCount: entries.length,
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final EntryModel entry;
  const _FeaturedCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => DetailScreen(entry: entry))),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF3D2B1A), Color(0xFF1E1510)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            if (entry.localImagePath != null || entry.remoteImageUrl != null)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: entry.remoteImageUrl != null
                      ? Image.network(entry.remoteImageUrl!, fit: BoxFit.cover)
                      : Image.file(File(entry.localImagePath!), fit: BoxFit.cover),
                ),
              ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 14, left: 16, right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: AppColors.gold.withOpacity(0.4), width: 0.5),
                    ),
                    child: Text('LATEST MEMORY',
                        style: TextStyle(color: AppColors.gold, fontSize: 9,
                            letterSpacing: 1.5, fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(height: 5),
                  Text(entry.title,
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 18, color: AppColors.textPrimary)),
                  Text(
                      '${DateFormat('MMM d').format(entry.createdAt)} · ${entry.locationName ?? ''}',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogItem extends StatelessWidget {
  final EntryModel entry;
  const _LogItem({required this.entry});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => DetailScreen(entry: entry))),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.07), width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.bgSurface,
                image: entry.localImagePath != null
                    ? DecorationImage(
                        image: FileImage(File(entry.localImagePath!)),
                        fit: BoxFit.cover)
                    : entry.remoteImageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(entry.remoteImageUrl!),
                          fit: BoxFit.cover)
                      : null,
              ),
              child: (entry.localImagePath == null && entry.remoteImageUrl == null)
                  ? Icon(Icons.photo_outlined,
                      color: AppColors.textMuted, size: 20)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.title,
                      style: TextStyle(color: AppColors.textPrimary,
                          fontSize: 13, fontWeight: FontWeight.w500),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(
                    '${DateFormat('MMM d').format(entry.createdAt)}'
                    '${entry.category != null ? ' · ${entry.category}' : ''}',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 10),
                  ),
                ],
              ),
            ),
            Container(
              width: 8, height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: entry.isSynced
                    ? AppColors.gold.withOpacity(0.5)
                    : Colors.orange.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}