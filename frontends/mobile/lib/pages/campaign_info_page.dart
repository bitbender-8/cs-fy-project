import 'package:flutter/material.dart';
import 'package:mobile/components/custom_appbar.dart';
import 'package:mobile/mock_data.dart';
import 'package:mobile/models/campaign.dart';
import 'package:mobile/models/campaign_request.dart';
import 'package:intl/intl.dart';
import 'package:mobile/models/payment_info.dart';

class CampaignInfoPage extends StatelessWidget {
  final Campaign campaign;
  final List<CampaignRequest> campaignRequests;
  final bool isPublic;

  CampaignInfoPage({
    super.key,
    required this.campaign,
    List<CampaignRequest>? campaignRequests,
    this.isPublic = true,
  }) : campaignRequests = campaignRequests ?? dummyCampaignRequests;

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd MMM yy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final documents = campaign.documents ?? [];
    final campaignPosts = campaign.campaignPosts ?? [];

    final double progressValue = 0.54;
    final String currentAmount = 'XXXX';

    return Scaffold(
      appBar: const CustomAppBar(pageTitle: "Campaign Information"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCampaignHeaderSection(
              context,
              colorScheme,
              textTheme,
              currentAmount,
              progressValue,
            ),
            const SizedBox(height: 16),
            _buildDescriptionSection(colorScheme, textTheme),
            const SizedBox(height: 16),
            if (documents.isNotEmpty) ...[
              _buildDocumentsSection(colorScheme, textTheme, documents),
              const SizedBox(height: 16),
            ],
            if (!isPublic && campaign.paymentInfo != null) ...[
              _buildPaymentInfoSection(
                  colorScheme, textTheme, campaign.paymentInfo!),
              const SizedBox(height: 16),
            ],
            if (isPublic) ...[
              // Conditional rendering based on isPublic
              _buildCampaignUpdatesSection(
                  colorScheme, textTheme, campaignPosts),
              const SizedBox(height: 16),
            ],
            if (!isPublic && campaignRequests.isNotEmpty) ...[
              // Conditional rendering based on isPublic and requests existence
              _buildCampaignRequestsSection(
                  colorScheme, textTheme, campaignRequests),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCampaignHeaderSection(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    String currentAmount,
    double progressValue,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    campaign.title,
                    style: textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    print(
                        'Donate button pressed for campaign: ${campaign.title}');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('Donate'),
                ),
              ],
            ),
            const Divider(height: 16),
            const SizedBox(height: 16),
            _buildInfoRow(
              label: 'Status:',
              value: campaign.status?.value ?? 'N/A',
              icon: Icons.info_outline,
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
            _buildInfoRow(
              label: 'Recipient:',
              value: campaign.ownerRecipientId,
              icon: Icons.person_outline,
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
            _buildInfoRow(
              label: 'Category:',
              value: campaign.category,
              icon: Icons.category_outlined,
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              label: 'Goal:',
              value: '$currentAmount ETB / ${campaign.fundraisingGoal} ETB',
              icon: Icons.attach_money,
              colorScheme: colorScheme,
              textTheme: textTheme,
              valueStyle: textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progressValue,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 12),
            _buildDateRow(
              label1: 'Launch:',
              value1: _formatDate(campaign.launchDate),
              label2: 'End:',
              value2: _formatDate(campaign.endDate),
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
            if (!isPublic) ...[
              const SizedBox(height: 8),
              _buildDateRow(
                label1: 'Submission:',
                value1: _formatDate(campaign.submissionDate),
                label2: 'Verification:',
                value2: _formatDate(campaign.verificationDate),
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
              if (campaign.denialDate != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  label: 'Denial:',
                  value: _formatDate(campaign.denialDate),
                  icon: Icons.cancel_outlined,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                  valueStyle: textTheme.bodyMedium!.copyWith(
                    color: colorScheme.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(
      ColorScheme colorScheme, TextTheme textTheme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.description_outlined, color: colorScheme.onSurface),
                const SizedBox(width: 8),
                Text(
                  'Description',
                  style: textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              campaign.description,
              style: textTheme.bodyMedium!
                  .copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsSection(
      ColorScheme colorScheme, TextTheme textTheme, List<dynamic> documents) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.folder_outlined, color: colorScheme.onSurface),
                const SizedBox(width: 8),
                Text(
                  'Documents',
                  style: textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: documents.map((doc) {
                final index = documents.indexOf(doc) + 1;
                return ActionChip(
                  avatar: Icon(Icons.description_outlined,
                      color: colorScheme.primary),
                  label: Text('Document $index'),
                  onPressed: () {
                    if (doc.documentUrl != null) {
                      print('Viewing document: ${doc.documentUrl}');
                    } else {
                      print('Document URL is null for document $index');
                    }
                  },
                  labelStyle: textTheme.bodyMedium!
                      .copyWith(color: colorScheme.primary),
                  backgroundColor:
                      colorScheme.primaryContainer.withValues(alpha: 0.5),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfoSection(
      ColorScheme colorScheme, TextTheme textTheme, PaymentInfo paymentInfo) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payments_outlined, color: colorScheme.onSurface),
                const SizedBox(width: 8),
                Text(
                  'Payout Information',
                  style: textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              label: 'Chapa Bank Name:',
              value: paymentInfo.chapaBankName,
              icon: Icons.account_balance_outlined,
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
            _buildInfoRow(
              label: 'Bank Account No:',
              value: paymentInfo.bankAccountNo,
              icon: Icons.account_balance_wallet_outlined,
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampaignUpdatesSection(ColorScheme colorScheme,
      TextTheme textTheme, List<dynamic> campaignPosts) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.update_outlined, color: colorScheme.onSurface),
                const SizedBox(width: 8),
                Text(
                  'Campaign Updates',
                  style: textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (campaignPosts.isEmpty)
              Text(
                'No campaign updates available.',
                style: textTheme.bodyMedium!.copyWith(
                  fontStyle: FontStyle.italic,
                  color: colorScheme.onSurfaceVariant,
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: campaignPosts.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final post = campaignPosts[index];
                  return Card(
                    elevation: 0,
                    color: colorScheme.surfaceContainerHigh,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      title: Text(
                        post.title ?? 'No Title',
                        style: textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        _formatDate(post.publicPostDate),
                        style: textTheme.bodySmall!.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      onTap: () {
                        print('Tapped on update: ${post.title}');
                      },
                      dense: true,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampaignRequestsSection(ColorScheme colorScheme,
      TextTheme textTheme, List<CampaignRequest> campaignRequests) {
    if (campaignRequests.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.request_page_outlined, color: colorScheme.onSurface),
                const SizedBox(width: 8),
                Text(
                  'Campaign Requests',
                  style: textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: campaignRequests.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final req = campaignRequests[index];
                return Card(
                  elevation: 0,
                  color: colorScheme.surfaceContainerHigh,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    title: Text(
                      req.title,
                      style: textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      _formatDate(req.requestDate),
                      style: textTheme.bodySmall!.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    onTap: () {
                      print('Tapped on request: ${req.title}');
                    },
                    dense: true,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required IconData icon,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    TextStyle? valueStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: textTheme.bodyMedium!
                    .copyWith(color: colorScheme.onSurface),
                children: [
                  TextSpan(
                    text: '$label ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: value,
                    style: valueStyle ??
                        textTheme.bodyMedium!.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRow({
    required String label1,
    required String value1,
    required String label2,
    required String value2,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 18,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 1,
                  child: RichText(
                    text: TextSpan(
                      style: textTheme.bodyMedium!
                          .copyWith(color: colorScheme.onSurface),
                      children: [
                        TextSpan(
                          text: '$label1 ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: value1,
                          style: textTheme.bodyMedium!.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: RichText(
                    text: TextSpan(
                      style: textTheme.bodyMedium!
                          .copyWith(color: colorScheme.onSurface),
                      children: [
                        TextSpan(
                          text: '$label2 ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: value2,
                          style: textTheme.bodyMedium!.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
