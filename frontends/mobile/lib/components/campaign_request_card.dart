import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile/models/campaign_request.dart';
import 'package:mobile/pages/campaign_request_detail_page.dart';
import 'package:mobile/utils/utils.dart';

class CampaignRequestCard extends StatelessWidget {
  final CampaignRequest campaignRequest;
  final AsyncCallback? afterPop;

  const CampaignRequestCard({
    super.key,
    required this.campaignRequest,
    this.afterPop,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () async {
        if (campaignRequest.id != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CampaignRequestDetailPage(
                campaignRequestId: campaignRequest.id!,
              ),
            ),
          );
          final postPopAction = afterPop;
          if (postPopAction != null) await postPopAction();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: Request ID is missing.')),
          );
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: theme.colorScheme.surfaceContainerHigh,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      toTitleCase(campaignRequest.title),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ResolutionType.getBackgroundColor(
                        campaignRequest.resolutionType,
                        theme.colorScheme,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      campaignRequest.resolutionType?.value ?? 'Pending',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: ResolutionType.getTextColor(
                          campaignRequest.resolutionType,
                          theme.colorScheme,
                        ),
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: CampaignRequestType.getBackgroundColor(
                        campaignRequest.requestType,
                        theme.colorScheme,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "Type: ${campaignRequest.requestType.value}",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: CampaignRequestType.getTextColor(
                          campaignRequest.requestType,
                          theme.colorScheme,
                        ),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      "Date: ${formatDate(campaignRequest.requestDate)}",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
