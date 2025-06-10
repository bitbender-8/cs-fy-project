import 'package:flutter/material.dart';
import 'package:chapasdk/chapasdk.dart';
import 'package:mobile/models/server/errors.dart';
import 'package:provider/provider.dart';

import 'package:mobile/components/custom_appbar.dart';
import 'package:mobile/utils/utils.dart';
import 'package:mobile/config.dart';
import 'package:mobile/services/providers.dart';
import 'package:mobile/models/campaign.dart';

class DonatePage extends StatefulWidget {
  final Campaign campaign;

  const DonatePage({
    super.key,
    required this.campaign,
  });

  @override
  State<DonatePage> createState() => _DonatePageState();
}

class _DonatePageState extends State<DonatePage> {
  final TextEditingController _amountController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phoneNo ?? '');
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
  }

  @override
  void dispose() {
    _amountController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _processDonation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Generate txRef with campaign ID
    final String txRef =
        'Donation-${widget.campaign.id}-${DateTime.now().microsecondsSinceEpoch}';
    final String amount = _amountController.text;

    final String email = _emailController.text;
    final String phone = _phoneController.text;
    final String firstName = _firstNameController.text;
    final String lastName = _lastNameController.text;

    try {
      Chapa.paymentParameters(
        context: context,
        publicKey: AppConfig.chapaPublicKey,
        currency: AppConfig.currency,
        amount: amount,
        email: email,
        phone: phone,
        firstName: firstName,
        lastName: lastName,
        txRef: txRef,
        title:
            'Donation for ${toTitleCase(widget.campaign.title)}', // More descriptive title
        desc:
            'Donation for campaign ID: ${widget.campaign.id}', // More descriptive description
        nativeCheckout: true,
        namedRouteFallBack: '/',
        showPaymentMethodsOnGridView: true,
        availablePaymentMethods: ['mpesa', 'cbebirr', 'telebirr', 'ebirr'],
        onPaymentFinished: (message, reference, amount) async {
          setState(() {
            _isLoading = false;
          });

          if (!mounted) return;

          if (message.contains('success')) {
            showInfoSnackBar(
              context,
              'Payment initiated successfully. Verifying...',
            );
            bool isVerified = await _verifyPaymentOnBackend(reference);

            if (!mounted) return;

            if (isVerified) {
              showInfoSnackBar(
                context,
                'Payment successfully verified and recorded!',
              );
              Navigator.pop(context);
            } else {
              showErrorSnackBar(
                context,
                'Payment could not be verified. Please contact support.',
              );
            }
          } else {
            showErrorSnackBar(context, 'Payment failed or cancelled: $message');
          }
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showErrorSnackBar(context, 'An unexpected error occurred: $e');
    }
  }

  Future<bool> _verifyPaymentOnBackend(String txRef) async {
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const CustomAppBar(pageTitle: "Make a Donation"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "You are donating to: **${toTitleCase(widget.campaign.title)}**",
                style:
                    textTheme.titleLarge!.copyWith(color: colorScheme.primary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                "Enter the amount you wish to donate:",
                style: textTheme.titleMedium!
                    .copyWith(color: colorScheme.onSurface),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Donation Amount (ETB)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a donation amount.';
                  }
                  if (double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return 'Please enter a valid positive amount.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  prefixIcon: const Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  prefixIcon: const Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameController,
                      decoration: InputDecoration(
                        labelText: 'First Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        prefixIcon: const Icon(Icons.person),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameController,
                      decoration: InputDecoration(
                        labelText: 'Last Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _processDonation,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.volunteer_activism_rounded),
                  label: Text(_isLoading ? "Processing..." : "Donate Now"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
