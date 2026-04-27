import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/remote/auth_service.dart';
import '../../../shared/providers/entry_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../../detail/screens/detail_screen.dart';
import 'dart:io';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final entries = context.watch<EntryProvider>().entries;
    final cities = entries.map((e) => e.locationName ?? '').toSet().length;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 24),
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                        colors: [Color(0xFFC9A96E), Color(0xFF8B6340)]),
                    border: Border.all(
                        color: AppColors.gold.withOpacity(0.35), width: 2),
                  ),
                  child: Center(
                    child: Text(
                      user?.displayName?.substring(0, 1).toUpperCase() ?? 'S',
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 26, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(user?.displayName ?? 'Spacey User',
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 18, color: AppColors.textPrimary)),
                Text('@${user?.email?.split('@').first ?? 'user'}.spacey',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.07), width: 0.5),
                  ),
                  child: Row(
                    children: [
                      _stat('${entries.length}', 'Logs'),
                      _statDivider(),
                      _stat('$cities', 'Tempat'),
                      // _statDivider(),
                      // _stat(
                      //   entries.isEmpty
                      //       ? '0'
                      //       : '${DateTime.now().difference(entries.last.createdAt).inDays ~/ 30 + 1}',
                      //   'Bulan',
                      // ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('MEMORY GRID',
                          style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 10, letterSpacing: 1.5,
                              fontWeight: FontWeight.w500)),
                      Text('filter',
                          style: TextStyle(
                              color: AppColors.gold, fontSize: 10)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            sliver: entries.isEmpty
                ? SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Text('No memories yet.',
                            style: TextStyle(color: AppColors.textMuted)),
                      ),
                    ),
                  )
                : SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _GridItem(entry: entries[i]),
                      childCount: entries.length,
                    ),
                  ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: GestureDetector(
                onTap: () async {
                  await context.read<AuthService>().logout();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (_) => false,
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: AppColors.error.withOpacity(0.3), width: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text('Sign out',
                        style: TextStyle(
                            color: AppColors.error, fontSize: 13)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String num, String label) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(children: [
          Text(num,
              style: GoogleFonts.playfairDisplay(
                  fontSize: 22, color: AppColors.gold)),
          Text(label,
              style: TextStyle(
                  color: AppColors.textMuted, fontSize: 9,
                  letterSpacing: 1)),
        ]),
      ),
    );
  }

  Widget _statDivider() {
    return Container(
        width: 0.5, height: 40, color: Colors.white.withOpacity(0.07));
  }
}

class _GridItem extends StatelessWidget {
  final entry;
  const _GridItem({required this.entry});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailScreen(entry: entry))),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF3D2B1A).withOpacity(0.9),
              const Color(0xFF1E1510),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: entry.remoteImageUrl != null
                    ? Image.network(entry.remoteImageUrl!, fit: BoxFit.cover)
                    : entry.localImagePath != null
                        ? Image.file(File(entry.localImagePath!), fit: BoxFit.cover)
                        : Container(color: Colors.white.withOpacity(0.05)),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
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
              bottom: 8, left: 8, right: 8,
              child: Text(entry.title,
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 11, color: AppColors.textPrimary,
                      fontStyle: FontStyle.italic),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}