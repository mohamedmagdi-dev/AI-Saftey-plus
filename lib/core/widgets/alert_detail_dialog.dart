import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import 'glass_container.dart';

class AlertDetailDialog extends StatelessWidget {
  const AlertDetailDialog({
    super.key,
    required this.title,
    required this.description,
    this.imageUrl,
    this.timestamp,
    this.severity,
  });

  final String title;
  final String description;
  final String? imageUrl;
  final DateTime? timestamp;
  final String? severity;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: GlassContainer(
          borderRadius: 20,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Alert Details',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Arimo',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Alert image if available
              if (imageUrl != null && imageUrl!.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.fitHeight,
                    placeholder: (context, url) => Container(
                      height: 200,
                      color: AppTheme.surfaceColor,
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentCyan),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 200,
                      color: AppTheme.surfaceColor,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: AppTheme.textSecondary,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Alert title
              Text(
                title,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Arimo',
                ),
              ),
              const SizedBox(height: 8),
              
              // Timestamp and severity if available
              if (timestamp != null || severity != null) ...[
                Row(
                  children: [
                    if (timestamp != null) ...[
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatTimestamp(timestamp!),
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                          fontFamily: 'Arimo',
                        ),
                      ),
                    ],
                    if (timestamp != null && severity != null) ...[
                      const SizedBox(width: 16),
                    ],
                    if (severity != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getSeverityColor(severity!).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          severity!.toUpperCase(),
                          style: TextStyle(
                            color: _getSeverityColor(severity!),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Arimo',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
              ],
              
              // Description
              Text(
                description,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 16,
                  fontFamily: 'Arimo',
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              
              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentCyan,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Arimo',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      case 'critical':
        return Colors.purple;
      default:
        return AppTheme.textSecondary;
    }
  }
}

// Utility function to show the alert dialog
void showAlertDetailDialog({
  required BuildContext context,
  required String title,
  required String description,
  String? imageUrl,
  DateTime? timestamp,
  String? severity,
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => AlertDetailDialog(
      title: title,
      description: description,
      imageUrl: imageUrl,
      timestamp: timestamp,
      severity: severity,
    ),
  );
}
