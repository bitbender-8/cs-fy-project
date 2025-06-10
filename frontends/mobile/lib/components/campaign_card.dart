// components/campaign_card.dart (Updated)
import 'package:flutter/material.dart';
import 'package:mobile/models/campaign.dart';
import 'package:mobile/models/recipient.dart';
import 'package:mobile/pages/campaign_detail_page.dart';

class CampaignCard extends StatefulWidget {
  final Campaign campaignData;
  final bool isPublic;

  const CampaignCard({
    super.key,
    required this.campaignData,
    required this.isPublic,
  });

  @override
  State<CampaignCard> createState() => _CampaignCardState();
}

class _CampaignCardState extends State<CampaignCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData currentTheme = Theme.of(context);
    final campaignProgress =
        (double.tryParse(widget.campaignData.totalDonated ?? '0') ?? 0) /
            (double.tryParse(widget.campaignData.fundraisingGoal) ?? 0);

    final Recipient? owner = widget.campaignData.campaignOwner;
    final String ownerFullName = owner?.fullName ?? 'Unknown Recipient';

    return InkWell(
      onTap: owner == null
          ? null
          : () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => CampaignDetailPage(
                  campaignId: widget.campaignData.id!,
                  isPublic: widget.isPublic,
                ),
              )),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        elevation: 2.0,
        color: currentTheme.colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.campaignData.title,
                    style: currentTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: currentTheme.colorScheme.onSurface,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: currentTheme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Text(
                      widget.campaignData.status?.value ?? 'Unknown',
                      style: currentTheme.textTheme.bodySmall?.copyWith(
                        color: currentTheme.colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              // Display recipient name directly
              Text(
                'Recipient: $ownerFullName',
                style: currentTheme.textTheme.bodyMedium?.copyWith(
                  color: currentTheme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                'Days remaining: ${widget.campaignData.timeRemaining?.inDays}',
                style: currentTheme.textTheme.bodyMedium?.copyWith(
                  color: currentTheme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Goal: ${widget.campaignData.fundraisingGoal} ETB',
                style: currentTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: currentTheme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: campaignProgress,
                      backgroundColor:
                          currentTheme.colorScheme.surfaceContainerHighest,
                      color: currentTheme.colorScheme.primary,
                      minHeight: 8.0,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    '${(campaignProgress * 100).toInt()}%',
                    style: currentTheme.textTheme.bodySmall?.copyWith(
                      color: currentTheme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
