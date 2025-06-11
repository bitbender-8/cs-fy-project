import 'package:chapasdk/chapasdk.dart';
import 'package:flutter/material.dart';
import 'package:mobile/components/custom_appbar.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/campaign.dart';
import 'package:mobile/models/server/errors.dart';
import 'package:mobile/services/payment_service.dart';
import 'package:mobile/services/providers.dart';
import 'package:mobile/utils/utils.dart';
import 'package:mobile/utils/validators.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class DonatePage extends StatefulWidget {
  final Campaign campaign;

  const DonatePage({super.key, required this.campaign});

  @override
  State<DonatePage> createState() => _DonatePageState();
}

class _DonatePageState extends State<DonatePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  late String _txnRef;

  // Optional fields
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _txnRef = "don-${widget.campaign.id}-${const Uuid().v4()}";
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
                validator: (value) => validMoneyAmount(
                  value,
                  AppConfig.maxMoneyAmount,
                ),
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

  //****** Helper functions
  Future<void> _processDonation() async {
    setState(() => _isLoading = true);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    _txnRef = "don-${widget.campaign.id}-${const Uuid().v4()}";

    try {
      Chapa.paymentParameters(
        context: context,
        publicKey: AppConfig.chapaPublicKey,
        currency: AppConfig.currency,
        amount: _amountController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        txRef: _txnRef, // Auto-genererated by chapa when using  native mode
        title: 'Donation',
        desc: 'Campaign - ${widget.campaign.id}',
        namedRouteFallBack: '',
        onPaymentFinished: (message, reference, amount) async {
          debugPrint(
            "[INFO]: (Payment) Message: $message, Reference: $reference, Amount: $amount",
          );

          if (message == "paymentSuccessful") {
            showInfoSnackBar(
              context,
              "Payment initiated sucessfully. Verifying...",
            );

            if (await _verifyPayment(_txnRef)) {
              if (!mounted) return;
              await showSuccessDialog(context, "Payment verified.");

              if (!mounted) return;
              Navigator.pop(context);
              Navigator.pop(context);
            }
          } else {
            showErrorSnackBar(context, 'Payment failed or cancelled.');
            debugPrint("[ERROR]: Payment failed or cancelled: $message");
          }
        },
      );
    } catch (e) {
      debugPrint("[REQUEST_ERROR]: $e");
      showErrorSnackBar(context, 'An unexpected error occurred');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _verifyPayment(String txnRef) async {
    setState(() => _isLoading = true);

    if (!_formKey.currentState!.validate()) {
      setState(() => _isLoading = false);
      return false;
    }
    _formKey.currentState!.save();

    final result = await Provider.of<PaymentService>(context, listen: false)
        .verifyDonation(
      widget.campaign.id!,
      txnRef,
    );

    if (!mounted) return false;
    bool paymentVerified = await handleServiceResponse(context, result);

    setState(() => _isLoading = false);
    return paymentVerified;
  }
}
