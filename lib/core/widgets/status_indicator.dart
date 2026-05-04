import 'package:flutter/material.dart';

enum StatusType { online, offline, warning, error }

class StatusIndicator extends StatelessWidget {
  final StatusType status;
  final double size;
  final String? label;

  const StatusIndicator({
    super.key,
    required this.status,
    this.size = 16,
    this.label,
  });

  Color get _statusColor {
    switch (status) {
      case StatusType.online:
        return const Color(0xFF00C950);
      case StatusType.offline:
        return const Color(0xFF99A1AE);
      case StatusType.warning:
        return const Color(0xFFF0B000);
      case StatusType.error:
        return const Color(0xFFE53E3E);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: ShapeDecoration(
            color: _statusColor,
            shape: const CircleBorder(),
          ),
        ),
        if (label != null) ...[
          const SizedBox(width: 8),
          Text(
            label!,
            style: TextStyle(
              color: _statusColor,
              fontSize: 14,
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ],
    );
  }
}
