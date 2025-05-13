import 'package:flutter/material.dart';
import 'package:mobile/utils/utils.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String pageTitle;

  const CustomAppBar({
    super.key,
    required this.pageTitle,
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
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconButton(
            icon: Icon(
              Icons.notifications,
              color: theme.colorScheme.onPrimary,
            ),
            tooltip: 'Notifications',
            onPressed: () {
              // TODO: Add your notification logic here
            },
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
