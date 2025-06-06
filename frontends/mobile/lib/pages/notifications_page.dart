import 'package:flutter/material.dart';
import 'package:mobile/components/custom_appbar.dart';
import 'package:mobile/components/notification_card.dart';
import 'package:mobile/pages/login_required_page.dart';
import 'package:mobile/services/providers.dart';
import 'package:provider/provider.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _isInitialFetchScheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );

    // Schedule the fetch only once when the widget first becomes active and dependencies are resolved.
    // This runs after the first frame is rendered, avoiding setState during build.
    if (!_isInitialFetchScheduled && userProvider.isLoggedIn) {
      // Set to true immediately to prevent re-scheduling
      _isInitialFetchScheduled = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Ensure the widget is still mounted before performing actions
        if (mounted && notificationProvider.status == NotificationStatus.idle) {
          notificationProvider.fetchNotifications();
        }
      });
    } else if (!userProvider.isLoggedIn && _isInitialFetchScheduled) {
      // If the user logs out, reset the flag so data can be fetched again on next login
      // This also ensures we don't try to fetch if not logged in.
      _isInitialFetchScheduled = false;
      // Clear the notification list in the provider when logging out.
      notificationProvider.resetState();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);

    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    Widget bodyContent;

    if (!userProvider.isLoggedIn) {
      bodyContent = const LoginRequiredPage();
    } else {
      switch (notificationProvider.status) {
        case NotificationStatus.idle:
          if (notificationProvider.notifications.isEmpty) {
            bodyContent = Center(
              child: Text(
                'No new notifications.',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            );
          } else {
            bodyContent = ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: notificationProvider.notifications.length,
              itemBuilder: (context, index) {
                final notification = notificationProvider.notifications[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 6.0,
                  ),
                  child: NotificationCard(
                    notification: notification,
                    onMarkAsRead: (id) => notificationProvider.markAsRead(id),
                    onDismiss: (id) =>
                        notificationProvider.dismissNotification(id),
                  ),
                );
              },
            );
          }
          break;
        case NotificationStatus.loading:
          bodyContent = const Center(child: CircularProgressIndicator());
          break;
        case NotificationStatus.error:
          bodyContent = Center(
            child: Text(
              notificationProvider.errorMessage ??
                  'Failed to load notifications.',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
          );
          break;
      }
    }

    return Scaffold(
      appBar: const CustomAppBar(
        pageTitle: 'Notifications',
        showNotificationIcon: false,
      ),
      body: bodyContent,
    );
  }
}
