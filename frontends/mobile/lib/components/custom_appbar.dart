import 'package:flutter/material.dart';
import 'package:mobile/pages/notifications_page.dart';
import 'package:mobile/utils/utils.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String pageTitle;
  final List<Widget> actions;
  final bool showNotificationIcon;

  const CustomAppBar({
    super.key,
    required this.pageTitle,
    this.actions = const [],
    this.showNotificationIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      title: Text(
        toTitleCase(pageTitle),
        style: theme.textTheme.titleLarge?.copyWith(
          color: theme.colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: theme.colorScheme.primary,
      iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
      actions: [
        if (showNotificationIcon)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.notifications),
              tooltip: 'Notifications',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NotificationsPage()),
                );
              },
            ),
          ),
        ...actions
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
