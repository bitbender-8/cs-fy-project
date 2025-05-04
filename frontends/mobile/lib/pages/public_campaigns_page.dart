import 'package:flutter/material.dart';
import 'package:mobile/components/campaign_card.dart';

class PublicCampaignsPage extends StatelessWidget {
  const PublicCampaignsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData currentTheme = Theme.of(context);

    final List<Map<String, dynamic>> dummyCampaigns = [
      {
        'title': 'Campaign Title 1',
        'status': 'Live',
        'recipient': 'Abebe Kebede',
        'daysRemaining': 234,
        'goal': 1000,
        'progress': 0.54,
      },
      {
        'title': 'Campaign Title 2',
        'status': 'Live',
        'recipient': 'Abebe Kebede',
        'daysRemaining': 234,
        'goal': 1000,
        'progress': 0.54,
      },
      {
        'title': 'Campaign Title 3',
        'status': 'Live',
        'recipient': 'Abebe Kebede',
        'daysRemaining': 234,
        'goal': 1000,
        'progress': 0.54,
      },
      {
        'title': 'Campaign Title 1',
        'status': 'Live',
        'recipient': 'Abebe Kebede',
        'daysRemaining': 234,
        'goal': 1000,
        'progress': 0.54,
      },
      {
        'title': 'Campaign Title 1',
        'status': 'Live',
        'recipient': 'Abebe Kebede',
        'daysRemaining': 234,
        'goal': 1000,
        'progress': 0.54,
      },
      {
        'title': 'Campaign Title 1',
        'status': 'Live',
        'recipient': 'Abebe Kebede',
        'daysRemaining': 234,
        'goal': 1000,
        'progress': 0.54,
      },
      {
        'title': 'Campaign Title 1',
        'status': 'Live',
        'recipient': 'Abebe Kebede',
        'daysRemaining': 234,
        'goal': 1000,
        'progress': 0.54,
      },
      {
        'title': 'Campaign Title 1',
        'status': 'Live',
        'recipient': 'Abebe Kebede',
        'daysRemaining': 234,
        'goal': 1000,
        'progress': 0.54,
      },
      {
        'title': 'Campaign Title 1',
        'status': 'Live',
        'recipient': 'Abebe Kebede',
        'daysRemaining': 234,
        'goal': 1000,
        'progress': 0.54,
      },
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by title, recipient, etc.',
                    prefixIcon: Icon(Icons.search,
                        color: currentTheme.colorScheme.onSurfaceVariant),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: currentTheme.colorScheme.surfaceContainerHighest,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 12.0),
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Container(
                decoration: BoxDecoration(
                  color: currentTheme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.all(12.0),
                child: Icon(
                  Icons.tune,
                  color: currentTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: dummyCampaigns.length,
            itemBuilder: (context, index) {
              final campaign = dummyCampaigns[index];
              return CampaignCard(campaignData: campaign);
            },
          ),
        ),
      ],
    );
  }
}
