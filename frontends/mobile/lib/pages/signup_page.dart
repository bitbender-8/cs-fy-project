import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/components/custom_appbar.dart';
import 'package:mobile/components/styled_elevated_button.dart';
import 'package:mobile/utils/validators.dart';
import 'package:mobile/services/providers.dart';
import 'package:mobile/models/recipient.dart';
import 'package:mobile/services/recipient_service.dart';
import 'package:provider/provider.dart';
import 'package:mobile/models/server/errors.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage>
    with FormErrorHelpers<SignupPage> {
  File? _profilePicture;
  final _formKey = GlobalKey<FormState>();

  String? _firstName, _middleName, _lastName, _phoneNo, _bio;
  DateTime? _dateOfBirth;
  final List<String> _socialMediaHandles = [];
  final List<String?> _socialHandleErrors = [];

  final _socialController = TextEditingController();
  final _dobController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _socialController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String? profilePictureServerError = getServerError('profilePicture');

    return Scaffold(
      appBar: const CustomAppBar(
        pageTitle: "Recipient Sign Up",
        showNotificationIcon: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            children: [
              const Text(
                'Create Your Account',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please provide your information to create your recipient profile',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              const Text(
                'Profile Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Column(
                        children: [
                          const Text(
                            'Profile Picture',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Tap to upload',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () {
                              _pickProfilePicture();
                              clearServerError('profilePicture');
                            },
                            child: CircleAvatar(
                              radius: 40,
                              backgroundImage: _profilePicture != null
                                  ? FileImage(_profilePicture!)
                                  : null,
                              child: _profilePicture == null
                                  ? const Icon(Icons.camera_alt, size: 32)
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: "First name*",
                                border: const OutlineInputBorder(),
                                hintText: "Enter your first name",
                                errorText: getServerError('firstName'),
                              ),
                              validator: (value) {
                                final clientError =
                                    validNonEmptyString(value, max: 50);
                                if (clientError != null) return clientError;
                                return getServerError('firstName');
                              },
                              onChanged: (value) =>
                                  clearServerError('firstName'),
                              onSaved: (value) => _firstName = value,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: "Middle name",
                                border: const OutlineInputBorder(),
                                hintText: "Enter your middle name (optional)",
                                errorText: getServerError('middleName'),
                              ),
                              validator: (value) {
                                final clientError =
                                    validNonEmptyString(value, max: 50);
                                if (clientError != null) return clientError;
                                return getServerError('middleName');
                              },
                              onChanged: (value) =>
                                  clearServerError('middleName'),
                              onSaved: (value) => _middleName = value,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (profilePictureServerError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                      child: Text(
                        profilePictureServerError,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Last name*",
                  border: const OutlineInputBorder(),
                  hintText: "Enter your last name",
                  errorText: getServerError('lastName'),
                ),
                validator: (value) {
                  final clientError = validNonEmptyString(value, max: 50);
                  if (clientError != null) return clientError;
                  return getServerError('lastName');
                },
                onChanged: (value) => clearServerError('lastName'),
                onSaved: (value) => _lastName = value,
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Bio*",
                  border: const OutlineInputBorder(),
                  hintText: "Tell us about yourself (max 500 characters)",
                  alignLabelWithHint: true,
                  errorText: getServerError('bio'),
                ),
                maxLines: 3,
                validator: (value) {
                  final clientError = validNonEmptyString(value, max: 500);
                  if (clientError != null) return clientError;
                  return getServerError('bio');
                },
                onChanged: (value) => clearServerError('bio'),
                onSaved: (value) => _bio = value,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dobController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Date of Birth*",
                  border: const OutlineInputBorder(),
                  hintText: "Select your date of birth",
                  suffixIcon: const Icon(Icons.calendar_today),
                  errorText: getServerError('dateOfBirth'),
                ),
                onTap: () {
                  _selectDate(context);
                  clearServerError('dateOfBirth');
                },
                validator: (value) {
                  final clientError = validDate(value, isPast: true);
                  if (clientError != null) return clientError;
                  return getServerError('dateOfBirth');
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Contact Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Phone number*",
                  border: const OutlineInputBorder(),
                  hintText: "Enter your phone number",
                  prefixIcon: const Icon(Icons.phone),
                  errorText: getServerError('phoneNo'),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  final clientError = validPhoneNo(value);
                  if (clientError != null) return clientError;
                  return getServerError('phoneNo');
                },
                onChanged: (value) => clearServerError('phoneNo'),
                onSaved: (value) => _phoneNo = value,
              ),
              const SizedBox(height: 12),
              const Text(
                'Add links to your social media profiles (optional)',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _socialController,
                decoration: InputDecoration(
                  labelText: "Social Media URL",
                  border: const OutlineInputBorder(),
                  hintText: "https://example.com/yourprofile",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      final handle = _socialController.text.trim();
                      final error = validUrl(handle);
                      if (error == null) {
                        setState(() {
                          _socialMediaHandles.add(handle);
                          _socialHandleErrors.add(null);
                          _socialController.clear();
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(error),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                      clearServerError('socialMediaHandles');
                    },
                  ),
                  errorText: getServerError('socialMediaHandles'),
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text(
                  'Example: https://facebook.com/yourname or https://twitter.com/yourhandle',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(_socialMediaHandles.length, (i) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Chip(
                        label: Text(
                          _socialMediaHandles[i],
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        onDeleted: () {
                          setState(() {
                            _socialMediaHandles.removeAt(i);
                            _socialHandleErrors.removeAt(i);
                          });
                          if (_socialMediaHandles.isEmpty) {
                            clearServerError('socialMediaHandles');
                          }
                        },
                      ),
                      if (_socialHandleErrors[i] != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 4),
                          child: Text(
                            _socialHandleErrors[i]!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 12),
                          ),
                        ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 32),
              const Text(
                '* indicates required fields',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 16),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : StyledElevatedButton(
                      onPressed: _handleFormSubmission,
                      label: 'Create Account',
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
        _dobController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _pickProfilePicture() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _profilePicture = File(picked.path);
      });
    }
  }

  Future<void> _handleFormSubmission() async {
    clearAllServerErrors();

    bool socialValid = true;

    for (int i = 0; i < _socialMediaHandles.length; i++) {
      final error = validUrl(_socialMediaHandles[i]);
      _socialHandleErrors[i] = error;
      if (error != null) socialValid = false;
    }

    if (!_formKey.currentState!.validate() || !socialValid) {
      setState(() => _isLoading = false);
      return;
    }
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.signup();

    final credentials = userProvider.credentials;
    if (credentials == null) {
      if (mounted) {
        showErrorSnackBar(context, 'Signup failed. Please try again.');
      }
      setState(() => _isLoading = false);
      return;
    }

    final auth0UserId = credentials.user.sub;
    final accessToken = credentials.accessToken;

    if (!mounted) return;
    final recipientService = Provider.of<RecipientService>(
      context,
      listen: false,
    );

    final recipient = Recipient(
      firstName: _firstName!,
      middleName: _middleName!,
      lastName: _lastName!,
      dateOfBirth: _dateOfBirth!,
      phoneNo: _phoneNo!,
      bio: _bio!,
      socialMediaHandles: _socialMediaHandles
          .map((value) => SocialMediaHandle(
                socialMediaHandle: value,
              ))
          .toList(),
    );

    final result = await recipientService.createRecipient(
      recipient,
      _profilePicture,
      accessToken,
    );

    // Signup submitted with invalid recipient object
    // Fill in -> Auth0 Success -> Server fails validation -> (Auth0 session must be removed, Auth0 orphan must be deleted)
    // Signup submitted with duplicate auth0 user (duplicate email)
    //

    if (!mounted) return;
    final success = await handleServiceResponse(
      context,
      result,
      onSuccess: () {
        userProvider.setRecipient(result.data!);
        if (mounted) {
          Navigator.of(context).pop(true);
        }
        showInfoSnackBar(context, 'Sign up successful!');
      },
      onValidationErrors: (fieldErrors) {
        setState(() => setServerErrors(fieldErrors));
        _formKey.currentState?.validate();
      },
    );

    if (!success && auth0UserId.isNotEmpty && mounted) {
      if (result.error is ProblemDetails) {
        final problem = result.error as ProblemDetails;
        bool isAuth0AccountUsedByARecipient =
            problem.code == ServerErrorCode.duplicateAuth0User ||
                problem.code == ServerErrorCode.duplicateEmail;

        if (!isAuth0AccountUsedByARecipient) {
          await recipientService.deleteAuth0User(auth0UserId, accessToken);
        } else {
          UserProvider.debugPrintUserProviderState(userProvider);
        }
      }
      userProvider.setCredentials(null);
      userProvider.setRecipient(null);
    }

    UserProvider.debugPrintUserProviderState(userProvider);
    setState(() => _isLoading = false);
  }
}
