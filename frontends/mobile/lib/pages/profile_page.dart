import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/components/page_with_floating_button.dart';
import 'package:mobile/models/recipient.dart';
import 'package:mobile/models/server/errors.dart';
import 'package:mobile/services/providers.dart';
import 'package:mobile/services/recipient_service.dart';
import 'package:mobile/utils/utils.dart';
import 'package:mobile/utils/validators.dart';
import 'package:provider/provider.dart';

// Assuming all necessary imports and the definition of FormErrorHelpers
// and your models (Recipient, SocialMediaHandle, ServerValidationException)
// are correctly handled and valid in your project.

class ProfilePage extends StatefulWidget {
  final Recipient initialRecipient;

  const ProfilePage({super.key, required this.initialRecipient});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with FormErrorHelpers<ProfilePage> {
  late Recipient _initialRecipient;
  final _formKey = GlobalKey<FormState>();

  // Define TextEditingControllers for all editable fields
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _phoneNoController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _newSocialHandleController = TextEditingController();

  final List<String?> _socialHandleErrors =
      []; // This will hold client-side errors
  late Recipient _editableRecipient;
  File? _profilePicture;

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _initialRecipient = widget.initialRecipient.copyWith();
    _fetchRecipient(); // Initial fetch on load
    _editableRecipient = _initialRecipient.copyWith();

    // Initialize controllers with _editableRecipient's current values
    _initializeControllers();

    _socialHandleErrors.addAll(List.generate(
      _editableRecipient.socialMediaHandles?.length ?? 0,
      (_) => null,
    ));
  }

  // New helper to initialize all controllers
  void _initializeControllers() {
    _firstNameController.text = _editableRecipient.firstName ?? '';
    _middleNameController.text = _editableRecipient.middleName ?? '';
    _lastNameController.text = _editableRecipient.lastName ?? '';
    _bioController.text = _editableRecipient.bio ?? '';
    _phoneNoController.text = _editableRecipient.phoneNo ?? '';
    _setDateOfBirthControllerText(); // This handles _dateOfBirthController
  }

  @override
  void dispose() {
    // Dispose all controllers
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _bioController.dispose();
    _phoneNoController.dispose();
    _dateOfBirthController.dispose();
    _newSocialHandleController.dispose();
    super.dispose();
  }

  void _setDateOfBirthControllerText() {
    if (_editableRecipient.dateOfBirth != null) {
      _dateOfBirthController.text =
          formatDate(_editableRecipient.dateOfBirth!.toLocal(), isShort: false);
    } else {
      _dateOfBirthController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageWithFloatingButton(
      body: Stack(
        children: [
          _buildForm(),
          if (_isLoading)
            _buildLoadingOverlay(), // Show loading overlay regardless of edit mode
        ],
      ),
      showFab: !_isEditing,
      fabIsLoading: _isLoading,
      onFabPressed: _toggleEditMode,
      fabIcon: Icons.edit,
    );
  }

  //****** Page sections
  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.5), // Use withOpacity for clarity
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: RefreshIndicator(
        // RefreshIndicator directly wraps the SingleChildScrollView
        onRefresh: () async {
          await _fetchRecipient();
          // After fetching, _editableRecipient and controllers are updated.
          // No need for _resetFields() here as we want to display the fresh data.
          // We also need to re-validate the form if there are server errors for social media handles
          _formKey.currentState?.validate();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          physics:
              const AlwaysScrollableScrollPhysics(), // Important for RefreshIndicator to always work
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProfileAvatarSection(),
              const SizedBox(height: 24.0),
              _buildPersonalInformationSection(),
              const SizedBox(height: 24.0),
              _buildContactSection(),
              const SizedBox(height: 24.0),
              _buildSocialMediaSection(),
              const SizedBox(height: 32.0),
              if (_isEditing) _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatarSection() {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        InkWell(
          onTap: _isEditing ? _pickProfilePicture : null,
          customBorder: const CircleBorder(),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: colorScheme.secondaryContainer,
            backgroundImage: _setProfilePicture(),
            child: _setProfilePicture() == null
                ? Icon(
                    Icons.person,
                    size: 60,
                    color: colorScheme.onSecondaryContainer,
                  )
                : null,
          ),
        ),
        if (_isEditing)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Tap to change picture',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }

  Widget _buildPersonalInformationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Personal Information'),
        TextFormField(
          controller: _firstNameController, // Use controller
          readOnly: !_isEditing,
          decoration: const InputDecoration(
            labelText: 'First Name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person_outline),
          ),
          validator: (value) => validNonEmptyString(value, max: 50),
        ),
        const SizedBox(height: 16.0),
        TextFormField(
          controller: _middleNameController, // Use controller
          readOnly: !_isEditing,
          decoration: const InputDecoration(
            labelText: 'Middle Name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person_outline),
          ),
          validator: (value) => validNonEmptyString(value, max: 50),
        ),
        const SizedBox(height: 16.0),
        TextFormField(
          controller: _lastNameController, // Use controller
          readOnly: !_isEditing,
          decoration: const InputDecoration(
            labelText: 'Last Name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person_outline),
          ),
          validator: (value) => validNonEmptyString(value, max: 50),
        ),
        const SizedBox(height: 16.0),
        TextFormField(
          readOnly: true,
          controller: _dateOfBirthController,
          decoration: InputDecoration(
            labelText: 'Date of Birth',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.calendar_month),
            errorText: getServerError('dateOfBirth'),
          ),
          onTap: () async {
            if (_isEditing) {
              await _selectDateOfBirth(context);
              clearServerError('dateOfBirth');
            }
          },
          validator: (_) =>
              validDate(
                _editableRecipient.dateOfBirth?.toIso8601String(),
                isPast: true,
              ) ??
              checkIfAtLeastYearsOld(_editableRecipient.dateOfBirth),
        ),
        const SizedBox(height: 16.0),
        TextFormField(
          controller: _bioController, // Use controller
          readOnly: !_isEditing,
          decoration: InputDecoration(
            labelText: 'Bio',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.info_outline),
            alignLabelWithHint: true,
            errorText: getServerError('bio'),
          ),
          keyboardType: TextInputType.multiline,
          maxLines: 5,
          minLines: 3,
          validator: (val) => validNonEmptyString(val, max: 500),
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Contact Information'),
        TextFormField(
          controller: _phoneNoController, // Use controller
          readOnly: !_isEditing,
          decoration: InputDecoration(
            labelText: 'Phone Number',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.phone),
            errorText: getServerError('phoneNo'),
          ),
          keyboardType: TextInputType.phone,
          validator: (val) => validPhoneNo(val),
        ),
        const SizedBox(height: 16.0),
        TextFormField(
          initialValue: _editableRecipient.email ??
              '', // Email is still read-only, no controller needed
          readOnly: true,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email_outlined),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }

  Widget _buildSocialMediaSection() {
    final colorScheme = Theme.of(context).colorScheme;
    final titleStyle = Theme.of(
      context,
    ).textTheme.titleLarge?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
        );
    final bool hasHandles =
        _editableRecipient.socialMediaHandles?.isNotEmpty ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Social Media Handles', style: titleStyle),
            if (_isEditing)
              TextButton.icon(
                onPressed: () => _showAddSocialHandleDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
                style: TextButton.styleFrom(
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  splashFactory: NoSplash.splashFactory,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        const Divider(height: 18, thickness: 2.0),
        if (hasHandles)
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: List.generate(
                _editableRecipient.socialMediaHandles?.length ?? 0, (i) {
              // Get server error for this specific social media handle
              final String? serverError =
                  getServerError('socialMediaHandles.$i.socialMediaHandle');
              // Combine client-side and server-side errors
              final String? displayError =
                  _socialHandleErrors[i] ?? serverError;

              return Chip(
                label: Text(
                  _editableRecipient.socialMediaHandles![i].socialMediaHandle,
                ),
                labelStyle: TextStyle(
                  color: displayError != null
                      ? colorScheme.onErrorContainer
                      : colorScheme
                          .onSecondaryContainer, // Text color for error
                ),
                backgroundColor: displayError != null
                    ? colorScheme.errorContainer
                    : colorScheme
                        .secondaryContainer, // Background color for error
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: BorderSide(
                      color: displayError != null
                          ? colorScheme.error
                          : colorScheme
                              .outlineVariant), // Border color for error
                ),
                onDeleted: _isEditing
                    ? () {
                        setState(() {
                          _editableRecipient.socialMediaHandles?.removeAt(i);
                          if (i < _socialHandleErrors.length) {
                            _socialHandleErrors.removeAt(i);
                          }
                          // Also remove server error for this handle if it exists
                          clearServerError(
                              'socialMediaHandles.$i.socialMediaHandle');
                        });
                      }
                    : null,
                deleteIcon: _isEditing && !_isLoading
                    ? Icon(
                        Icons.close,
                        size: 18,
                        color: displayError != null
                            ? colorScheme.onErrorContainer
                            : colorScheme
                                .onSecondaryContainer, // Icon color for error
                      )
                    : null,
              );
            }),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              'No social media handles added.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        // Display generic social media handle error if any
        if (getServerError('socialMediaHandles') != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 12.0),
            child: Text(
              getServerError('socialMediaHandles')!,
              style: TextStyle(color: colorScheme.error, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final colorScheme = Theme.of(context).colorScheme;
    const buttonPadding = EdgeInsets.symmetric(vertical: 14.0);
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading
                ? null
                : () {
                    _resetFields();
                    _toggleEditMode();
                  },
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.error,
              side: BorderSide(color: colorScheme.error),
              padding: buttonPadding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submitChanges,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Submit'),
          ),
        ),
      ],
    );
  }

  //****** Page sub-components
  Widget _buildSectionHeader(String title) {
    final colorScheme = Theme.of(context).colorScheme;
    final titleStyle = Theme.of(
      context,
    ).textTheme.titleLarge?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
        );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: titleStyle),
          const Divider(height: 24, thickness: 2.0),
        ],
      ),
    );
  }

  Future<void> _showAddSocialHandleDialog(BuildContext context) async {
    _newSocialHandleController.clear();
    String? newHandle = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String? validationError;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Social Media Handle'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _newSocialHandleController,
                    decoration: InputDecoration(
                      labelText: 'Handle',
                      hintText: 'e.g., https://twitter.com/myusername',
                      border: const OutlineInputBorder(),
                      errorText: validationError,
                    ),
                    validator: (value) => validNonEmptyString(value, max: 100),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Add'),
                  onPressed: () {
                    final String input = _newSocialHandleController.text.trim();
                    final String? error =
                        validUrl(input); // Validate as URL here
                    if (error == null) {
                      Navigator.of(context).pop(input);
                    } else {
                      setDialogState(() {
                        validationError = error;
                      });
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );

    if (newHandle != null && newHandle.isNotEmpty) {
      if (!context.mounted) return;
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final String? currentRecipientId = userProvider.user?.id;

      if (currentRecipientId != null) {
        // Add to editableRecipient directly. Will be saved on form submission.
        setState(() {
          _editableRecipient.socialMediaHandles ??= [];
          _editableRecipient.socialMediaHandles!.add(
            SocialMediaHandle(
                socialMediaHandle: newHandle, recipientId: currentRecipientId),
          );
          _socialHandleErrors
              .add(null); // Add null for new handle's error state
        });
      } else {
        if (context.mounted) {
          showErrorSnackBar(
            context,
            'Could not add handle: Recipient ID not found.',
          );
        }
      }
    }
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _editableRecipient.dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (mounted && picked != null && picked != _editableRecipient.dateOfBirth) {
      setState(() {
        _editableRecipient = _editableRecipient.copyWith(dateOfBirth: picked);
        _dateOfBirthController.text = formatDate(picked, isShort: false);
        clearServerError('dateOfBirth');
      });
    }
  }

  //****** Helper functions
  void _submitChanges() async {
    setState(() {
      _isLoading = true;
      clearAllServerErrors();
    });

    final form = _formKey.currentState;
    if (form == null) {
      setState(() => _isLoading = false);
      return;
    }

    // Collect updated recipient data directly from controllers
    Recipient updatedRecipient = _editableRecipient.copyWith(
      firstName: _firstNameController.text,
      middleName: _middleNameController.text,
      lastName: _lastNameController.text,
      bio: _bioController.text,
      phoneNo: _phoneNoController.text,
      // Date of birth is already updated via _selectDateOfBirth into _editableRecipient
      // Social media handles are updated directly into _editableRecipient's list
    );

    // Client-side validation for social media handles
    bool allHandlesValid = true;
    // Ensure _socialHandleErrors has enough capacity for all handles
    if (_socialHandleErrors.length <
        (updatedRecipient.socialMediaHandles?.length ?? 0)) {
      _socialHandleErrors.addAll(List.generate(
        (updatedRecipient.socialMediaHandles?.length ?? 0) -
            _socialHandleErrors.length,
        (_) => null,
      ));
    }
    for (int i = 0;
        i < (updatedRecipient.socialMediaHandles?.length ?? 0);
        i++) {
      final handle = updatedRecipient.socialMediaHandles![i].socialMediaHandle;
      final error = validUrl(handle); // Use validUrl for social media handles
      _socialHandleErrors[i] = error;
      if (error != null) allHandlesValid = false;
    }

    // Trigger validation for all fields using their validators
    final isFormValid =
        _formKey.currentState!.validate(); // This runs all validators

    if (!isFormValid || !allHandlesValid) {
      setState(() => _isLoading = false);
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final accessToken = userProvider.credentials?.accessToken;

    if (accessToken == null) {
      if (context.mounted) {
        showErrorSnackBar(
          context,
          'You are not logged in. Please log in again.',
        );
      }
      setState(() => _isLoading = false);
      return;
    }

    final recipientService = Provider.of<RecipientService>(
      context,
      listen: false,
    );
    final result = await recipientService.updateRecipient(
      updatedRecipient, // Use the collected updatedRecipient
      _profilePicture,
      accessToken,
    );

    if (!mounted) return;
    await handleServiceResponse(
      context,
      result,
      successMessage: 'Profile updated successfully.',
      onSuccess: () async {
        if (mounted) {
          setState(() {
            _isEditing = false;
            _profilePicture = null;
          });
          // Update the user provider's recipient and the _editableRecipient
          // We fetch again to ensure all fields are up-to-date, including profile picture URL if changed server-side
          if (result.data == true) {
            // Assuming result.data indicates successful update
            final String recipientId = userProvider.user!.id as String;
            final updatedRecipientResponse =
                await recipientService.getRecipientById(
              recipientId,
              accessToken,
            );

            if (updatedRecipientResponse.data != null) {
              userProvider.setRecipient(updatedRecipientResponse.data);
              setState(() {
                _initialRecipient = updatedRecipientResponse.data!.copyWith();
                _editableRecipient = updatedRecipientResponse.data!.copyWith();
                // Re-initialize all controllers with new data
                _initializeControllers();
              });
            }

            clearAllServerErrors();
            _socialHandleErrors.clear();
            _socialHandleErrors.addAll(List.generate(
              _editableRecipient.socialMediaHandles?.length ?? 0,
              (_) => null,
            ));
            _formKey.currentState?.validate();
          }
        }
      },
      onValidationErrors: (errors) {
        setState(() => setServerErrors(errors));

        // Trigger form validation to show errors
        _formKey.currentState?.validate();
        // Manually update social handle errors for display if they come from server
        _updateSocialHandleErrorsFromServer(errors);
      },
    );

    setState(() => _isLoading = false);
  }

  void _updateSocialHandleErrorsFromServer(Map<String, List<String>> errors) {
    setState(() {
      _socialHandleErrors.clear();
      _socialHandleErrors.addAll(List.generate(
        _editableRecipient.socialMediaHandles?.length ?? 0,
        (_) => null,
      ));

      errors.forEach((key, value) {
        // Check for social media handle errors like 'socialMediaHandles.0.socialMediaHandle'
        final RegExp socialHandleErrorRegex =
            RegExp(r'socialMediaHandles\.(\d+)\.socialMediaHandle');
        final match = socialHandleErrorRegex.firstMatch(key);
        if (match != null) {
          final int index = int.parse(match.group(1)!);
          if (index < _socialHandleErrors.length) {
            _socialHandleErrors[index] = value.isNotEmpty ? value.first : null;
          }
        }
      });
    });
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Reset to initial state when exiting edit mode
        _editableRecipient = _initialRecipient.copyWith();
        _initializeControllers();
        _profilePicture = null;

        clearAllServerErrors();
        _socialHandleErrors.clear();
        _socialHandleErrors.addAll(List.generate(
          _editableRecipient.socialMediaHandles?.length ?? 0,
          (_) => null,
        ));
      }
      _formKey.currentState
          ?.validate(); // Validate to clear/show current errors based on mode
      _isLoading = false; // Ensure loading is off when toggling edit mode
    });
  }

  ImageProvider? _setProfilePicture() {
    var pictureUrl = _editableRecipient.profilePictureUrl;

    if (_profilePicture != null) {
      return FileImage(_profilePicture!);
    } else {
      return pictureUrl != null && pictureUrl.isNotEmpty
          ? NetworkImage(pictureUrl)
          : null;
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

  void _resetFields() {
    setState(() {
      _editableRecipient = _initialRecipient.copyWith();
      _initializeControllers();
      _profilePicture = null;
      clearAllServerErrors();

      // Clear and re-initialize social media handle validation errors
      _socialHandleErrors.clear();
      _socialHandleErrors.addAll(List.generate(
        _editableRecipient.socialMediaHandles?.length ?? 0,
        (_) => null,
      ));

      // Calling _formKey.currentState?.reset() here will clear the visual state of the fields and their validation messages.
      _formKey.currentState?.reset();
    });
  }

  Future<void> _fetchRecipient() async {
    setState(() => _isLoading = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final accessToken = userProvider.credentials?.accessToken;

    if (accessToken == null) {
      showErrorSnackBar(context, 'You are not logged in. Please log in again.');
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    if (!mounted) return;
    if (userProvider.user == null) {
      setState(() => _isLoading = false);
      return;
    }

    final result = await Provider.of<RecipientService>(
      context,
      listen: false,
    ).getRecipientById(
      userProvider.user!.id as String,
      accessToken,
    );

    if (!mounted) return;
    await handleServiceResponse(context, result, onSuccess: () {
      if (result.data != null) {
        setState(() {
          _initialRecipient = result.data!.copyWith();
          _editableRecipient = result.data!.copyWith();
          _initializeControllers();
          _socialHandleErrors.clear();
          _socialHandleErrors.addAll(List.generate(
            _editableRecipient.socialMediaHandles?.length ?? 0,
            (_) => null,
          ));
        });
      }
    });

    setState(() => _isLoading = false);
  }
}
