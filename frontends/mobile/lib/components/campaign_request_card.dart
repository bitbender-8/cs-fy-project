import 'package:flutter/material.dart';
import 'package:mobile/models/campaign_request.dart';
import 'package:mobile/pages/campaign_request_detail_page.dart';

class CampaignRequestCard extends StatelessWidget {
  final CampaignRequest campaignRequest;

  const CampaignRequestCard({super.key, required this.campaignRequest});

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return "${date.day}/${date.month}/${date.year % 100}";
  }

  Color _getResolutionStatusColor(
      ResolutionType? resolutionType, ThemeData theme) {
    if (resolutionType == null) {
      return Colors.orange;
    }
    switch (resolutionType) {
      case ResolutionType.accepted:
        return Colors.green;
      case ResolutionType.rejected:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData currentTheme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        print("Defecate request $campaignRequest");
        if (campaignRequest.id != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CampaignRequestDetailPage(requestId: campaignRequest.id!),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: Request ID is missing.')),
          );
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        color: currentTheme.colorScheme.surfaceContainerLow,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      campaignRequest.title,
                      style: currentTheme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    'Status: ${campaignRequest.resolutionType?.value ?? "Unknown"}',
                    style: currentTheme.textTheme.bodySmall?.copyWith(
                      color: _getResolutionStatusColor(
                          campaignRequest.resolutionType, currentTheme),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Text(
                'Type: ${campaignRequest.requestType.value}',
                style: currentTheme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 4.0),
              Text(
                'Date: ${_formatDate(campaignRequest.requestDate)}',
                style: currentTheme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
