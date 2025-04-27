import 'package:flutter/material.dart';
import 'package:mobile/home.dart';

void main() => runApp(const TesfaFundApp());

class TesfaFundApp extends StatelessWidget {
  const TesfaFundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TesfaFund',
      debugShowCheckedModeBanner: false,
      home: const SafeArea(child: Home()),
      theme: ThemeData.light(useMaterial3: true),
    );
  }
}
