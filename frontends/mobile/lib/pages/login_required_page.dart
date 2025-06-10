import 'package:flutter/material.dart';
import 'package:mobile/models/server/errors.dart';
import 'package:provider/provider.dart';

import 'package:mobile/models/server/filters.dart';
import 'package:mobile/models/recipient.dart';
import 'package:mobile/services/recipient_service.dart';
import 'package:mobile/components/styled_elevated_button.dart';
import 'package:mobile/pages/signup_page.dart';
import 'package:mobile/services/providers.dart';

class LoginRequiredPage extends StatefulWidget {
  const LoginRequiredPage({super.key});

  @override
  State<LoginRequiredPage> createState() => _LoginRequiredPageState();
}

class _LoginRequiredPageState extends State<LoginRequiredPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.surface,
      child: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                margin:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
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
                              onPressed: () async => await _handleLogin(),
                              label: 'Log In',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: StyledElevatedButton(
                              onPressed: () async => await _navigateToSignUp(),
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

  //****** Helper functions
  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.login();
    if (!mounted) return;

    final credentials = userProvider.credentials;
    if (!userProvider.isLoggedIn) {
      if (mounted) {
        showErrorSnackBar(
          context,
          userProvider.errorMsg ?? 'Login failed. Please try again.',
        );
      }
      setState(() => _isLoading = false);
      return;
    }

    if (!mounted) return;
    final recipientService = Provider.of<RecipientService>(
      context,
      listen: false,
    );
    final result = await recipientService.getRecipients(
      RecipientFilter(auth0UserId: credentials!.user.sub),
      credentials.accessToken,
    );

    if (!mounted) return;
    await handleServiceResponse(
      context,
      result,
      onSuccess: () {
        if (result.data != null && result.data!.items.isNotEmpty) {
          userProvider.setRecipient(Recipient.fromJson(
            result.data!.items.first,
          ));
          showInfoSnackBar(context, 'Login successful!');
        } else {
          // This case means Auth0 login was successful, but no recipient found.
          // This might indicate a user who has only logged in via Auth0 but not signed up as a recipient.
          showErrorSnackBar(
            context,
            'No recipient profile found. Please sign up.',
          );
          // Clear credentials as recipient isn't linked
          userProvider.setCredentials(null);
          userProvider.setRecipient(null);
        }
      },
    );

    UserProvider.debugPrintUserProviderState(userProvider);
    setState(() => _isLoading = false);
  }

  Future<void> _navigateToSignUp() async {
    setState(() => _isLoading = true);

    await Navigator.of(context).push(
      // The SignupPage now gets UserProvider from context internally
      MaterialPageRoute(builder: (context) => const SignupPage()),
    );

    if (!mounted) return;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    UserProvider.debugPrintUserProviderState(userProvider);

    setState(() => _isLoading = false);
  }
}
