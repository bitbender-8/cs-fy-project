import 'package:flutter/material.dart';
import 'package:mobile/models/server/filters.dart';
import 'package:mobile/pages/campaign_request_detail_page.dart';
import 'package:mobile/pages/donate_page.dart';
import 'package:mobile/services/campaign_post_service.dart';
import 'package:mobile/services/campaign_request_service.dart';
import 'package:mobile/services/campaign_service.dart';
import 'package:mobile/services/recipient_service.dart';
import 'dart:math' as math;
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';

import 'package:mobile/components/custom_appbar.dart';
import 'package:mobile/config.dart';
import 'package:mobile/services/file_service.dart';
import 'package:mobile/services/providers.dart';
import 'package:mobile/models/campaign.dart';
import 'package:mobile/models/campaign_request.dart';
import 'package:mobile/models/payment_info.dart';
import 'package:mobile/models/server/errors.dart';
import 'package:mobile/pages/campaign_post_page.dart';
import 'package:mobile/utils/utils.dart';

class CampaignDetailPage extends StatefulWidget {
  final String campaignId;
  final bool isPublic;

  const CampaignDetailPage({
    super.key,
    required this.campaignId,
    this.isPublic = true,
  });

  @override
  State<CampaignDetailPage> createState() => _CampaignDetailPageState();
}

class _CampaignDetailPageState extends State<CampaignDetailPage> {
  Campaign? _campaign;
  final List<CampaignRequest> _campaignRequests = [];
  final List<CampaignPost> _campaignPosts = [];
  final Set<int> _loadingDocs = {};
  bool _isLoadingPage = false;
  bool _isLoadingLists = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(pageTitle: "Campaign Information"),
      body: _isLoadingPage
          ? const Center(child: CircularProgressIndicator())
          : _campaign == null
              ? const Center(
                  child: Text(
                    "Could not fetch campaign details.\nCheck your internet connection.",
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildCampaignHeaderSection(context),
                      const SizedBox(height: 8),
                      _buildDescriptionSection(context),
                      const SizedBox(height: 8),
                      if (!widget.isPublic) ...[
                        _buildPaymentInfoSection(
                            context, _campaign?.paymentInfo),
                        const SizedBox(height: 8),
                      ],
                      _buildCampaignPostsSection(context),
                      const SizedBox(height: 8),
                      if (!widget.isPublic) ...[
                        _buildCampaignRequestsSection(
                            context, _campaignRequests),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
      floatingActionButton:
          widget.isPublic && !_isLoadingPage && _campaign != null
              ? FloatingActionButton.extended(
                  onPressed: _onDonatePressed,
                  icon: const Icon(Icons.volunteer_activism_rounded),
                  label: const Text("Donate"),
                )
              : null,
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
        (double.tryParse(_campaign?.totalDonated ?? '0') ?? 0) /
            (double.tryParse(_campaign?.fundraisingGoal ?? '0') ?? 0);

    return _buildCard(context, [
      Text(
        toTitleCase(_campaign?.title ?? 'Unknown'),
        style: titleStyle,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
      const Divider(height: 20, thickness: 2),
      const SizedBox(height: 8),
      _buildInfoRow(
        context: context,
        label: 'Status:',
        value: "\n${_campaign?.status?.value ?? "Unknown"}",
        icon: Icons.info_outline,
        secondLabel: 'Category:',
        secondValue: _campaign?.category ?? "Unknown",
        secondIcon: Icons.category_outlined,
      ),
      _buildInfoRow(
        context: context,
        label: 'Recipient:',
        value: "\n${_campaign?.campaignOwner?.fullName ?? 'N/A'}",
        icon: Icons.person_outline,
      ),
      _buildInfoRow(
        context: context,
        label: "Goal:",
        value:
            "${_campaign?.totalDonated} of ${_campaign?.fundraisingGoal} ETB",
        icon: Icons.attach_money_outlined,
        progressBarValue: progressValue,
      ),
      const Divider(height: 24),
      _buildInfoRow(
        context: context,
        label: 'Launch Date:',
        value: "\n${formatDate(_campaign?.launchDate, isShort: false)}",
        icon: Icons.rocket_launch,
        secondLabel: 'End Date:',
        secondValue: "\n${formatDate(_campaign?.endDate, isShort: false)}",
        secondIcon: Icons.flag_outlined,
      ),
      if (!widget.isPublic) ...[
        _buildInfoRow(
          context: context,
          label: 'Submission Date:',
          value: "\n${formatDate(_campaign?.submissionDate, isShort: false)}",
          icon: Icons.assignment_turned_in_outlined,
          secondLabel: 'Denial Date:',
          secondValue: "\n${formatDate(_campaign?.denialDate, isShort: false)}",
          secondIcon: Icons.block,
        ),
        _buildInfoRow(
          context: context,
          label: 'Verification Date:',
          value: formatDate(_campaign?.verificationDate, isShort: false),
          icon: Icons.verified_outlined,
        ),
      ],
      if (_campaign?.documents != null && _campaign!.documents.isNotEmpty) ...[
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
          children: _campaign!.documents.map((doc) {
            final index = _campaign!.documents.indexOf(doc) + 1;

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
        _campaign?.description ?? "Unknown",
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

  Widget _buildCampaignPostsSection(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return _buildScrollableCardSection(
      context: context,
      title: 'Campaign Posts (Updates)',
      emptyMessage: 'No campaign posts available.',
      icon: Icons.update,
      items: _campaignPosts,
      itemBuilder: (BuildContext context, CampaignPost post) {
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                formatDate(post.publicPostDate, isShort: false),
                style: textTheme.bodySmall!.copyWith(
                  color: colorScheme.onTertiaryContainer,
                ),
              ),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CampaignPostPage(campaignPost: post),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCampaignRequestsSection(
    BuildContext context,
    List<CampaignRequest> campaignRequests,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return _buildScrollableCardSection(
      context: context,
      title: 'Campaign Requests',
      emptyMessage: 'No campaign requests available.',
      icon: Icons.question_answer_outlined,
      items: campaignRequests,
      itemBuilder: (BuildContext context, CampaignRequest req) {
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
                      color: colorScheme.scrim,
                    ),
                  ),
                  TextSpan(
                    text: " ${toTitleCase(req.title)}",
                    style: textTheme.titleMedium!
                        .copyWith(color: colorScheme.onSurface),
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                formatDate(req.requestDate, isShort: false),
                style: textTheme.bodySmall!.copyWith(
                  color: colorScheme.onTertiaryContainer,
                ),
              ),
            ),
            onTap: () {
              if (req.id == null) return;

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CampaignRequestDetailPage(
                    campaignRequestId: req.id!,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
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

  Widget _buildScrollableCardSection<T>({
    required BuildContext context,
    required String title,
    required String emptyMessage,
    required IconData icon,
    required List<T> items,
    required Widget Function(BuildContext, T) itemBuilder,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final titleStyle = textTheme.headlineSmall!.copyWith(
      fontWeight: FontWeight.bold,
      color: colorScheme.onSurface,
    );

    const maxVisibleItems = 6;
    const tileHeight = 110.0;
    const separatorHeight = 8.0;

    final visibleItems = math.min(items.length, maxVisibleItems);
    final maxHeight = visibleItems > 0
        ? (visibleItems * tileHeight) + ((visibleItems - 1) * separatorHeight)
        : 0.0;

    final children = [
      Row(
        children: [
          Icon(icon, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: titleStyle,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
      const Divider(height: 20, thickness: 2),
      const SizedBox(height: 10),
    ];

    if (_isLoadingLists) {
      children.add(const Center(child: CircularProgressIndicator()));
    } else if (items.isEmpty) {
      children.add(
        Text(
          emptyMessage,
          style: textTheme.bodyMedium!
              .copyWith(color: colorScheme.onSurfaceVariant),
        ),
      );
    } else {
      children.addAll([
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Scrollbar(
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: separatorHeight),
              itemBuilder: (context, index) =>
                  itemBuilder(context, items[index]),
            ),
          ),
        ),
        const Divider(height: 10),
      ]);
    }

    return _buildCard(context, children);
  }

  //****** Helper functions
  void _onDonatePressed() {
    if (_isLoadingPage || _campaign == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DonatePage(campaign: _campaign!),
      ),
    );
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
        ? "${AppConfig.apiUrl}/files/public/$filename"
        : "${AppConfig.apiUrl}/files/campaign-documents/$filename";

    // If it contains the http prefix, handle as normal url.
    if (docUrl.startsWith('http')) {
      processedUrl = docUrl;
    }

    final String? authToken = Provider.of<UserProvider>(
      context,
      listen: false,
    ).credentials?.accessToken;

    final result = await Provider.of<FileService>(
      context,
      listen: false,
    ).openFileFromUrl(
      fileUrl: processedUrl,
      accessToken: authToken,
    );

    if (!context.mounted) return;
    handleServiceResponse(context, result);
  }

  Future<void> _fetchData() async {
    // This campaign fetching needs to happen before owner fetching
    if (await _fetchCampaign()) await _fetchCampaignOwner();
    _fetchCampaignPosts();
    if (!widget.isPublic) _fetchCampaignRequests();
  }

  Future<bool> _fetchCampaign() async {
    setState(() => _isLoadingPage = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final accessToken = userProvider.credentials?.accessToken;

    if (!mounted) return false;
    final result = await Provider.of<CampaignService>(
      context,
      listen: false,
    ).getCampaignById(
      widget.campaignId,
      accessToken,
    );

    if (!mounted) return false;
    await handleServiceResponse(context, result, onSuccess: () {
      if (result.data == null) return;
      setState(() => _campaign = result.data);
    });

    setState(() => _isLoadingPage = false);
    return true;
  }

  Future<void> _fetchCampaignOwner() async {
    setState(() => _isLoadingPage = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final accessToken = userProvider.credentials?.accessToken;

    if (!mounted) return;
    final result = await Provider.of<RecipientService>(
      context,
      listen: false,
    ).getRecipientById(
      _campaign!.ownerRecipientId,
      accessToken,
    );

    if (!mounted) return;
    await handleServiceResponse(context, result, onSuccess: () {
      if (result.data == null) return;
      setState(() => _campaign!.campaignOwner = result.data);
    });

    setState(() => _isLoadingPage = false);
  }

  Future<void> _fetchCampaignPosts() async {
    setState(() {
      _isLoadingLists = true;
      _campaignPosts.clear();
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final accessToken = userProvider.credentials?.accessToken;

    if (!mounted) return;
    final result = await Provider.of<CampaignPostService>(
      context,
      listen: false,
    ).getCampaignPosts(
      CampaignPostFilter(campaignId: widget.campaignId),
      accessToken,
    );

    if (!mounted) return;
    await handleServiceResponse(context, result, onSuccess: () {
      if (result.data == null) return;
      setState(
        () => _campaignPosts.addAll(
          result.data!.toTypedList((data) => CampaignPost.fromJson(data)),
        ),
      );
    });

    setState(() => _isLoadingLists = false);
  }

  Future<void> _fetchCampaignRequests() async {
    setState(() {
      _isLoadingLists = true;
      _campaignRequests.clear();
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final accessToken = userProvider.credentials?.accessToken;

    if (widget.isPublic || !userProvider.isLoggedIn) {
      setState(() => _isLoadingLists = false);
      return;
    }

    if (accessToken == null) {
      showErrorSnackBar(context, 'You are not logged in. Please log in again.');
      if (mounted) setState(() => _isLoadingLists = false);
      return;
    }

    if (!mounted) return;
    final result = await Provider.of<CampaignRequestService>(
      context,
      listen: false,
    ).getCampaignRequests(
      CampaignRequestFilter(campaignId: widget.campaignId),
      accessToken,
    );

    if (!mounted) return;
    await handleServiceResponse(context, result, onSuccess: () {
      if (result.data == null) return;
      setState(
        () => _campaignRequests.addAll(
          result.data!.toTypedList((data) => CampaignRequest.fromJson(data)),
        ),
      );
    });

    setState(() => _isLoadingLists = false);
  }
}
