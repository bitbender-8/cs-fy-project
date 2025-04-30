class PaymentInfo {
  String paymentMethod;
  String phoneNo;
  String? bankAccountNo;
  String? bankName;

  PaymentInfo({
    required this.paymentMethod,
    required this.phoneNo,
    this.bankAccountNo,
    this.bankName,
  });
}
