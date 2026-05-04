import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'glass_container.dart';
import 'status_indicator.dart';

class CameraCard extends StatelessWidget {
  final String cameraName;
  final String location;
  final bool isOnline;
  final VoidCallback? onTap;
  final String? thumbnailUrl;

  const CameraCard({
    super.key,
    required this.cameraName,
    required this.location,
    this.isOnline = true,
    this.onTap,
    this.thumbnailUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.black.withValues(alpha: 0.3),
              ),
              child: thumbnailUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: thumbnailUrl!,
                        fit: BoxFit.fill,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white54,
                            strokeWidth: 2,
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.videocam, color: Colors.white54),
                      ),
                    )
                  : const Icon(Icons.videocam, color: Colors.white54, size: 48),
            ),
            const SizedBox(height: 12),
            Text(
              cameraName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Arimo',
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              location,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 14,
                fontFamily: 'Arimo',
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 8),
            StatusIndicator(
              status: isOnline ? StatusType.online : StatusType.offline,
              label: isOnline ? 'Online' : 'Offline',
            ),
          ],
        ),
      ),
    );
  }
}
