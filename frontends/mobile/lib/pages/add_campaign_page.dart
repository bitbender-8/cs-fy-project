import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:mobile/models/server/errors.dart';
import 'package:provider/provider.dart';

import 'package:mobile/components/custom_appbar.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/campaign.dart';
import 'package:mobile/models/payment_info.dart';
import 'package:mobile/services/campaign_service.dart';
import 'package:mobile/services/providers.dart';
import 'package:mobile/utils/utils.dart';
import 'package:mobile/utils/validators.dart';

class AddCampaignPage extends StatefulWidget {
  const AddCampaignPage({super.key});

  @override
  State<AddCampaignPage> createState() => _AddCampaignPageState();
}

class _AddCampaignPageState extends State<AddCampaignPage>
    with FormErrorHelpers<AddCampaignPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String _title = '',
      _description = '',
      _fundraisingGoal = '',
      _category = CampaignCategories.charity.value;
  DateTime _endDate = DateTime.now().add(const Duration(days: 90));

  final List<PlatformFile> _supportingDocuments = [];
  PaymentInfo _paymentInfo = PaymentInfo(
    chapaBankCode: ChapaBanks.commercialBankOfEthiopia.code,
    chapaBankName: ChapaBanks.commercialBankOfEthiopia.name,
    bankAccountNo: '',
  );

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _fundraisingGoalController =
      TextEditingController();
  final TextEditingController _bankAccountNoController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.text = _title;
    _descriptionController.text = _description;
    _fundraisingGoalController.text = _fundraisingGoal;
    _bankAccountNoController.text = _paymentInfo.bankAccountNo;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _fundraisingGoalController.dispose();
    _bankAccountNoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final titleStyle = Theme.of(context)
        .textTheme
        .titleLarge
        ?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold);

    return Scaffold(
      appBar: const CustomAppBar(pageTitle: 'Campaign Application'),
      body: Stack(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              children: [
                const SizedBox(height: 8.0),
                Text('Campaign Information', style: titleStyle),
                const Divider(height: 24, thickness: 2.0),
                ..._buildCampaignInformationSection(context, colorScheme),
                const SizedBox(height: 20.0),
                Text('Supporting Documents', style: titleStyle),
                const Divider(height: 24, thickness: 2.0),
                ..._buildSupportingDocumentsSection(context, colorScheme),
                const SizedBox(height: 20.0),
                Text('Payment Information', style: titleStyle),
                const Divider(height: 24, thickness: 2.0),
                ..._buildPaymentInfoSection(context, colorScheme),
                const SizedBox(height: 40.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () async => await _submitCampaign(context),
                        style: TextButton.styleFrom(
                          foregroundColor: colorScheme.onPrimary,
                          backgroundColor: colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text("Submit"),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: colorScheme.onError,
                          backgroundColor: colorScheme.error,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text("Cancel"),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        if (_isLoading) ...[
          ModalBarrier(
            color: Colors.black.withValues(alpha: 0.5),
            dismissible: false,
          ),
          const Center(
            child: CircularProgressIndicator(),
          )
        ],
      ]),
    );
  }

  //***** Page sections
  List<Widget> _buildCampaignInformationSection(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return <Widget>[
      TextFormField(
        controller: _titleController,
        decoration: InputDecoration(
          labelText: 'Campaign Title',
          hintText: 'Enter the campaign title',
          border: const OutlineInputBorder(),
          prefixIcon: Icon(Icons.title, color: colorScheme.primary),
          errorText: getServerError('title'),
        ),
        maxLength: 100,
        onChanged: (value) {
          setState(() => _title = value);
          clearServerError('title');
        },
        validator: (value) => validNonEmptyString(value, max: 100),
        onSaved: (value) => _title = value ?? '',
      ),
      const SizedBox(height: 10),
      TextFormField(
        controller: _descriptionController,
        decoration: InputDecoration(
          labelText: 'Campaign Description',
          hintText: 'Enter the campaign description',
          border: const OutlineInputBorder(),
          prefixIcon: Icon(Icons.description, color: colorScheme.primary),
          errorText: getServerError('description'),
        ),
        maxLines: 5,
        maxLength: 500,
        onChanged: (value) {
          setState(() => _description = value);
          clearServerError('description');
        },
        validator: (value) => validNonEmptyString(value, max: 500),
        onSaved: (value) => _description = value ?? '',
      ),
      const SizedBox(height: 10),
      TextFormField(
        controller: _fundraisingGoalController,
        decoration: InputDecoration(
          labelText: 'Fundraising Goal',
          hintText: 'Enter the fundraising goal',
          border: const OutlineInputBorder(),
          prefixIcon: Icon(Icons.attach_money, color: colorScheme.primary),
          suffixText: 'ETB',
          errorText: getServerError('fundraisingGoal'),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
        ],
        onChanged: (value) {
          setState(() => _fundraisingGoal = value);
          clearServerError('fundraisingGoal');
        },
        validator: (value) {
          final valResult = validMoneyAmount(value, maxMoneyAmount);
          if (valResult != null) return valResult;

          final goal = double.tryParse(value ?? '0') ?? 0;
          if (goal < 100) return 'Fundraising goal must be at least 100 ETB';

          return null;
        },
        onSaved: (value) => _fundraisingGoal = value ?? '',
      ),
      const SizedBox(height: 16),
      TextFormField(
        decoration: InputDecoration(
          labelText: 'Campaign End Date',
          hintText: 'Enter the campaign end date',
          border: const OutlineInputBorder(),
          prefixIcon: Icon(Icons.calendar_today, color: colorScheme.primary),
          errorText: getServerError('endDate'),
        ),
        readOnly: true,
        onTap: () async {
          await _selectEndDate(context);
          clearServerError('endDate');
        },
        initialValue: DateFormat('MMMM dd, yyyy').format(_endDate),
        validator: (value) =>
            validDate(_endDate.toIso8601String(), isPast: false),
      ),
      const SizedBox(height: 16),
      DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Campaign Category',
          hintText: 'Select a category',
          border: const OutlineInputBorder(),
          prefixIcon: Icon(Icons.category, color: colorScheme.primary),
          errorText: getServerError('category'),
        ),
        value: _category,
        items: CampaignCategories.values.map((category) {
          return DropdownMenuItem<String>(
            value: category.value,
            child: Text(category.value),
          );
        }).toList(),
        onChanged: (value) {
          setState(() => _category = value!);
          clearServerError('category');
        },
        validator: (value) {
          return validEnum(
            value,
            CampaignCategories.values.map((e) => e.value).toList(),
            'Campaign Category',
          );
        },
        onSaved: (value) => _category = value!,
      ),
    ];
  }

  List<Widget> _buildPaymentInfoSection(
      BuildContext context, ColorScheme colorScheme) {
    return <Widget>[
      DropdownButtonFormField<int>(
        decoration: InputDecoration(
          labelText: 'Bank Name',
          hintText: 'Select your bank',
          border: const OutlineInputBorder(),
          prefixIcon: Icon(Icons.account_balance, color: colorScheme.primary),
          errorText: getServerError('paymentInfo.chapaBankCode'),
        ),
        value: _paymentInfo.chapaBankCode,
        items: ChapaBanks.values.map((bank) {
          return DropdownMenuItem<int>(
            value: bank.code,
            child: Text(bank.name),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              final selectedBank = ChapaBanks.values
                  .firstWhere((bank) => bank.code == value, orElse: () {
                return ChapaBanks.commercialBankOfEthiopia;
              });
              _paymentInfo = _paymentInfo.copyWith(
                chapaBankCode: selectedBank.code,
                chapaBankName: selectedBank.name,
              );
            });
            clearServerError('paymentInfo.chapaBankCode');
          }
        },
        validator: (value) => value == null ? 'Please select a bank' : null,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _bankAccountNoController,
        decoration: InputDecoration(
          labelText: 'Bank Account Number',
          hintText: 'Enter bank account number',
          border: const OutlineInputBorder(),
          prefixIcon:
              Icon(Icons.account_balance_wallet, color: colorScheme.primary),
          errorText: getServerError('paymentInfo.bankAccountNo'),
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (value) => validBankAccountNo(value),
        onChanged: (value) {
          _paymentInfo.bankAccountNo = value;
          clearServerError('paymentInfo.bankAccountNo');
        },
      ),
    ];
  }

  List<Widget> _buildSupportingDocumentsSection(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    String? documentsServerError = getServerError('documents');
    return <Widget>[
      Text(
        'You may attach up to $maxFileNo files under the size of $maxFileSizeMb MB each. '
        'Supported file types: ${allowedFileExtensions.map(
              (val) => val.toUpperCase(),
            ).join(
              ', ',
            )}',
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: colorScheme.onSurfaceVariant),
      ),
      const SizedBox(height: 8.0),
      OutlinedButton.icon(
        label: Text(
          'Attach Files',
          style: TextStyle(color: colorScheme.primary),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: colorScheme.primary), // Green border
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        ),
        onPressed: () async {
          await _pickDocuments();
          clearServerError('documents');
        },
      ),
      if (documentsServerError != null)
        Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 12.0),
          child: Text(
            documentsServerError,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 12,
            ),
          ),
        ),
      const SizedBox(height: 16.0),
      if (_supportingDocuments.isNotEmpty)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Selected Files:',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8.0),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: List.generate(_supportingDocuments.length, (index) {
                final file = _supportingDocuments[index];
                return Chip(
                  avatar: Icon(
                    getFileIconFromFileName(file.name),
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  label: Text(
                    file.name,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  deleteIcon: const Icon(Icons.cancel, size: 18),
                  deleteIconColor: Theme.of(context).colorScheme.onPrimary,
                  onDeleted: _isLoading ? null : () => _removeDocument(index),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            ),
          ],
        ),
    ];
  }

  //****** Helper methods
  void _showSuccessDialog(BuildContext context) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 30),
              SizedBox(width: 10),
              Text(
                'Success',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          content: const Text(
            'Your campaign application has been submitted successfully!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'OK',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.pop(context, true);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime.now().add(const Duration(days: 3)),
      lastDate: DateTime.now().add(const Duration(days: 3 * 365)),
    );

    if (mounted && picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _pickDocuments() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: allowedFileExtensions,
      withData: true,
    );

    if (!mounted) return;

    if (result != null) {
      List<PlatformFile> newlySelectedValidFiles = [];
      for (PlatformFile file in result.files) {
        if (file.size <= maxFileSizeMb * 1024 * 1024) {
          newlySelectedValidFiles.add(file);
        } else {
          showErrorSnackBar(
            context,
            'File ${file.name} exceeds the ${maxFileSizeMb}MB limit.',
          );
        }
      }

      if ((_supportingDocuments.length + newlySelectedValidFiles.length) >
          maxFileNo) {
        final numCanAdd = maxFileNo - _supportingDocuments.length;
        if (numCanAdd <= 0) {
          showErrorSnackBar(
            context,
            'You can upload a maximum of $maxFileNo documents.',
          );
          return;
        }
        newlySelectedValidFiles =
            newlySelectedValidFiles.take(numCanAdd).toList();
        showInfoSnackBar(
          context,
          'You can upload a maximum of $maxFileNo documents. Some files were not added.',
        );
      }

      if (mounted) {
        setState(() {
          _supportingDocuments.addAll(newlySelectedValidFiles);
        });
      }
    }
  }

  void _removeDocument(int index) {
    setState(() {
      _supportingDocuments.removeAt(index);
    });
  }

  Future<void> _submitCampaign(BuildContext context) async {
    setState(() {
      _isLoading = true;
      clearAllServerErrors();
    });

    if (!_formKey.currentState!.validate()) {
      setState(() => _isLoading = false);
      return;
    }

    _formKey.currentState!.save();

    if (_supportingDocuments.isEmpty) {
      showErrorSnackBar(
          context, 'Supporting documents are required for campaign creation.');
      setState(() => _isLoading = false);
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final accessToken = userProvider.credentials?.accessToken;

    if (accessToken == null) {
      showErrorSnackBar(context, 'Authentication error. Please log in again.');
      setState(() => _isLoading = false);
      return;
    }

    final campaignData = Campaign(
      ownerRecipientId: userProvider.user?.id ?? '',
      title: _title,
      description: _description,
      fundraisingGoal: _fundraisingGoal,
      category: _category,
      endDate: _endDate,
      paymentInfo: _paymentInfo,
    );

    final response = await Provider.of<CampaignService>(
      context,
      listen: false,
    ).createCampaign(
      campaignData,
      _supportingDocuments,
      accessToken,
    );

    if (!context.mounted) return;

    handleServiceResponse(
      context,
      response,
      onSuccess: () {
        if (mounted) {
          _showSuccessDialog(context);
        }
      },
      onValidationErrors: (errors) {
        setState(() {
          setServerErrors(errors);
        });
        // After setting errors, validate the form again to show them immediately. This causes the TextFormFields to re-evaluate their errorText.
        _formKey.currentState?.validate();
      },
    );

    if (context.mounted) setState(() => _isLoading = false);
  }
}
