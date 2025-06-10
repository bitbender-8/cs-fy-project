// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_info.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PaymentInfoCWProxy {
  PaymentInfo chapaBankCode(int chapaBankCode);

  PaymentInfo chapaBankName(String chapaBankName);

  PaymentInfo bankAccountNo(String bankAccountNo);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PaymentInfo(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PaymentInfo(...).copyWith(id: 12, name: "My name")
  /// ````
  PaymentInfo call({
    int chapaBankCode,
    String chapaBankName,
    String bankAccountNo,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPaymentInfo.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPaymentInfo.copyWith.fieldName(...)`
class _$PaymentInfoCWProxyImpl implements _$PaymentInfoCWProxy {
  const _$PaymentInfoCWProxyImpl(this._value);

  final PaymentInfo _value;

  @override
  PaymentInfo chapaBankCode(int chapaBankCode) =>
      this(chapaBankCode: chapaBankCode);

  @override
  PaymentInfo chapaBankName(String chapaBankName) =>
      this(chapaBankName: chapaBankName);

  @override
  PaymentInfo bankAccountNo(String bankAccountNo) =>
      this(bankAccountNo: bankAccountNo);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PaymentInfo(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PaymentInfo(...).copyWith(id: 12, name: "My name")
  /// ````
  PaymentInfo call({
    Object? chapaBankCode = const $CopyWithPlaceholder(),
    Object? chapaBankName = const $CopyWithPlaceholder(),
    Object? bankAccountNo = const $CopyWithPlaceholder(),
  }) {
    return PaymentInfo(
      chapaBankCode: chapaBankCode == const $CopyWithPlaceholder()
          ? _value.chapaBankCode
          // ignore: cast_nullable_to_non_nullable
          : chapaBankCode as int,
      chapaBankName: chapaBankName == const $CopyWithPlaceholder()
          ? _value.chapaBankName
          // ignore: cast_nullable_to_non_nullable
          : chapaBankName as String,
      bankAccountNo: bankAccountNo == const $CopyWithPlaceholder()
          ? _value.bankAccountNo
          // ignore: cast_nullable_to_non_nullable
          : bankAccountNo as String,
    );
  }
}

extension $PaymentInfoCopyWith on PaymentInfo {
  /// Returns a callable class that can be used as follows: `instanceOfPaymentInfo.copyWith(...)` or like so:`instanceOfPaymentInfo.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PaymentInfoCWProxy get copyWith => _$PaymentInfoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentInfo _$PaymentInfoFromJson(Map<String, dynamic> json) => PaymentInfo(
      chapaBankCode: (json['chapaBankCode'] as num).toInt(),
      chapaBankName: json['chapaBankName'] as String,
      bankAccountNo: json['bankAccountNo'] as String,
    );

Map<String, dynamic> _$PaymentInfoToJson(PaymentInfo instance) =>
    <String, dynamic>{
      'chapaBankCode': instance.chapaBankCode,
      'chapaBankName': instance.chapaBankName,
      'bankAccountNo': instance.bankAccountNo,
    };
