import 'package:flutter/material.dart';

class PageWithFloatingButton extends StatelessWidget {
  final Widget body;
  final bool showFab;
  final bool fabIsLoading;
  final VoidCallback onFabPressed;
  final GlobalKey fabHeroTag = GlobalKey();
  final IconData fabIcon;

  PageWithFloatingButton({
    super.key,
    required this.body,
    this.showFab = true,
    this.fabIsLoading = false,
    required this.onFabPressed,
    this.fabIcon = Icons.add,
  });

  @override
  Widget build(BuildContext context) {
    // Get the bottom inset (keyboard height)
    final double bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Stack(
      children: [
        body,
        if (showFab)
          SafeArea(
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                // Adjust bottom padding based on keyboard height
                padding: EdgeInsets.only(
                  right: 16.0,
                  bottom: 16.0 + bottomInset,
                ),
                child: FloatingActionButton(
                  heroTag: fabHeroTag,
                  onPressed: fabIsLoading ? null : onFabPressed,
                  child: Icon(fabIcon),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
