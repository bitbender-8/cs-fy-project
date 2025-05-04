import 'package:flutter/material.dart';
import 'package:mobile/components/styled_elevated_button.dart';
import 'package:mobile/services/notifiers.dart';
import 'package:provider/provider.dart';

class LoginRequiredPage extends StatelessWidget {
  const LoginRequiredPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.surface,
      child: Center(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'You must be logged in to see this content.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: StyledElevatedButton(
                        onPressed: () {
                          userProvider.login();
                        },
                        label: 'Log In',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StyledElevatedButton(
                        onPressed: () {
                          userProvider.logout();
                        },
                        label: 'Sign Up',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
