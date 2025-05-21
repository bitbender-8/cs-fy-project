// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_info.dart';

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
