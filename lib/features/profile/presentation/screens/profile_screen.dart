import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../library/domain/library_repository.dart'; 
import '../../../library/domain/models/user_book.dart';
import '../../data/profile_repository.dart';
import 'package:bookshelf/core/localization/l10n/app_localizations.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isUploading = false;
  final _picker = ImagePicker();

  Future<void> _changeAvatar(ImageSource source) async {
    final loc = AppLocalizations.of(context)!;
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 400,
      );

      if (pickedFile == null) return;

      setState(() => _isUploading = true);

      final file = File(pickedFile.path);
      final repo = ref.read(profileRepositoryProvider);

      final downloadUrl = await repo.uploadAvatar(file);

      if (downloadUrl != null) {
        await repo.updateProfilePhoto(downloadUrl);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.avatar_success), 
              behavior: SnackBarBehavior.floating
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${loc.error}$e'), 
            backgroundColor: Theme.of(context).colorScheme.error
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showImageSourceBottomSheet() {
    final loc = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: Text(loc.avatar_gallery),
              onTap: () {
                Navigator.pop(context);
                _changeAvatar(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: Text(loc.avatar_camera),
              onTap: () {
                Navigator.pop(context);
                _changeAvatar(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _calculateStatistics(List<UserBook> books) {
    int readCount = books.where((b) => b.status == ReadingStatus.completed).length;
    int readingCount = books.where((b) => b.status == ReadingStatus.reading).length;
    int backlogCount = books.where((b) => b.status == ReadingStatus.backlog).length;

    final ratedBooks = books.where((b) => b.rating != null && b.rating! > 0).toList();
    double averageRating = 0.0;
    if (ratedBooks.isNotEmpty) {
      final totalRating = ratedBooks.fold<int>(0, (sum, b) => sum + b.rating!);
      averageRating = totalRating / ratedBooks.length;
    }

    return {
      'readCount': readCount,
      'readingCount': readingCount,
      'backlogCount': backlogCount,
      'averageRating': averageRating,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;
    final userBooksAsync = ref.watch(userBooksStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.profile_title, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                    child: user?.photoURL == null && !_isUploading
                        ? Icon(Icons.person_rounded, size: 60, color: theme.colorScheme.onPrimaryContainer)
                        : null,
                  ),
                  if (_isUploading)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.32),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                      ),
                    ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton.filled(
                      icon: const Icon(Icons.camera_alt_rounded, size: 20),
                      onPressed: _isUploading ? null : _showImageSourceBottomSheet,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.displayName ?? user?.email ?? loc.user_default_name,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            userBooksAsync.when(
              data: (books) {
                final stats = _calculateStatistics(books);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(loc.stats_title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                  
                    Row(
                      children: [
                        _buildStatCard(context, loc.stat_read, '${stats['readCount']}', Icons.check_circle_outline_rounded, Colors.green),
                        const SizedBox(width: 12),
                        _buildStatCard(context, loc.stat_reading, '${stats['readingCount']}', Icons.menu_book_rounded, Colors.blue),
                        const SizedBox(width: 12),
                        _buildStatCard(context, loc.stat_want, '${stats['backlogCount']}', Icons.bookmark_border_rounded, Colors.orange),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Card(
                      elevation: 0,
                      color: theme.colorScheme.surfaceContainerLow,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildListTileStat(
                              context, 
                              loc.avg_rating, 
                              stats['averageRating'] == 0.0 ? loc.no_ratings : '${(stats['averageRating'] as double).toStringAsFixed(1)} / 10', 
                              Icons.star_rounded, 
                              Colors.amber
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('${loc.error}$e')),
            ),
            
            const SizedBox(height: 40),
            OutlinedButton.icon(
              onPressed: () => FirebaseAuth.instance.signOut(),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                side: BorderSide(color: theme.colorScheme.error),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: Icon(Icons.logout_rounded, color: theme.colorScheme.error),
              label: Text(loc.logout, style: TextStyle(color: theme.colorScheme.error)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
  Widget _buildListTileStat(BuildContext context, String label, String value, IconData icon, Color iconColor) {

    final theme = Theme.of(context);
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: iconColor.withValues(alpha: 0.05),
          child: Icon(icon, color: iconColor),
        ),
        const SizedBox(width: 16),
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
} 

