import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mobile/models/campaign.dart';
import 'package:mobile/utils/validators.dart';

class AddCampaignPage extends StatefulWidget {
  const AddCampaignPage({super.key});

  @override
  State<AddCampaignPage> createState() => _AddCampaignPageState();
}

class _AddCampaignPageState extends State<AddCampaignPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _endDateController = TextEditingController();

  String _title = '';
  String _description = '';
  String _fundraisingGoal = '';
  String _category = CampaignCategories.charity.value; // Default category
  DateTime? _endDate;

  String? _selectedPaymentMethod;
  String _bankName = '';
  String _bankAccountNumber = '';
  String _phoneNumber = '';

  final List<PlatformFile> _selectedDocuments = []; // To store selected files

  bool _isLoading = false;
  bool _isAccurateCheckboxChecked = false; // For the confirmation dialog

  // Simulated data - replace with actual checks/calls
  bool _hasPendingCampaign = false; // Simulate no pending campaign for now
  final List<String> _availableBanks = [
    'Bank A',
    'Bank B',
    'Bank C'
  ]; // Example bank list

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now().add(const Duration(days: 3)),
      firstDate: DateTime.now().add(const Duration(days: 3)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme,
          ),
          child: child!,
        );
      },
    );
    if (!mounted) return;

    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
        _endDateController.text = DateFormat('yyyy-MM-dd').format(_endDate!);
      });
    }
  }

  Future<void> _pickDocuments() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
      withData: true, // Required to check file size
    );

    // Check if the widget is still mounted after the async operation
    if (!mounted) return;

    if (result != null) {
      // Validate selected files
      List<PlatformFile> validFiles = [];
      for (PlatformFile file in result.files) {
        if (file.size <= 5 * 1024 * 1024) {
          // 5 MB limit
          validFiles.add(file);
        } else {
          // Optionally show a message for files exceeding the size limit
          // Guard ScaffoldMessenger use with mounted check
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('File ${file.name} exceeds the 5 MB limit.')),
            );
          }
        }
      }

      if ((_selectedDocuments.length + validFiles.length) > 15) {
        // Guard ScaffoldMessenger use with mounted check
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('You can upload a maximum of 15 documents.')),
          );
        }
        validFiles = validFiles
            .take(15 - _selectedDocuments.length)
            .toList(); // Take only up to the limit
      }

      // Guard setState with mounted check
      if (mounted) {
        setState(() {
          _selectedDocuments.addAll(validFiles);
        });
      }
    }
  }

  void _removeDocument(int index) {
    setState(() {
      _selectedDocuments.removeAt(index);
    });
  }

  void _showConfirmationDialog() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Simulate checking for pending campaign (Alternative Flow 4.2)
      // In a real app, this would be an async call.
      // If the check were async, we'd need mounted guards here.
      // As it's currently simulated as sync, no guard needed here for this specific check.
      if (_hasPendingCampaign) {
        // Guard ScaffoldMessenger use with mounted check
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('You already have a pending campaign.')),
          );
        }
        return; // Prevent showing the dialog if a pending campaign exists
      }

      // Reset checkbox state before showing dialog
      _isAccurateCheckboxChecked = false;

      // showDialog uses the context it's given, and its builder function's
      // context is tied to the dialog's lifecycle. The issue arises from
      // code *after* the await showDialog call.

      showDialog(
        context: context,
        barrierDismissible: false, // User must interact with the dialog
        builder: (BuildContext context) {
          final colorScheme = Theme.of(context).colorScheme;
          return AlertDialog(
            title: const Text('Confirm Campaign Details'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Title: $_title'),
                  Text('Description: $_description'),
                  Text('Fundraising Goal: $_fundraisingGoal ETB'),
                  Text('Category: $_category'),
                  Text(
                      'End Date: ${_endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : 'Not set'}'),
                  const SizedBox(height: 16),
                  Text(
                      'Payment Method: ${_selectedPaymentMethod ?? 'Not selected'}'),
                  if (_selectedPaymentMethod ==
                      PaymentMethods.bankTransfer.value) ...[
                    Text('Bank Name: $_bankName'),
                    Text('Account Number: $_bankAccountNumber'),
                  ] else if (_selectedPaymentMethod ==
                      PaymentMethods.mobileMoney.value) ...[
                    Text('Phone Number: $_phoneNumber'),
                  ],
                  const SizedBox(height: 16),
                  Text('Documents Uploaded: ${_selectedDocuments.length}'),
                  const SizedBox(height: 16),
                  StatefulBuilder(
                      // Use StatefulBuilder to update checkbox state within dialog
                      builder: (BuildContext context, StateSetter setState) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _isAccurateCheckboxChecked,
                          onChanged: (bool? value) {
                            setState(() {
                              _isAccurateCheckboxChecked = value ?? false;
                            });
                            // Also update the state in the main widget
                            // Guard setState with mounted check
                            if (mounted) {
                              this.setState(() {
                                _isAccurateCheckboxChecked = value ?? false;
                              });
                            }
                          },
                          activeColor: colorScheme.primary,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 8.0), // Align text vertically
                            child: Text(
                              'The information and documents I have provided are accurate.',
                              style: TextStyle(color: colorScheme.onSurface),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child:
                    Text('Edit', style: TextStyle(color: colorScheme.primary)),
                onPressed: () {
                  // Navigator.of(context).pop() is safe as it uses the dialog's context
                  Navigator.of(context).pop(); // Close the dialog
                  // Checkbox state is already reset before showing the dialog
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
                onPressed: _isAccurateCheckboxChecked
                    ? () {
                        // Navigator.of(context).pop() is safe
                        Navigator.of(context).pop(); // Close the dialog
                        _submitCampaign(); // Proceed with submission
                      }
                    : null, // Disable button if checkbox is not checked
                child: const Text('Confirm and Submit'),
              ),
            ],
          );
        },
      );
    }
  }

  void _submitCampaign() async {
    // This function is now called *after* the confirmation dialog
    // and the checkbox is checked.
    // Guard setState with mounted check
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    // Simulate the campaign creation process (Step 7)
    // In a real application, this is where you'd send the data to your backend API
    await Future.delayed(const Duration(seconds: 3)); // Simulate network delay

    // Check if widget is still mounted after the async operation before using context
    if (!mounted) return;

    // Simulate success message (Step 7)
    // Guard ScaffoldMessenger use with mounted check
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Your campaign has been submitted for review.')),
    );

    // Guard setState with mounted check
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }

    // Redirect to the homepage 
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Campaign'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 1.0, // Add a subtle shadow
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      'Create your campaign',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 24.0), // Spacing after main title

                    Text(
                      'Campaign Information',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: colorScheme.primary),
                    ),
                    const Divider(
                        height: 24, thickness: 1.0), // Visual separator
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Campaign Title',
                        hintText: 'Enter the campaign title',
                        border: const OutlineInputBorder(),
                        prefixIcon:
                            Icon(Icons.title, color: colorScheme.primary),
                      ),
                      maxLength:
                          100, // Keep maxLength for visual enforcement and counter
                      validator: (value) =>
                          validNonEmptyString(value, max: 100),
                      onSaved: (value) {
                        _title = value!;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Campaign Description',
                        hintText: 'Enter the campaign description',
                        border: const OutlineInputBorder(),
                        prefixIcon:
                            Icon(Icons.description, color: colorScheme.primary),
                      ),
                      maxLines: 5,
                      validator: (value) =>
                          validNonEmptyString(value, min: 10, max: 500),
                      onSaved: (value) {
                        _description = value!;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Fundraising Goal',
                        hintText: 'Enter the amount of money you plan to raise',
                        border: const OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money,
                            color: colorScheme.primary),
                        suffixText:
                            'ETB', // Add ETB suffix as seen in the image
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      validator: (value) {
                        final moneyValidation = validMoneyAmount(
                            value, 1000000000.0); // Example higher max
                        if (moneyValidation != null) return moneyValidation;
                        final goal = double.tryParse(value ?? '0');
                        if (goal != null && goal < 100) {
                          return 'Must be at least 100 ETB';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _fundraisingGoal = value!;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _endDateController,
                      decoration: InputDecoration(
                        labelText: 'Campaign End Date',
                        hintText: 'Enter campaign end date',
                        border: const OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today,
                            color: colorScheme.primary),
                      ),
                      readOnly:
                          true, // Make it read-only so date picker is the only input method
                      onTap: () => _selectEndDate(context),
                      validator: (value) {
                        final dateValidation = validDate(value, isPast: false);
                        if (dateValidation != null) return dateValidation;

                        // Additional validation for min/max duration based on selected date
                        if (_endDate != null) {
                          final now = DateTime.now();
                          final difference = _endDate!.difference(now);
                          if (difference.inDays < 3) {
                            return 'Must have a minimum duration of 3 days';
                          }
                          if (difference.inDays > 365) {
                            return 'Can have a maximum duration of 1 year';
                          }
                        }
                        return null;
                      },
                      onSaved: (value) {
                        if (value != null && value.isNotEmpty) {
                          try {
                            _endDate = DateFormat('yyyy-MM-dd').parse(value);
                          } catch (e) {
                            debugPrint('Error parsing end date on save: $e');
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 16.0),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Campaign Category',
                        hintText: 'Select a category',
                        border: const OutlineInputBorder(),
                        prefixIcon:
                            Icon(Icons.category, color: colorScheme.primary),
                      ),
                      value: _category,
                      items: CampaignCategories.values.map((category) {
                        return DropdownMenuItem(
                          value: category.value,
                          child: Text(category.value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _category = value!;
                        });
                      },
                      validator: (value) {
                        // Use the provided validEnum validator
                        return validEnum(
                            value,
                            CampaignCategories.values
                                .map((e) => e.value)
                                .toList(),
                            'Category');
                      },
                      onSaved: (value) {
                        _category = value!;
                      },
                    ),
                    const SizedBox(height: 24.0),

                    Text(
                      'Payment Information',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: colorScheme.primary),
                    ),
                    const Divider(
                        height: 24, thickness: 1.0), // Visual separator

                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Payment Method',
                        hintText: 'Select a payment method',
                        border: const OutlineInputBorder(),
                        prefixIcon:
                            Icon(Icons.payment, color: colorScheme.primary),
                      ),
                      value: _selectedPaymentMethod,
                      items: PaymentMethods.values.map((method) {
                        return DropdownMenuItem(
                          value: method.value,
                          child: Text(method.value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentMethod = value!;
                          // Clear previous payment info when method changes
                          _bankName = '';
                          _bankAccountNumber = '';
                          _phoneNumber = '';
                          // Reset validation for payment fields when method changes
                          _formKey.currentState?.validate();
                        });
                      },
                      validator: (value) {
                        // Use the provided validEnum validator
                        return validEnum(
                            value,
                            PaymentMethods.values.map((e) => e.value).toList(),
                            'Payment Method');
                      },
                      onSaved: (value) {
                        _selectedPaymentMethod = value;
                      },
                    ),
                    const SizedBox(height: 16.0),

                    if (_selectedPaymentMethod ==
                        PaymentMethods.bankTransfer.value) ...[
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Bank Name',
                          hintText: 'Select your bank',
                          border: const OutlineInputBorder(),
                          prefixIcon: Icon(Icons.account_balance,
                              color: colorScheme.primary),
                        ),
                        value: _bankName.isNotEmpty
                            ? _bankName
                            : null, // Use null if not set to show hint
                        items: _availableBanks.map((bank) {
                          return DropdownMenuItem(
                            value: bank,
                            child: Text(bank),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _bankName = value!;
                          });
                        },
                        validator: (value) {
                          if (_selectedPaymentMethod ==
                              PaymentMethods.bankTransfer.value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a bank';
                            }
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _bankName = value ?? '';
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Bank Account Number',
                          hintText: 'Enter bank account number',
                          border: const OutlineInputBorder(),
                          prefixIcon: Icon(Icons.account_balance_wallet,
                              color: colorScheme.primary),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        validator: (value) {
                          if (_selectedPaymentMethod ==
                              PaymentMethods.bankTransfer.value) {
                            // Use the provided validBankAccountNo validator
                            return validBankAccountNo(value);
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _bankAccountNumber = value ?? '';
                        },
                      ),
                    ] else if (_selectedPaymentMethod ==
                        PaymentMethods.mobileMoney.value) ...[
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          hintText: 'Enter phone number in E.164 format',
                          border: const OutlineInputBorder(),
                          prefixIcon:
                              Icon(Icons.phone, color: colorScheme.primary),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (_selectedPaymentMethod ==
                              PaymentMethods.mobileMoney.value) {
                            return validPhoneNo(
                                value); // Use the provided validator
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _phoneNumber = value ?? '';
                        },
                      ),
                    ],
                    const SizedBox(height: 24.0),

                    Text(
                      'Supporting Documents',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: colorScheme.primary),
                    ),
                    const Divider(
                        height: 24, thickness: 1.0), // Visual separator

                    // Text providing guidance for document uploads
                    Text(
                      'You may attach up to 15 files under the size of 5 MB each. '
                      'Supported file types: PDF, JPG, PNG.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 8.0),

                    OutlinedButton.icon(
                      onPressed: _isLoading ? null : _pickDocuments,
                      icon: Icon(Icons.attach_file, color: colorScheme.primary),
                      label: Text('Attach files',
                          style: TextStyle(color: colorScheme.primary)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: colorScheme.primary), // Green border
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 16.0),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    if (_selectedDocuments.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Selected Files:',
                              style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: 8.0),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _selectedDocuments.length,
                            itemBuilder: (context, index) {
                              final file = _selectedDocuments[index];
                              return Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      file.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.red, size: 20),
                                    onPressed: _isLoading
                                        ? null
                                        : () => _removeDocument(index),
                                    tooltip: 'Remove file',
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),

                    const SizedBox(height: 32.0), // More space before buttons

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.end, // Align buttons to the right
                      children: [
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  Navigator.pop(context); // Cancel and go back
                                },
                          child: Text('Cancel',
                              style: TextStyle(
                                  color: colorScheme.onSurfaceVariant)),
                        ),
                        const SizedBox(width: 16.0),
                        ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : _showConfirmationDialog, // Show dialog
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary, // Green color
                            foregroundColor: colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24.0, vertical: 12.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        colorScheme.onPrimary),
                                    strokeWidth: 2.0,
                                  ),
                                )
                              : const Text('Submit Campaign'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            ModalBarrier(
              color: Colors.black.withValues(alpha: 0.5),
              dismissible: false,
            ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
