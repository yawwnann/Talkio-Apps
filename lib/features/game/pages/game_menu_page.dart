import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/anak_model.dart';
import '../../../core/models/game_recommendation_model.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/parent_bottom_nav.dart';
import '../../anak/providers/anak_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/game_recommendation_provider.dart';

/// Game Menu Page
/// Menu game: pilih anak â†’ tampilkan rekomendasi game berdasarkan umur
class GameMenuPage extends ConsumerStatefulWidget {
  const GameMenuPage({super.key});

  @override
  ConsumerState<GameMenuPage> createState() => _GameMenuPageState();
}

class _GameMenuPageState extends ConsumerState<GameMenuPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch children list if not loaded
      final user = ref.read(currentUserProvider);
      if (user != null) {
        ref.read(anakProvider.notifier).getAnakList(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final anakState = ref.watch(anakProvider);
    final selectedAnak = anakState.selectedAnak;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: 'Game Edukasi',
        showBackButton: false,
        showLogo: true,
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildChildPicker(context, anakState),
          const SizedBox(height: 16),
          _buildRecommendationsSection(context, selectedAnak),
        ],
      ),
      bottomNavigationBar: const ParentBottomNav(currentIndex: 4),
    );
  }

  Widget _buildChildPicker(BuildContext context, AnakState anakState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (anakState.isLoading && anakState.anakList.isEmpty)
          const LinearProgressIndicator(minHeight: 3)
        else if (anakState.anakList.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFFD97706), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Belum ada data anak. Tambahkan anak di menu Anak.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF92400E),
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          DropdownButtonFormField<AnakModel>(
            initialValue: anakState.selectedAnak,
            decoration: InputDecoration(
              labelText: 'Pilih Anak',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            items: anakState.anakList
                .map(
                  (anak) => DropdownMenuItem<AnakModel>(
                    value: anak,
                    child: Text('${anak.name} \u2022 ${anak.age} th'),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              ref.read(anakProvider.notifier).selectAnak(value);
            },
          ),
      ],
    );
  }

  Widget _buildRecommendationsSection(
      BuildContext context, AnakModel? selectedAnak) {
    if (selectedAnak == null) {
      return const SizedBox.shrink();
    }

    final recState =
        ref.watch(gameRecommendationByChildProvider(selectedAnak.id));

    if (recState.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (recState.error != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          recState.error ?? 'Gagal memuat',
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.red),
        ),
      );
    }

    final rec = recState.recommendations;
    if (rec == null || rec.games.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: rec.games
          .map((g) => _buildRecommendationCard(context, g, selectedAnak))
          .toList(),
    );
  }

  Widget _buildLoadingRecommendations() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryBlue.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(
            'Memuat rekomendasi game...',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorRecommendations(String? message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message ?? 'Gagal memuat rekomendasi',
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: const Color(0xFFDC2626),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyRecommendations({String? subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryBlue.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rekomendasi Game',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle ?? 'Pilih anak untuk melihat game yang relevan.',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(
      BuildContext context, GameRecommendationItem recItem, AnakModel selectedAnak) {
    final title = recItem.gameType;
    final params = recItem.params;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFDBEAFE),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.games_rounded, color: Color(0xFF2563EB)),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${params['choicesCount'] ?? '-'} pilihan • ${params['rounds'] ?? '-'} ronde',
          style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B)),
        ),
        trailing: IconButton(
          onPressed: () {
            final childId = selectedAnak.id;
            switch (recItem.gameType) {
              case 'Suara Binatang':
                context.pushNamed(
                  'suara-binatang',
                  extra: {
                    'childId': childId,
                    'choicesCount': params['choicesCount'] ?? 2,
                    'rounds': params['rounds'] ?? 5,
                  },
                );
                break;
              case 'Kata Bergambar':
                context.pushNamed(
                  'kata-bergambar',
                  extra: {
                    'childId': childId,
                    'choicesCount': params['choicesCount'] ?? 3,
                    'rounds': params['rounds'] ?? 8,
                    'hintMode': params['hintMode'] ?? 'none',
                  },
                );
                break;
              case 'Tebak Suara':
                context.pushNamed('tebak-suara', extra: {'childId': childId});
                break;
              case 'Latihan Artikulasi':
                context.pushNamed('latihan-artikulasi', extra: {'childId': childId});
                break;
              case 'Cerita Interaktif':
                context.pushNamed('cerita-interaktif', extra: {'childId': childId});
                break;
              default:
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Game "$title" sedang dalam pengembangan'),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
            }
          },
          icon: const Icon(Icons.play_arrow_rounded),
          color: AppConstants.primaryBlue,
        ),
        onTap: () {
          final childId = selectedAnak.id;
          switch (recItem.gameType) {
            case 'Suara Binatang':
              context.pushNamed(
                'suara-binatang',
                extra: {
                  'childId': childId,
                  'choicesCount': params['choicesCount'] ?? 2,
                  'rounds': params['rounds'] ?? 5,
                },
              );
              break;
            case 'Kata Bergambar':
              context.pushNamed(
                'kata-bergambar',
                extra: {
                  'childId': childId,
                  'choicesCount': params['choicesCount'] ?? 3,
                  'rounds': params['rounds'] ?? 8,
                  'hintMode': params['hintMode'] ?? 'none',
                },
              );
              break;
            case 'Tebak Suara':
              context.pushNamed('tebak-suara', extra: {'childId': childId});
              break;
            case 'Latihan Artikulasi':
              context.pushNamed('latihan-artikulasi', extra: {'childId': childId});
              break;
            case 'Cerita Interaktif':
              context.pushNamed('cerita-interaktif', extra: {'childId': childId});
              break;
          }
        },
      ),
    );
  }

  }


