import 'package:flutter/material.dart';
import 'package:mobile/home.dart';
import 'package:mobile/services/campaign_service.dart';
import 'package:mobile/services/providers.dart';
import 'package:mobile/services/recipient_service.dart';
import 'package:provider/provider.dart';

void main() => runApp(
      MultiProvider(
        providers: [
          Provider<RecipientService>(
            create: (_) => RecipientService(),
          ),
          Provider<CampaignService>(
            create: (_) => CampaignService(),
          ),
          ChangeNotifierProvider<UserProvider>(
            create: (_) => UserProvider(),
          ),
        ],
        child: const TesfaFundApp(),
      ),
    );

class TesfaFundApp extends StatelessWidget {
  const TesfaFundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TesfaFund',
      debugShowCheckedModeBanner: false,
      home: const SafeArea(child: Home()),
      theme: ThemeData.light(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green.shade700),
      ),
    );
  }
}
