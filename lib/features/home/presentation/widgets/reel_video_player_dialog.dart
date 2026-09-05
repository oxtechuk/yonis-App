import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../../app/localization/locale_keys.g.dart';
import '../../../../app/styles/app_colors.dart';
import '../../../../app/styles/app_spacing.dart';
import '../../../../app/styles/app_text_styles.dart';
import '../../domain/entities/reel.dart';

/// Extracts a YouTube video id from watch, shorts, youtu.be and embed URLs.
String? extractYoutubeId(String url) {
  final fromHelper = YoutubePlayer.convertUrlToId(url);
  if (fromHelper != null && fromHelper.isNotEmpty) return fromHelper;
  final match = RegExp(r'shorts\/([^#&?\/]+)').firstMatch(url);
  return match?.group(1);
}

/// Opens [reel] in an in-app popup player. YouTube links play embedded;
/// anything else falls back to the external app/browser.
Future<void> showReelVideoDialog(BuildContext context, Reel reel) async {
  final videoId = extractYoutubeId(reel.videoUrl.trim());
  if (videoId == null) {
    await openReelExternally(context, reel.videoUrl);
    return;
  }
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => _ReelVideoDialog(reel: reel, videoId: videoId),
  );
}

/// Opens the reel url in the YouTube app / external browser.
Future<void> openReelExternally(BuildContext context, String videoUrl) async {
  final rawUrl = videoUrl.trim();
  debugPrint('[reels] open externally: "$rawUrl"');
  if (rawUrl.isEmpty) return;
  final uri = Uri.tryParse(rawUrl);
  if (uri == null || !uri.hasScheme) return;
  try {
    var launched =
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    debugPrint('[reels] externalApplication result: $launched');
    launched =
        launched || await launchUrl(uri, mode: LaunchMode.platformDefault);
    debugPrint('[reels] final launch result: $launched');
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr(LocaleKeys.errors_general))),
      );
    }
  } catch (e) {
    debugPrint('[reels] launch failed: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr(LocaleKeys.errors_general))),
      );
    }
  }
}

class _ReelVideoDialog extends StatefulWidget {
  const _ReelVideoDialog({required this.reel, required this.videoId});

  final Reel reel;
  final String videoId;

  @override
  State<_ReelVideoDialog> createState() => _ReelVideoDialogState();
}

class _ReelVideoDialogState extends State<_ReelVideoDialog> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(controller: _controller),
      builder: (context, player) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xl,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.reel.title,
                      style: AppTextStyles.title.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: player,
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  openReelExternally(context, widget.reel.videoUrl);
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text('YouTube'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
