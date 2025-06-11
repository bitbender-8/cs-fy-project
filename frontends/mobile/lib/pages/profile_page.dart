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

class ProfilePage extends StatefulWidget {
  final Recipient initialRecipient;

  const ProfilePage({super.key, required this.initialRecipient});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with FormErrorHelpers<ProfilePage> {
  late final Recipient _initialRecipient;
  final _formKey = GlobalKey<FormState>();

  final _dateOfBirthController = TextEditingController();
  final _newSocialHandleController = TextEditingController();
  final List<String?> _socialHandleErrors = [];
  late Recipient _editableRecipient;
  File? _profilePicture;

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _initialRecipient = widget.initialRecipient.copyWith();
    _fetchRecipient();
    _editableRecipient = _initialRecipient.copyWith();

    if (_editableRecipient.dateOfBirth != null) {
      _dateOfBirthController.text =
          formatDate(_editableRecipient.dateOfBirth!.toLocal(), isShort: false);
    }

    _socialHandleErrors.addAll(List.generate(
      _editableRecipient.socialMediaHandles?.length ?? 0,
      (_) => null,
    ));
  }

  @override
  void dispose() {
    _dateOfBirthController.dispose();
    _newSocialHandleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageWithFloatingButton(
      body: Stack(
        children: [
          _buildForm(),
          if (_isEditing && _isLoading) _buildLoadingOverlay(),
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
        color: Colors.black.withValues(alpha: 0.5),
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: RefreshIndicator(
            onRefresh: () async {
              await _fetchRecipient();
              print("df");
              _resetFields();
            },
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
          )),
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
          initialValue: _editableRecipient.firstName,
          readOnly: !_isEditing,
          decoration: const InputDecoration(
            labelText: 'First Name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person_outline),
          ),
          validator: (value) => validNonEmptyString(value, max: 50),
          onSaved: (val) => setState(() {
            _editableRecipient = _editableRecipient.copyWith(
              firstName: val ?? '',
            );
          }),
        ),
        const SizedBox(height: 16.0),
        TextFormField(
          initialValue: _editableRecipient.middleName,
          readOnly: !_isEditing,
          decoration: const InputDecoration(
            labelText: 'Middle Name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person_outline),
          ),
          validator: (value) => validNonEmptyString(value, max: 50),
          onSaved: (val) => setState(() {
            _editableRecipient = _editableRecipient.copyWith(
              middleName: val ?? '',
            );
          }),
        ),
        const SizedBox(height: 16.0),
        TextFormField(
          initialValue: _editableRecipient.lastName,
          readOnly: !_isEditing,
          decoration: const InputDecoration(
            labelText: 'Last Name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person_outline),
          ),
          validator: (value) => validNonEmptyString(value, max: 50),
          onSaved: (val) => setState(() {
            _editableRecipient = _editableRecipient.copyWith(
              lastName: val ?? '',
            );
          }),
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
          initialValue: _editableRecipient.bio,
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
          onSaved: (val) => setState(() {
            _editableRecipient = _editableRecipient.copyWith(
              bio: val ?? '',
            );
          }),
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
          initialValue: _editableRecipient.phoneNo ?? '',
          readOnly: !_isEditing,
          decoration: InputDecoration(
            labelText: 'Phone Number',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.phone),
            errorText: getServerError('phoneNo'),
          ),
          keyboardType: TextInputType.phone,
          validator: (val) => validPhoneNo(val),
          onSaved: (val) => setState(() {
            _editableRecipient = _editableRecipient.copyWith(
              phoneNo: val ?? '',
            );
          }),
        ),
        const SizedBox(height: 16.0),
        TextFormField(
          initialValue: _editableRecipient.email ?? '',
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
              return Chip(
                label: Text(
                  _editableRecipient.socialMediaHandles![i].socialMediaHandle,
                ),
                labelStyle: TextStyle(color: colorScheme.onSecondaryContainer),
                backgroundColor: colorScheme.secondaryContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: BorderSide(color: colorScheme.outlineVariant),
                ),
                onDeleted: _isEditing
                    ? () {
                        setState(() {
                          _editableRecipient.socialMediaHandles?.removeAt(i);
                          if (i < _socialHandleErrors.length) {
                            _socialHandleErrors.removeAt(i);
                          }
                        });
                      }
                    : null,
                deleteIcon: _isEditing && !_isLoading
                    ? Icon(
                        Icons.close,
                        size: 18,
                        color: colorScheme.onSecondaryContainer,
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
                // Added shape
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
                    final String? error = validNonEmptyString(input, max: 100);

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
        _addSocialHandle(newHandle, currentRecipientId);
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

  void _addSocialHandle(String handle, String recipientId) {
    setState(() {
      _editableRecipient.socialMediaHandles ??= [];
      _editableRecipient.socialMediaHandles!.add(
        SocialMediaHandle(socialMediaHandle: handle, recipientId: recipientId),
      );
      _socialHandleErrors.add(null); // Add null for new handle's error state
    });
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

    final isFormValid = _formKey.currentState!.validate();

    bool allHandlesValid = true;
    for (int i = 0;
        i < (_editableRecipient.socialMediaHandles?.length ?? 0);
        i++) {
      final handle =
          _editableRecipient.socialMediaHandles![i].socialMediaHandle;

      final error = validUrl(handle);
      _socialHandleErrors[i] = error;
      if (error != null) allHandlesValid = false;
    }

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
      _editableRecipient,
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
          // Update the user provider's recipient after successful save
          if (result.data == true) {
            final String recipientId = userProvider.user!.id as String;
            final updatedRecipient = await recipientService.getRecipientById(
              recipientId,
              accessToken,
            );

            userProvider.setRecipient(updatedRecipient.data);
            _editableRecipient = updatedRecipient.data!.copyWith();

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
      },
    );

    setState(() => _isLoading = false);
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Reset to initial state when exiting edit mode
        _editableRecipient = _initialRecipient.copyWith();
        _profilePicture = null;

        clearAllServerErrors();
        _socialHandleErrors.clear();
        _socialHandleErrors.addAll(List.generate(
          _editableRecipient.socialMediaHandles?.length ?? 0,
          (_) => null,
        ));
      }
      _formKey.currentState?.validate();
      // Ensure loading is off when toggling edit mode
      _isLoading = false;
    });
  }

  ImageProvider? _setProfilePicture() {
    var pictureUrl = _editableRecipient.profilePictureUrl;

    if (_profilePicture != null) {
      return FileImage(_profilePicture!);
    } else {
      return pictureUrl != null ? NetworkImage(pictureUrl) : null;
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
      _profilePicture = null;
      clearAllServerErrors();

      // Clear and re-initialize social media handle validation errors
      _socialHandleErrors.clear();
      _socialHandleErrors.addAll(List.generate(
        _editableRecipient.socialMediaHandles?.length ?? 0,
        (_) => null,
      ));

      // Reset the form fields to their initial values and clear their validation messages
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
    if (userProvider.user == null) return;

    final result = await Provider.of<RecipientService>(
      context,
      listen: false,
    ).getRecipientById(
      userProvider.user!.id as String,
      accessToken,
    );

    if (!mounted) return;
    await handleServiceResponse(context, result, onSuccess: () {
      if (result.data == null) return;
      setState(() => _initialRecipient = result.data as Recipient);
    });

    setState(() => _isLoading = false);
  }
}
