import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile/models/server/errors.dart';
import 'package:mobile/models/server/response.dart';
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

  // Handle Login Logic
  Future<void> _handleLogin(
    BuildContext context,
    UserProvider userProvider,
  ) async {
    setState(() {
      _isLoading = true;
    });

    await userProvider.login();
    if (!context.mounted) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final credentials = userProvider.credentials;
    if (credentials == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed. Please try again.')),
        );
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final recipientService = Provider.of<RecipientService>(
      context,
      listen: false,
    );
    final result = await recipientService.getRecipients(
      RecipientFilters(auth0UserId: credentials.user.sub),
      credentials.accessToken,
    );

    debugPrintApiResponse(result);

    // Show Login Status
    if (result.data != null && result.data!.items.isNotEmpty) {
      userProvider.setRecipient(Recipient.fromJson(result.data!.items.first));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful!')),
        );
      }
    } else {
      userProvider.setCredentials(null);
      userProvider.setRecipient(null);

      if (context.mounted) {
        String? message;

        if (result.error is ProblemDetails) {
          message = (result.error as ProblemDetails).detail;
        } else if (result.error is SimpleError) {
          message = (result.error as SimpleError).message;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text((message ?? '')),
          ),
        );
      }
    }

    UserProvider.debugPrintUserProviderState(userProvider);

    setState(() {
      _isLoading = false;
    });
  }

  // Handle Sign Up Logic
  Future<void> _handleSignUp(
    BuildContext context,
    UserProvider userProvider,
  ) async {
    setState(() {
      _isLoading = true;
    });

    final recipientData = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SignupPage()),
    ) as Map<String, dynamic>?;

    // Handle Signup Cancellation
    if (recipientData == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    await userProvider.signup();
    if (!context.mounted) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final credentials = userProvider.credentials;
    if (credentials == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signup failed. Please try again.')),
        );
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final auth0UserId = credentials.user.sub;
    final accessToken = credentials.accessToken;
    final recipientService = Provider.of<RecipientService>(
      context,
      listen: false,
    );

    // Create Recipient Object
    final handles = recipientData['socialMediaHandles'];
    debugPrint("Handles: ${jsonEncode(handles)}");

    final recipient = Recipient(
      firstName: recipientData['firstName'],
      middleName: recipientData['middleName'],
      lastName: recipientData['lastName'],
      dateOfBirth: recipientData['dateOfBirth'],
      phoneNo: recipientData['phoneNo'],
      bio: recipientData['bio'],
      socialMediaHandles: (recipientData['socialMediaHandles'])
          .map<SocialMediaHandle>((value) => SocialMediaHandle(
                socialMediaHandle: value,
              ))
          .toList(),
    );
    final profilePicture = recipientData['profilePicture'];

    debugPrint("Recipient: ${jsonEncode(recipient)}");

    // Attempt to Create Recipient
    final result = await recipientService.createRecipient(
      recipient,
      profilePicture,
      accessToken,
    );

    debugPrintApiResponse(result);

    // Clean up Orphan Auth0 User on Failure
    if (result.data == null && auth0UserId.isNotEmpty && context.mounted) {
      await recipientService.deleteAuth0User(auth0UserId, accessToken);
    }

    // Show Signup Status
    if (result.data != null) {
      userProvider.setRecipient(result.data!);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign up successful!')),
        );
      }
    } else {
      userProvider.setCredentials(null);
      userProvider.setRecipient(null);

      if (context.mounted) {
        String? message;

        if (result.error is ProblemDetails) {
          message = (result.error as ProblemDetails).detail;
        } else if (result.error is SimpleError) {
          message = (result.error as SimpleError).message;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text((message ?? '')),
          ),
        );
      }
    }

    UserProvider.debugPrintUserProviderState(userProvider);

    setState(() {
      _isLoading = false;
    });
  }

  // Build Method
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.surface,
      child: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
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
                              onPressed: () async => await _handleLogin(
                                context,
                                userProvider,
                              ),
                              label: 'Log In',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: StyledElevatedButton(
                              onPressed: () async => await _handleSignUp(
                                context,
                                userProvider,
                              ),
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
