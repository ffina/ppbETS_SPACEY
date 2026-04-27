import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/local/models/entry_model.dart';
import '../../../shared/providers/entry_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DetailScreen extends StatelessWidget {
  final EntryModel entry;
  const DetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.bg,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.4),
                  border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
                ),
                child: const Icon(Icons.arrow_back,
                    color: AppColors.textPrimary, size: 18),
              ),
            ),
            actions: [
              PopupMenuButton(
                color: AppColors.bgCard,
                icon: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.4),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.1), width: 0.5),
                  ),
                  child: const Icon(Icons.more_vert,
                      color: AppColors.textPrimary, size: 18),
                ),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete',
                        style: TextStyle(color: AppColors.error)),
                  ),
                ],
                onSelected: (v) async {
                  if (v == 'delete') {
                    final uid = FirebaseAuth.instance.currentUser!.uid;
                    await context
                        .read<EntryProvider>()
                        .deleteEntry(uid, entry.id);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (entry.localImagePath != null)
                    Image.file(File(entry.localImagePath!), fit: BoxFit.cover)
                  else if (entry.remoteImageUrl != null)
                    Image.network(entry.remoteImageUrl!, fit: BoxFit.cover)
                  else
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF3D2B1A), Color(0xFF1E1510)],
                        ),
                      ),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, AppColors.bg],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(children: [
                  if (entry.category != null) _tag(entry.category!, isGold: true),
                  if (entry.mood != null) ...[
                    const SizedBox(width: 6),
                    _tag(entry.mood!, isGold: false),
                  ],
                ]),
                const SizedBox(height: 10),
                Text(entry.title,
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 26, color: AppColors.textPrimary,
                        height: 1.3)),
                if (entry.locationName != null) ...[
                  const SizedBox(height: 6),
                  Row(children: [
                    Icon(Icons.location_on_outlined,
                        color: AppColors.textMuted, size: 12),
                    const SizedBox(width: 4),
                    Text(entry.locationName!,
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 11)),
                  ]),
                ],
                const SizedBox(height: 20),
                Divider(color: Colors.white.withOpacity(0.07)),
                const SizedBox(height: 16),
                if (entry.note != null && entry.note!.isNotEmpty)
                  Text('"${entry.note}"',
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 14, color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic, height: 1.8)),
                const SizedBox(height: 20),
                Wrap(spacing: 10, runSpacing: 10, children: [
                  _metaCard('Date',
                      DateFormat('MMM d, yyyy').format(entry.createdAt)),
                  _metaCard('Time', DateFormat('HH:mm').format(entry.createdAt)),
                  if (entry.locationName != null)
                    _metaCard('Location', entry.locationName!),
                  _metaCard('Synced', entry.isSynced ? 'Yes' : 'Pending'),
                ]),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String label, {required bool isGold}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isGold
            ? AppColors.gold.withOpacity(0.15)
            : Colors.green.withOpacity(0.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: isGold
              ? AppColors.gold.withOpacity(0.35)
              : Colors.green.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Text(label,
          style: TextStyle(
              color: isGold ? AppColors.gold : const Color(0xFF7AB882),
              fontSize: 10, fontWeight: FontWeight.w500,
              letterSpacing: 0.5)),
    );
  }

  Widget _metaCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.07), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: TextStyle(
                  color: AppColors.gold, fontSize: 13,
                  fontWeight: FontWeight.w500)),
          Text(label,
              style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
        ],
      ),
    );
  }
}