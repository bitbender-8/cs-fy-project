import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/config.dart';
import 'package:mobile/services/file_service.dart';
import 'package:mobile/services/providers.dart';
import 'dart:math' as math;
import 'package:path/path.dart' as path;

import 'package:mobile/components/custom_appbar.dart';
import 'package:mobile/mock_data.dart';
import 'package:mobile/models/campaign.dart';
import 'package:mobile/models/campaign_request.dart';
import 'package:mobile/models/payment_info.dart';
import 'package:mobile/models/recipient.dart';
import 'package:mobile/models/server/errors.dart';
import 'package:mobile/pages/campaign_post_info_page.dart';
import 'package:mobile/utils/utils.dart';
import 'package:provider/provider.dart';

class CampaignInfoPage extends StatefulWidget {
  final Campaign campaign;
  final Recipient campaignOwner;
  final bool isPublic;

  const CampaignInfoPage({
    super.key,
    required this.campaign,
    required this.campaignOwner,
    this.isPublic = true,
  });

  @override
  State<CampaignInfoPage> createState() => _CampaignInfoPageState();
}

class _CampaignInfoPageState extends State<CampaignInfoPage> {
  final List<CampaignRequest> _campaignRequests = [];
  final List<CampaignPost> _campaignPosts = [];
  final Set<int> _loadingDocs = {};

  @override
  void initState() {
    super.initState();
    // REMOVE
    _campaignRequests.addAll(dummyCampaignRequests);
    _campaignPosts.addAll(dummyCampaigns.map(
      (camp) => CampaignPost(
          id: "",
          title: "Request: ${camp.title}",
          content: camp.description,
          campaignId: camp.id ?? '',
          publicPostDate: camp.endDate),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(pageTitle: "Campaign Information"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildCampaignHeaderSection(context),
            const SizedBox(height: 8),
            _buildDescriptionSection(context),
            const SizedBox(height: 8),
            if (!widget.isPublic) ...[
              _buildPaymentInfoSection(context, widget.campaign.paymentInfo),
              const SizedBox(height: 8),
            ],
            _buildCampaignUpdatesSection(context, _campaignPosts),
            const SizedBox(height: 8),
            if (!widget.isPublic) ...[
              _buildCampaignRequestsSection(context, _campaignRequests),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }

  //****** Page sections
  Widget _buildCampaignHeaderSection(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextStyle titleStyle = textTheme.headlineSmall!.copyWith(
      fontWeight: FontWeight.bold,
      color: colorScheme.onSurface,
    );
    final double progressValue =
        (double.tryParse(widget.campaign.totalDonated ?? '0') ?? 0) /
            (double.tryParse(widget.campaign.fundraisingGoal) ?? 0);

    return _buildCard(context, [
      Text(
        toTitleCase(widget.campaign.title),
        style: titleStyle,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
      const Divider(height: 20, thickness: 2),
      const SizedBox(height: 8),
      _buildInfoRow(
        context: context,
        label: 'Status:',
        value: "\n${widget.campaign.status?.value ?? 'N/A'}",
        icon: Icons.info_outline,
        secondLabel: 'Category:',
        secondValue: widget.campaign.category,
        secondIcon: Icons.category_outlined,
      ),
      _buildInfoRow(
        context: context,
        label: 'Recipient:',
        value: "\n${widget.campaign.campaignOwner?.fullName ?? 'N/A'}",
        icon: Icons.person_outline,
      ),
      _buildInfoRow(
        context: context,
        label: "Goal:",
        value:
            "${widget.campaign.totalDonated} of ${widget.campaign.fundraisingGoal} ETB",
        icon: Icons.attach_money_outlined,
        progressBarValue: progressValue,
      ),
      const Divider(height: 24),
      _buildInfoRow(
        context: context,
        label: 'Launch Date:',
        value: "\n${_formatDate(widget.campaign.launchDate)}",
        icon: Icons.rocket_launch,
        secondLabel: 'End Date:',
        secondValue: "\n${_formatDate(widget.campaign.endDate)}",
        secondIcon: Icons.flag_outlined,
      ),
      if (!widget.isPublic) ...[
        _buildInfoRow(
          context: context,
          label: 'Submission Date:',
          value: "\n${_formatDate(widget.campaign.submissionDate)}",
          icon: Icons.assignment_turned_in_outlined,
          secondLabel: 'Denial Date:',
          secondValue: "\n${_formatDate(widget.campaign.denialDate)}",
          secondIcon: Icons.block,
        ),
        _buildInfoRow(
          context: context,
          label: 'Verification Date:',
          value: _formatDate(widget.campaign.verificationDate),
          icon: Icons.verified_outlined,
        ),
      ],
      if (widget.campaign.documents.isNotEmpty) ...[
        const Divider(height: 24),
        _buildInfoRow(
          context: context,
          label: "Supporting Documents:",
          value: "",
          icon: Icons.description_outlined,
        ),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: widget.campaign.documents.map((doc) {
            final index = widget.campaign.documents.indexOf(doc) + 1;

            return ActionChip(
                label: _loadingDocs.contains(index)
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('Document $index'),
                labelPadding:
                    const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
                backgroundColor: colorScheme.secondaryContainer,
                onPressed: () async {
                  setState(() {
                    _loadingDocs.add(index);
                  });
                  await _openDocument(context, doc);
                  setState(() {
                    _loadingDocs.remove(index);
                  });
                });
          }).toList(),
        ),
      ],
    ]);
  }

  Widget _buildDescriptionSection(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextStyle titleStyle = textTheme.headlineSmall!.copyWith(
      fontWeight: FontWeight.bold,
      color: colorScheme.onSurface,
    );

    return _buildCard(context, [
      Row(
        children: [
          Icon(Icons.description_outlined, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            'Description',
            style: titleStyle,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          )
        ],
      ),
      const Divider(height: 20, thickness: 2),
      const SizedBox(height: 10),
      Text(
        widget.campaign.description,
        style: textTheme.bodyMedium!.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
    ]);
  }

  Widget _buildPaymentInfoSection(
    BuildContext context,
    PaymentInfo? paymentInfo,
  ) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextStyle titleStyle = textTheme.headlineSmall!.copyWith(
      fontWeight: FontWeight.bold,
      color: colorScheme.onSurface,
    );

    return _buildCard(context, [
      Row(
        children: [
          Icon(Icons.payments_outlined, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            'Payout Information',
            style: titleStyle,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          )
        ],
      ),
      const Divider(height: 20, thickness: 2),
      const SizedBox(height: 10),
      _buildInfoRow(
        context: context,
        label: 'Bank Name:',
        value: "\n${paymentInfo?.chapaBankName ?? 'N/A'}",
        icon: Icons.account_balance_outlined,
      ),
      _buildInfoRow(
        context: context,
        label: 'Bank Acccount Number:',
        value: "\n${paymentInfo?.bankAccountNo ?? 'N/A'}",
        icon: Icons.account_balance_wallet_outlined,
      )
    ]);
  }

  Widget _buildCampaignUpdatesSection(
    BuildContext context,
    List<CampaignPost> campaignPosts,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final titleStyle = textTheme.headlineSmall!.copyWith(
      fontWeight: FontWeight.bold,
      color: colorScheme.onSurface,
    );

    const maxVisibleItems = 6;
    const tileHeight = 64.0;
    const separatorHeight = 8.0;

    final visibleItems = math.min(campaignPosts.length, maxVisibleItems);
    final maxHeight =
        visibleItems * tileHeight + (visibleItems - 1) * separatorHeight;

    return _buildCard(context, [
      Row(
        children: [
          Icon(Icons.update, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            'Campaign Posts (Updates)',
            style: titleStyle,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
      const Divider(height: 20, thickness: 2),
      const SizedBox(height: 10),

      /// Constrain the list’s height so only 6 items are visible,
      /// then let the ListView scroll inside that box.
      ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Scrollbar(
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: campaignPosts.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: separatorHeight),
            itemBuilder: (context, index) {
              final post = campaignPosts[index];

              return Container(
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                  title: Text(
                    toTitleCase(post.title),
                    style: textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      post.content,
                      style: textTheme.bodySmall!.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _formatDate(post.publicPostDate),
                      style: textTheme.bodySmall!.copyWith(
                        color: colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => CampaignPostInfoPage(campaignPost: post),
                    ));
                  },
                ),
              );
            },
          ),
        ),
      ),
    ]);
  }

  Widget _buildCampaignRequestsSection(
    BuildContext context,
    List<CampaignRequest> campaignRequests,
  ) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextStyle titleStyle = textTheme.headlineSmall!.copyWith(
      fontWeight: FontWeight.bold,
      color: colorScheme.onSurface,
    );

    const maxVisibleItems = 6;
    const tileHeight = 64.0;
    const separatorHeight = 8.0;

    final visibleItems = math.min(_campaignPosts.length, maxVisibleItems);
    final maxHeight =
        visibleItems * tileHeight + (visibleItems - 1) * separatorHeight;

    return _buildCard(context, [
      Row(
        children: [
          Icon(Icons.question_answer_outlined, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            "Campaign Requests",
            style: titleStyle,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          )
        ],
      ),
      const Divider(height: 20, thickness: 2),
      const SizedBox(height: 10),

      /// Constrain the list’s height so only 6 items are visible,
      /// then let the ListView scroll inside that box.
      ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Scrollbar(
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: campaignRequests.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: separatorHeight),
            itemBuilder: (context, index) {
              final req = campaignRequests[index];

              return Container(
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                  title: RichText(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "${req.requestType.value}:",
                          style: textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.scrim),
                        ),
                        TextSpan(
                          text: " ${toTitleCase(req.title)}",
                          style: textTheme.titleMedium!.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      req.justification,
                      style: textTheme.bodySmall!.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _formatDate(req.requestDate),
                      style: textTheme.bodySmall!.copyWith(
                        color: colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ]);
  }

  //****** Sub-components
  Widget _buildCard(BuildContext context, List<Widget> children) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    String? secondLabel,
    String? secondValue,
    IconData? secondIcon,
    TextStyle? valueStyle,
    double? progressBarValue,
  }) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    valueStyle ??= textTheme.titleMedium!.copyWith(
      color: colorScheme.onSurfaceVariant,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 20, color: colorScheme.primary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$label ',
                        style: textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: value,
                        style: valueStyle,
                      ),
                    ],
                  ),
                ),
                if (progressBarValue != null) ...[
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: progressBarValue,
                    borderRadius: BorderRadius.circular(8),
                    backgroundColor: colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0x4D),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(colorScheme.primary),
                    minHeight: 10,
                  ),
                ],
              ],
            ),
          ),
          if (secondLabel != null &&
              secondValue != null &&
              secondIcon != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(secondIcon, size: 20, color: colorScheme.primary),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: RichText(
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$secondLabel ',
                      style: textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: secondValue,
                      style: valueStyle,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  //****** Helpers
  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  Future<void> _openDocument(
    BuildContext context,
    CampaignDocument document,
  ) async {
    final docUrl =
        widget.isPublic ? document.redactedDocumentUrl : document.documentUrl;

    if (docUrl == null) {
      showInfoSnackBar(context, "Document does not have a url");
      return;
    }

    final filename = path.basename(docUrl);
    if (filename.isEmpty) {
      showInfoSnackBar(context, "Document URL is invalid");
      return;
    }

    String processedUrl = widget.isPublic
        ? "$apiUrl/files/public/$filename"
        : "$apiUrl/files/campaign-documents/$filename";

    // If it contains the http prefix, handle as normal url.
    if (docUrl.startsWith('http')) {
      processedUrl = docUrl;
    }

    // If your app requires authorization for non-public files, get the token here
    final String? authToken = widget.isPublic
        ? null
        : Provider.of<UserProvider>(context, listen: false)
            .credentials!
            .accessToken;

    final result =
        await Provider.of<FileService>(context, listen: false).openFileFromUrl(
      fileUrl: processedUrl,
      accessToken: authToken,
    );

    if (!context.mounted) return;
    handleServiceResponse(context, result);
  }
}
