import 'package:flutter/material.dart';

enum StatusType { success, warning, error, info, pending }

class StatusIndicator extends StatelessWidget {
  final StatusType status;
  final String text;
  final IconData? icon;
  final bool showIcon;

  const StatusIndicator({
    super.key,
    required this.status,
    required this.text,
    this.icon,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color backgroundColor;
    Color textColor;
    Color iconColor;
    IconData defaultIcon;

    switch (status) {
      case StatusType.success:
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green.shade800;
        iconColor = Colors.green.shade600;
        defaultIcon = Icons.check_circle;
        break;
      case StatusType.warning:
        backgroundColor = Colors.orange.shade50;
        textColor = Colors.orange.shade800;
        iconColor = Colors.orange.shade600;
        defaultIcon = Icons.warning;
        break;
      case StatusType.error:
        backgroundColor = Colors.red.shade50;
        textColor = Colors.red.shade800;
        iconColor = Colors.red.shade600;
        defaultIcon = Icons.error;
        break;
      case StatusType.info:
        backgroundColor = Colors.blue.shade50;
        textColor = Colors.blue.shade800;
        iconColor = Colors.blue.shade600;
        defaultIcon = Icons.info;
        break;
      case StatusType.pending:
        backgroundColor = Colors.grey.shade50;
        textColor = Colors.grey.shade800;
        iconColor = Colors.grey.shade600;
        defaultIcon = Icons.schedule;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: iconColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              icon ?? defaultIcon,
              color: iconColor,
              size: 20,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}