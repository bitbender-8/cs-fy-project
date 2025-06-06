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

  @override
  void dispose() {
    _socialController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              // Header Section
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

              // Profile Picture Section
              const Text(
                'Profile Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
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
                            labelText: "First name*",
                            border: OutlineInputBorder(),
                            hintText: "Enter your first name",
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
                            hintText: "Enter your middle name (optional)",
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
                  labelText: "Last name*",
                  border: OutlineInputBorder(),
                  hintText: "Enter your last name",
                ),
                validator: (value) => validNonEmptyString(value, max: 50),
                onSaved: (value) => _lastName = value,
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Bio*",
                  border: OutlineInputBorder(),
                  hintText: "Tell us about yourself (max 500 characters)",
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                validator: (value) => validNonEmptyString(value, max: 500),
                onSaved: (value) => _bio = value,
              ),
              const SizedBox(height: 12),
              // Date of Birth Picker
              TextFormField(
                controller: _dobController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: "Date of Birth*",
                  border: OutlineInputBorder(),
                  hintText: "Select your date of birth",
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () => _selectDate(context),
                validator: (value) => validDate(value, isPast: true),
              ),
              const SizedBox(height: 20),

              const Text(
                'Contact Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Phone number*",
                  border: OutlineInputBorder(),
                  hintText: "Enter your phone number",
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => validPhoneNo(value),
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
                        setState(() {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(error),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Help text for social media
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text(
                  'Example: https://facebook.com/yourname or https://twitter.com/yourhandle',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
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
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary,
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
              const SizedBox(height: 32),

              // Form Submission
              const Text(
                '* indicates required fields',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 16),
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
                label: 'Create Account',
              ),
            ],
          ),
        ),
      ),
    );
  }

  //****** Helper functions
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
}
