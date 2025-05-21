import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:mobile/components/custom_appbar.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/campaign.dart';
import 'package:mobile/models/payment_info.dart';
import 'package:mobile/utils/validators.dart';

class AddCampaignPage extends StatefulWidget {
  const AddCampaignPage({super.key});

  @override
  State<AddCampaignPage> createState() => _AddCampaignPageState();
}

class _AddCampaignPageState extends State<AddCampaignPage> {
  final _formKey = GlobalKey<FormState>();
  final _endDateController = TextEditingController();
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
            child: ListView(
              children: [
                const SizedBox(height: 8.0),
                Text('Campaign Information', style: titleStyle),
                const Divider(height: 24, thickness: 2.0),
                ..._buildCampaignInformationSection(context, colorScheme),
                const SizedBox(height: 20.0),
                Text('Payment Information', style: titleStyle),
                const Divider(height: 24, thickness: 2.0),
                ..._buildPaymentInfoSection(context, colorScheme),
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

  List<Widget> _buildCampaignInformationSection(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return <Widget>[
      TextFormField(
        decoration: InputDecoration(
          labelText: 'Campaign Title',
          hintText: 'Enter the campaign title',
          border: const OutlineInputBorder(),
          prefixIcon: Icon(Icons.title, color: colorScheme.primary),
        ),
        maxLength: 100,
        validator: (value) => validNonEmptyString(value, max: 100),
        onSaved: (value) => _title = value ?? '',
      ),
      const SizedBox(height: 10),
      TextFormField(
        decoration: InputDecoration(
          labelText: 'Campaign Description',
          hintText: 'Enter the campaign description',
          border: const OutlineInputBorder(),
          prefixIcon: Icon(Icons.description, color: colorScheme.primary),
        ),
        maxLines: 5,
        maxLength: 500,
        validator: (value) => validNonEmptyString(value, max: 500),
        onSaved: (value) => _description = value ?? '',
      ),
      const SizedBox(height: 10),
      TextFormField(
        decoration: InputDecoration(
          labelText: 'Fundraising Goal',
          hintText: 'Enter the fundraising goal',
          border: const OutlineInputBorder(),
          prefixIcon: Icon(Icons.attach_money, color: colorScheme.primary),
          suffixText: 'ETB',
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
        ],
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
        controller: _endDateController,
        decoration: InputDecoration(
          labelText: 'Campaign End Date',
          hintText: 'Enter the campaign end date',
          border: const OutlineInputBorder(),
          prefixIcon: Icon(Icons.calendar_today, color: colorScheme.primary),
        ),
        readOnly: true,
        onTap: () => _selectEndDate(context),
        validator: (value) => validDate(value, isPast: false),
        onSaved: (newValue) =>
            _endDate = DateTime.tryParse(newValue ?? '') ?? _endDate,
      ),
      const SizedBox(height: 16),
      DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Campaign Category',
          hintText: 'Select a category',
          border: const OutlineInputBorder(),
          prefixIcon: Icon(Icons.category, color: colorScheme.primary),
        ),
        value: _category,
        items: CampaignCategories.values.map((category) {
          return DropdownMenuItem<String>(
            value: category.value,
            child: Text(category.value),
          );
        }).toList(),
        onChanged: (value) => setState(() => _category = value!),
        validator: (value) {
          return validEnum(
            value,
            CampaignCategories.values.map((e) => e.value).toList(),
            'Campaign Category',
          );
        },
        onSaved: (value) => _category = value!,
      ),
      const SizedBox(height: 16),
      Text(
        'You may attach up to $maxFileNo files under the size of $maxFileSizeMb MB each. '
        'Supported file types: PDF, JPG, PNG.',
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: colorScheme.onSurfaceVariant),
      ),
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
        onPressed: _pickDocuments,
      ),
    ];
  }

  List<Widget> _buildPaymentInfoSection(
      BuildContext context, ColorScheme colorScheme) {
    return <Widget>[
      DropdownButtonFormField(
        decoration: InputDecoration(
          labelText: 'Bank Name',
          hintText: 'Select your bank',
          border: const OutlineInputBorder(),
          prefixIcon: Icon(Icons.account_balance, color: colorScheme.primary),
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
          }
        },
        validator: (value) => value == null ? 'Please select a bank' : null,
      ),
      const SizedBox(height: 16),
      TextFormField(
        decoration: InputDecoration(
          labelText: 'Bank Account Number',
          hintText: 'Enter bank account number',
          border: const OutlineInputBorder(),
          prefixIcon:
              Icon(Icons.account_balance_wallet, color: colorScheme.primary),
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (value) => validBankAccountNo(value),
        onSaved: (value) => _paymentInfo.bankAccountNo = value ?? '',
      ),
    ];
  }

  // Helper methods
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
        _endDateController.text = DateFormat('MMMM dd, yyyy').format(_endDate);
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
      // Validate selected files
      List<PlatformFile> validFiles = [];
      for (PlatformFile file in result.files) {
        if (file.size <= maxFileSizeMb * 1024 * 1024) {
          validFiles.add(file);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'File ${file.name} exceeds the $maxFileSizeMb MB limit.'),
              ),
            );
          }
        }
      }

      if ((_supportingDocuments.length + validFiles.length) > maxFileNo) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('You can upload a maximum of $maxFileNo documents.'),
            ),
          );
        }
        validFiles =
            validFiles.take(maxFileNo - _supportingDocuments.length).toList();
      }

      // Guard setState with mounted check
      if (mounted) {
        setState(() {
          _supportingDocuments.addAll(validFiles);
        });
      }
    }
  }
}
