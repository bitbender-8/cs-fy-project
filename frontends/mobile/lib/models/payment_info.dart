enum ChapaBanks {
  abayBank('Abay Bank', 130),
  addisInternationalBank('Addis International Bank', 772),
  ahaduBank('Ahadu Bank', 207),
  awashBank('Awash Bank', 656),
  bankOfAbyssinia('Bank of Abyssinia', 347),
  berhanBank('Berhan Bank', 571),
  commercialBankOfEthiopia('Commercial Bank of Ethiopia (CBE)', 946),
  dashenBank('Dashen Bank', 880),
  enatBank('Enat Bank', 1),
  globalBankEthiopia('Global Bank Ethiopia', 301),
  hibretBank('Hibret Bank', 534),
  lionInternationalBank('Lion International Bank', 315),
  nibInternationalBank('Nib International Bank', 979),
  wegagenBank('Wegagen Bank', 472);

  final String name;
  final int code;

  const ChapaBanks(this.name, this.code);

  static ChapaBanks? getByCode(int code) {
    for (ChapaBanks bank in ChapaBanks.values) {
      if (bank.code == code) {
        return bank;
      }
    }
    return null;
  }

  static ChapaBanks? getByName(String name) {
    for (ChapaBanks bank in ChapaBanks.values) {
      if (bank.name == name) {
        return bank;
      }
    }
    return null;
  }
}

class PaymentInfo {
  int chapaBankCode;
  String chapaBankName;
  String bankAccountNo;

  PaymentInfo({
    required this.chapaBankCode,
    required this.chapaBankName,
    required this.bankAccountNo,
  });
}
