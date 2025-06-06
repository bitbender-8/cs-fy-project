import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/models/app_notification.dart';

class NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final Function(String) onMarkAsRead;
  final Function(String) onDismiss;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onMarkAsRead,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: notification.isRead
            ? BorderSide.none
            : BorderSide(color: colorScheme.primary.withAlpha(127), width: 1.0),
      ),
      color: notification.isRead
          ? colorScheme.surfaceContainerHigh
          : colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    notification.subject,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: notification.isRead
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8.0),
                if (!notification.isRead)
                  SizedBox(
                    height: 28,
                    child: OutlinedButton(
                      onPressed: () => onMarkAsRead(notification.id),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        side: BorderSide(color: colorScheme.primary),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0)),
                      ),
                      child: Text(
                        'Mark as read',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: 4.0),
                SizedBox(
                  width: 28,
                  height: 28,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(Icons.close,
                        size: 18, color: colorScheme.onSurfaceVariant),
                    onPressed: () => onDismiss(notification.id),
                    alignment: Alignment.center,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4.0),
            Text(
              'Date: ${DateFormat('MM/dd/yy HH:mm').format(notification.createdAt)}', // Using 'createdAt'
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              notification.body, // Using 'body' from your model
              style: textTheme.bodyMedium?.copyWith(
                color: notification.isRead
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.onSurface,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
