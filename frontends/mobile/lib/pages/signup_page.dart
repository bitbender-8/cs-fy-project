import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/components/custom_appbar.dart';
import 'package:mobile/components/styled_elevated_button.dart';
import 'package:mobile/utils/validators.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  File? _profilePicture;
  final _formKey = GlobalKey<FormState>();

  String? _firstName, _middleName, _lastName, _phoneNo, _bio;
  DateTime? _dateOfBirth;
  final List<String> _socialMediaHandles = [];
  final List<String?> _socialHandleErrors = [];

  final _socialController = TextEditingController();
  final _dobController = TextEditingController();

  Future<void> _pickProfilePicture() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _profilePicture = File(picked.path);
      });
    }
  }

  @override
  void dispose() {
    _socialController.dispose();
    _dobController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(pageTitle: "Recipient Sign Up"),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            children: [
              Row(
                children: [
                  Column(
                    children: [
                      const Text('Profile Picture'),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: _pickProfilePicture,
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
                          decoration: const InputDecoration(
                            labelText: "First name",
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              validNonEmptyString(value, max: 50),
                          onSaved: (value) => _firstName = value,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: "Middle name",
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              validNonEmptyString(value, max: 50),
                          onSaved: (value) => _middleName = value,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Last name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => validNonEmptyString(value, max: 50),
                onSaved: (value) => _lastName = value,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Phone number",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => validPhoneNo(value),
                onSaved: (value) => _phoneNo = value,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Bio",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) => validNonEmptyString(value, max: 500),
                onSaved: (value) => _bio = value,
              ),
              const SizedBox(height: 12),
              // Styled Date Picker
              TextFormField(
                controller: _dobController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: "Date of Birth",
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () => _selectDate(context),
                validator: (value) => validDate(value, isPast: true),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _socialController,
                decoration: InputDecoration(
                  labelText: "Add Social Media URL",
                  border: const OutlineInputBorder(),
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
                        setState(() {
                          // Optionally show error in a snackbar or below the field
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error)),
                          );
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Display each handle with its error:
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
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimary, // Text color
                          ),
                        ),
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primary, // Background color
                        onDeleted: () {
                          setState(() {
                            _socialMediaHandles.removeAt(i);
                            _socialHandleErrors.removeAt(i);
                          });
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
              const SizedBox(height: 24),
              StyledElevatedButton(
                onPressed: () {
                  bool socialValid = true;

                  // On form submit, validate all handles:
                  for (int i = 0; i < _socialMediaHandles.length; i++) {
                    final error = validUrl(_socialMediaHandles[i]);
                    _socialHandleErrors[i] = error;
                    if (error != null) socialValid = false;
                  }
                  if (_formKey.currentState!.validate() && socialValid) {
                    _formKey.currentState!.save();
                    Navigator.of(context).pop({
                      'profilePicture': _profilePicture,
                      'firstName': _firstName,
                      'middleName': _middleName,
                      'lastName': _lastName,
                      'phoneNo': _phoneNo,
                      'bio': _bio,
                      'dateOfBirth': _dateOfBirth,
                      'socialMediaHandles': _socialMediaHandles,
                    });
                  }
                },
                label: 'Continue',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
