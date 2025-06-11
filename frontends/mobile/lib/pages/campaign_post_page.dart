import 'package:flutter/material.dart';
import 'package:mobile/components/custom_appbar.dart';
import 'package:mobile/models/campaign.dart';
import 'package:mobile/utils/utils.dart';

class CampaignPostPage extends StatelessWidget {
  final CampaignPost campaignPost;

  const CampaignPostPage({super.key, required this.campaignPost});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: const CustomAppBar(pageTitle: 'Campaign Post Details'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              toTitleCase(campaignPost.title),
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  "Public Post Date: ${formatDate(
                    campaignPost.publicPostDate,
                  )}",
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(color: colorScheme.outlineVariant, thickness: 1.2),
            const SizedBox(height: 10),
            Text(
              campaignPost.content,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
                height: 1.6,
              ),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}
