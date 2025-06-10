import 'package:flutter/material.dart';

import 'package:mobile/pages/notifications_page.dart';
import 'package:mobile/services/providers.dart';
import 'package:mobile/utils/utils.dart';
import 'package:provider/provider.dart';

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
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final canPop = Navigator.of(context).canPop();

    return AppBar(
      leadingWidth: 46,
      leading: canPop // If we can pop, always show the back button
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Go back',
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          : (showNotificationIcon
              ? IconButton(
                  icon: const Icon(Icons.notifications),
                  tooltip: 'Notifications',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const NotificationsPage(),
                      ),
                    );
                  },
                )
              : null),
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
        ...actions,
        if (userProvider.isLoggedIn)
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: IconButton(
              onPressed: userProvider.isLoading
                  ? null
                  : () => Provider.of<UserProvider>(context, listen: false)
                      .logout(),
              icon: Icon(Icons.logout, color: theme.colorScheme.errorContainer),
              tooltip: "Logout",
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
