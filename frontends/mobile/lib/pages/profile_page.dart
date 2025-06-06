import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/recipient.dart';
import 'package:mobile/models/server/errors.dart';
import 'package:mobile/services/providers.dart';
import 'package:mobile/services/recipient_service.dart';
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
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateOfBirthController = TextEditingController();
  bool _isEditing = false;
  bool _isLoading = false;

  late Recipient _editableRecipient;
  File? _profilePicture;

  final List<String?> _socialHandleErrors = [];
  final TextEditingController _newSocialHandleController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _editableRecipient = widget.initialRecipient.copyWith();

    if (_editableRecipient.dateOfBirth != null) {
      _dateOfBirthController.text = DateFormat('MMMM dd, yyyy').format(
        _editableRecipient.dateOfBirth!.toLocal(),
      );
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
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: _isEditing ? _pickProfilePicture : null,
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: colorScheme.primary.withAlpha(127),
                          backgroundImage: _profilePicture != null
                              ? FileImage(_profilePicture!)
                              : _editableRecipient.profilePictureUrl != null
                                  ? NetworkImage(
                                      "$apiUrl/files/public/${_editableRecipient.profilePictureUrl}",
                                    )
                                  : null,
                          child: (_profilePicture == null &&
                                  _editableRecipient.profilePictureUrl == null)
                              ? Icon(Icons.person,
                                  size: 40, color: colorScheme.primary)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: TextFormField(
                          initialValue: _editableRecipient.firstName,
                          readOnly: !_isEditing,
                          decoration: InputDecoration(
                            labelText: 'First Name',
                            border: const OutlineInputBorder(),
                            errorText: getServerError('firstName'),
                            prefixIcon: const Icon(Icons.person_outline),
                          ),
                          validator: (value) => validNonEmptyString(
                            value,
                            max: 50,
                          ),
                          onChanged: (val) => clearServerError('firstName'),
                          onSaved: (val) => _editableRecipient =
                              _editableRecipient.copyWith(firstName: val ?? ''),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      SizedBox(
                        width: 56.0,
                        height: 56.0,
                        child: Material(
                          color: colorScheme.error,
                          borderRadius: BorderRadius.circular(8.0),
                          child: InkWell(
                            onTap: _isLoading ? null : _logout,
                            borderRadius: BorderRadius.circular(8.0),
                            child: Center(
                              child: Icon(
                                Icons.logout,
                                color: colorScheme.onError,
                                size: 24.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: _editableRecipient.middleName,
                          readOnly: !_isEditing,
                          decoration: InputDecoration(
                            labelText: 'Middle Name',
                            border: const OutlineInputBorder(),
                            errorText: getServerError('middleName'),
                            prefixIcon: const Icon(Icons.person_outline),
                          ),
                          validator: (value) => validNonEmptyString(
                            value,
                            max: 50,
                          ),
                          onChanged: (val) => clearServerError('middleName'),
                          onSaved: (val) => _editableRecipient =
                              _editableRecipient.copyWith(
                                  middleName: val ?? ''),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: TextFormField(
                          initialValue: _editableRecipient.lastName,
                          readOnly: !_isEditing,
                          decoration: InputDecoration(
                            labelText: 'Last Name',
                            border: const OutlineInputBorder(),
                            errorText: getServerError('lastName'),
                            prefixIcon: const Icon(Icons.person_outline),
                          ),
                          validator: (value) => validNonEmptyString(
                            value,
                            max: 50,
                          ),
                          onChanged: (val) => clearServerError('lastName'),
                          onSaved: (val) => _editableRecipient =
                              _editableRecipient.copyWith(lastName: val ?? ''),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    readOnly: !_isEditing,
                    decoration: InputDecoration(
                      labelText: 'Date of birth',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.calendar_month),
                      errorText: getServerError('dateOfBirth'),
                    ),
                    controller: _dateOfBirthController,
                    onTap: () async {
                      if (_isEditing) await _selectDateOfBirth(context);
                    },
                    validator: (_) => validDate(
                      _editableRecipient.dateOfBirth?.toIso8601String(),
                      isPast: true,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    readOnly: !_isEditing,
                    decoration: InputDecoration(
                      labelText: 'Phone number',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.phone),
                      errorText: getServerError('phoneNo'),
                    ),
                    initialValue: _editableRecipient.phoneNo ?? '',
                    keyboardType: TextInputType.phone,
                    validator: (val) => validPhoneNo(val),
                    onSaved: (val) => _editableRecipient =
                        _editableRecipient.copyWith(phoneNo: val ?? ''),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    initialValue: _editableRecipient.email ?? '',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    readOnly: !_isEditing,
                    decoration: InputDecoration(
                      labelText: 'Bio',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.info),
                      errorText: getServerError('bio'),
                    ),
                    initialValue: _editableRecipient.bio,
                    keyboardType: TextInputType.multiline,
                    maxLines: 5,
                    validator: (val) => validNonEmptyString(val, max: 500),
                    onSaved: (val) => _editableRecipient =
                        _editableRecipient.copyWith(bio: val ?? ''),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Social Media Handles',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (_isEditing)
                        TextButton.icon(
                          onPressed: () => _showAddSocialHandleDialog(context),
                          icon: Icon(
                            Icons.add_link,
                            color: colorScheme.primary,
                          ),
                          label: const Text('Add Social'),
                        ),
                    ],
                  ),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: List.generate(
                      _editableRecipient.socialMediaHandles?.length ?? 0,
                      (i) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Chip(
                              label: Text(
                                _editableRecipient
                                    .socialMediaHandles![i].socialMediaHandle,
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              deleteIcon: _isEditing && !_isLoading
                                  ? Icon(
                                      Icons.cancel,
                                      color: colorScheme.onPrimary,
                                    )
                                  : null,
                              onDeleted: _isEditing
                                  ? () {
                                      setState(() {
                                        _editableRecipient.socialMediaHandles
                                            ?.removeAt(i);
                                        if (i < _socialHandleErrors.length) {
                                          _socialHandleErrors.removeAt(i);
                                        }
                                      });
                                    }
                                  : null,
                            ),
                            if (_socialHandleErrors.length > i &&
                                _socialHandleErrors[i] != null)
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 4, bottom: 4),
                                child: Text(
                                  _socialHandleErrors[i]!,
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 12),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  // Show Cancel and Submit buttons ONLY when in editing mode
                  if (_isEditing)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () =>
                                _isLoading ? null : _toggleEditMode(),
                            style: TextButton.styleFrom(
                              foregroundColor: colorScheme.onError,
                              backgroundColor: colorScheme.error,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: TextButton(
                            onPressed: _isLoading
                                ? null
                                : () => _submitChanges(context),
                            style: TextButton.styleFrom(
                              backgroundColor: _isLoading
                                  ? Colors.grey // Indicate loading
                                  : colorScheme.primary,
                              foregroundColor: _isLoading
                                  ? Colors.black38 // Dim text when loading
                                  : colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: const Text('Submit'),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
        if (_isLoading && _isEditing)
          Positioned.fill(
            child: Container(
              color: Colors.black.withAlpha(127),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        // Show Floating Action Button ONLY when NOT in editing mode
        if (!_isEditing)
          SafeArea(
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FloatingActionButton(
                  onPressed: _isLoading ? null : _toggleEditMode,
                  child: const Icon(Icons.edit),
                ),
              ),
            ),
          ),
      ],
    );
  }

  //****** Helper functions
  void _logout() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.logout();
  }

  void _submitChanges(BuildContext context) async {
    setState(() {
      _isLoading = true;
      clearAllServerErrors();
    });

    // Validate form fields
    final isFormValid = _formKey.currentState!.validate();

    // Validate social media handles
    bool allHandlesValid = true;
    for (int i = 0;
        i < (_editableRecipient.socialMediaHandles?.length ?? 0);
        i++) {
      final handle =
          _editableRecipient.socialMediaHandles![i].socialMediaHandle;
      final error = validNonEmptyString(handle, max: 100);
      _socialHandleErrors[i] = error;
      if (error != null) {
        allHandlesValid = false;
      }
    }

    setState(() {
      _isLoading = false;
    });

    // Stop if any validations failed
    if (!isFormValid || !allHandlesValid) return;

    // Save form data
    _formKey.currentState!.save();

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final accessToken = userProvider.credentials?.accessToken;
    final recipientService =
        Provider.of<RecipientService>(context, listen: false);

    if (accessToken == null) {
      showErrorSnackBar(context, 'You are not logged in. Please log in again.');
      return;
    }

    setState(() => _isLoading = true);

    print(jsonEncode(_editableRecipient.toJson()));

    final result = await recipientService.updateRecipient(
      _editableRecipient,
      _profilePicture,
      accessToken,
    );

    if (!context.mounted) return;

    await handleServiceResponse(
      context,
      result,
      successMessage: 'Profile updated successfully.',
      onSuccess: () {
        if (mounted) {
          setState(() {
            _isEditing = false;
            _profilePicture = null;
          });
        }
      },
      onValidationErrors: (errors) {
        setState(() {
          setServerErrors(errors);
        });
        _formKey.currentState?.validate();
      },
    );

    if (context.mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _editableRecipient = widget.initialRecipient.copyWith();
        _profilePicture = null;

        clearAllServerErrors();
        _socialHandleErrors.clear();
        _socialHandleErrors.addAll(List.generate(
          _editableRecipient.socialMediaHandles?.length ?? 0,
          (_) => null,
        ));
      }
      _formKey.currentState?.validate();
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
        _dateOfBirthController.text =
            DateFormat('MMMM dd, yyyy').format(picked);
        clearServerError('dateOfBirth');
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
        showErrorSnackBar(
          context,
          'Could not add handle: Recipient ID not found.',
        );
      }
    }
  }

  void _addSocialHandle(String handle, String recipientId) {
    setState(() {
      _editableRecipient.socialMediaHandles ??= [];
      _editableRecipient.socialMediaHandles!.add(
        SocialMediaHandle(socialMediaHandle: handle, recipientId: recipientId),
      );
      _socialHandleErrors.add(null);
    });
  }
}
