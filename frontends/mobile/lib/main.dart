import 'package:flutter/material.dart';
import 'package:mobile/home.dart';
import 'package:mobile/services/campaign_service.dart';
import 'package:mobile/services/file_service.dart';
import 'package:mobile/services/notification_service.dart';
import 'package:mobile/services/providers.dart';
import 'package:mobile/services/recipient_service.dart';
import 'package:provider/provider.dart';

void main() => runApp(
      MultiProvider(
        providers: [
          // Providers
          Provider<RecipientService>(create: (_) => RecipientService()),
          Provider<CampaignService>(create: (_) => CampaignService()),
          Provider<FileService>(create: (_) => FileService()),
          Provider<NotificationService>(create: (_) => NotificationService()),

          // ChangeNotifierProviders
          ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),

          // Add the NotificationProvider using ChangeNotifierProxyProvider
          // It needs access to NotificationService and UserProvider
          ChangeNotifierProxyProvider<NotificationService,
              NotificationProvider>(
            create: (context) => NotificationProvider(
              context.read<NotificationService>(),
              context.read<UserProvider>(),
            ),
            // The `update` function is called when a dependency changes.
            update: (
              context,
              notificationService,
              notificationProvider,
            ) =>
                notificationProvider!,
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
