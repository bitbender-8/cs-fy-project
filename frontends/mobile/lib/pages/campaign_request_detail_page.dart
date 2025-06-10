import 'package:flutter/material.dart';
import 'package:mobile/components/custom_appbar.dart';
import 'package:mobile/models/campaign.dart';
import 'package:mobile/models/campaign_request.dart';
import 'package:mobile/models/server/errors.dart';
import 'package:mobile/pages/campaign_post_page.dart';
import 'package:mobile/services/campaign_request_service.dart';
import 'package:mobile/services/campaign_service.dart';
import 'package:mobile/services/providers.dart';
import 'package:mobile/utils/utils.dart';
import 'package:provider/provider.dart';

class CampaignRequestDetailPage extends StatefulWidget {
  final String campaignRequestId;

  const CampaignRequestDetailPage({super.key, required this.campaignRequestId});

  @override
  State<CampaignRequestDetailPage> createState() =>
      _CampaignRequestDetailPageState();
}

class _CampaignRequestDetailPageState extends State<CampaignRequestDetailPage> {
  final _fabHeroTag = GlobalKey();
  CampaignRequest? _campaignRequest;
  Campaign? _campaign;

  bool _isLoading = false;
  bool _isDeleted = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData currentTheme = Theme.of(context);
    final ColorScheme colorScheme = currentTheme.colorScheme;

    return Scaffold(
      appBar: const CustomAppBar(pageTitle: "Campaign Request Details"),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _isDeleted
              ? const Center(
                  child: Text("This campaign request has been deleted"),
                )
              : _buildContent(),
      floatingActionButton:
          _isLoading || _campaignRequest?.resolutionType != null || _isDeleted
              ? null
              : FloatingActionButton.extended(
                  backgroundColor: colorScheme.errorContainer,
                  foregroundColor: colorScheme.onErrorContainer,
                  heroTag: _fabHeroTag,
                  onPressed: _isLoading ? null : _deleteCampaignRequest,
                  label: const Text('Delete Request'),
                  icon: const Icon(Icons.delete_forever_rounded),
                ),
    );
  }

  //****** Page sections
  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          _buildRequestHeader(context),
          const SizedBox(height: 8),
          _buildJustificationSection(context),
          const SizedBox(height: 8),
          _buildRequestSpecificDetails(context),
        ],
      ),
    );
  }

  Widget _buildRequestHeader(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextStyle titleStyle = textTheme.headlineSmall!.copyWith(
      fontWeight: FontWeight.bold,
      color: colorScheme.onSurface,
    );

    return _buildCard(context, [
      Text(
        toTitleCase(_campaignRequest?.title ?? "Unknown"),
        style: titleStyle,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
      const Divider(height: 14, thickness: 2),
      const SizedBox(height: 4),
      _buildInfoRow(
        context: context,
        label: "Parent campaign title:",
        value: "\n${_campaign?.title ?? "Unknown"}",
        icon: Icons.title_rounded,
      ),
      _buildInfoRow(
        context: context,
        label: 'Status:',
        value: "\n${_campaignRequest?.resolutionType?.value ?? "Pending"}",
        icon: Icons.info_outline,
      ),
      _buildInfoRow(
        context: context,
        label: 'Request Type:',
        value: "\n${_campaignRequest?.requestType.value ?? "Unknown"}",
        icon: Icons.pages_outlined,
      ),
      _buildInfoRow(
        context: context,
        label: "Request Date:",
        value: formatDate(_campaignRequest?.requestDate, isShort: false),
        icon: Icons.calendar_today,
      ),
      _buildInfoRow(
        context: context,
        label: "Request resolved:",
        value: _campaignRequest?.resolutionType != null ? "Yes" : "No",
        icon: Icons.check_circle,
        secondLabel: "Resolution Date:",
        secondValue: formatDate(
          _campaignRequest?.resolutionDate,
          isShort: false,
        ),
        secondIcon: Icons.calendar_today,
      ),
      const Divider(height: 12),
    ]);
  }

  Widget _buildJustificationSection(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return _buildCard(context, [
      Padding(
        padding: const EdgeInsets.only(bottom: 2.0, top: 2.0),
        child: Row(
          children: [
            Icon(Icons.description, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Justification',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      const Divider(height: 14),
      const SizedBox(height: 4),
      Text(
        _campaignRequest?.justification ?? "No justification provided.",
        style: textTheme.bodyLarge!.copyWith(
          color: colorScheme.onSurfaceVariant,
          height: 1.5, // Improve readability for long text
        ),
      ),
    ]);
  }

  Widget _buildRequestSpecificDetails(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    List<Widget> details = [];

    details.add(
      Padding(
        padding: const EdgeInsets.only(bottom: 2.0, top: 2.0),
        child: Row(
          children: [
            Icon(Icons.category_outlined, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Request Specific Details',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
    details.addAll([
      const Divider(height: 14),
      const SizedBox(height: 4),
    ]);

    if (_campaignRequest is GoalAdjustmentRequest) {
      final request = _campaignRequest as GoalAdjustmentRequest;
      details.add(_buildInfoRow(
        context: context,
        label: 'New Goal:',
        value: request.newGoal,
        icon: Icons.flag,
      ));
    } else if (_campaignRequest is PostUpdateRequest) {
      final request = _campaignRequest as PostUpdateRequest;

      details.add(
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            leading: Icon(Icons.article_outlined, color: colorScheme.primary),
            title: Text(
              toTitleCase(request.newPost.title),
              style: textTheme.titleMedium!.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              'Tap to view post',
              style: textTheme.bodySmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            trailing: const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CampaignPostPage(
                    campaignPost: request.newPost,
                  ),
                ),
              );
            },
          ),
        ),
      );
    } else if (_campaignRequest is EndDateExtensionRequest) {
      final request = _campaignRequest as EndDateExtensionRequest;
      details.add(_buildInfoRow(
        context: context,
        label: 'New End Date:',
        value: formatDate(request.newEndDate, isShort: false),
        icon: Icons.date_range,
      ));
    } else if (_campaignRequest is StatusChangeRequest) {
      final request = _campaignRequest as StatusChangeRequest;
      details.add(_buildInfoRow(
        context: context,
        label: 'Updated Campaign Status: ',
        value: request.newStatus.value,
        icon: Icons.info,
      ));
    } else {
      details.add(const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text('No specific details for this request type.'),
      ));
    }

    return _buildCard(context, details);
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
        padding: const EdgeInsets.all(12),
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
                      if (label.isNotEmpty)
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

  //****** Helper functions
  Future<void> _fetchData() async {
    setState(() => _isLoading = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final accessToken = userProvider.credentials?.accessToken;

    if (accessToken == null) {
      showErrorSnackBar(context, 'You are not logged in. Please log in again.');
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    // Fetch campaign request
    final campaignRequestResult = await Provider.of<CampaignRequestService>(
      context,
      listen: false,
    ).getCampaignRequestById(
      widget.campaignRequestId,
      accessToken,
    );

    if (!mounted) return;
    await handleServiceResponse(context, campaignRequestResult, onSuccess: () {
      if (campaignRequestResult.data == null) return;
      setState(() => _campaignRequest = campaignRequestResult.data);
    });

    // Fetch associated campaign
    if (!mounted) return;
    final campaignResult = await Provider.of<CampaignService>(
      context,
      listen: false,
    ).getCampaignById(
      _campaignRequest!.campaignId,
      accessToken,
    );

    if (!mounted) return;
    await handleServiceResponse(context, campaignResult, onSuccess: () {
      if (campaignResult.data == null) return;
      setState(() => _campaign = campaignResult.data);
    });

    setState(() => _isLoading = false);
  }

  Future<void> _deleteCampaignRequest() async {
    setState(() => _isLoading = true);

    final deleteCampaignRequest = await showConfirmationDialog(
      context,
      "Delete campaign request",
      "Deleting a campaign request is permanent and irreversible. Are you sure you want to perform this action?",
    );
    if (!deleteCampaignRequest) {
      setState(() => _isLoading = false);
      return;
    }

    if (!mounted) return;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final accessToken = userProvider.credentials?.accessToken;

    if (accessToken == null) {
      showErrorSnackBar(context, 'You are not logged in. Please log in again.');
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final result = await Provider.of<CampaignRequestService>(
      context,
      listen: false,
    ).deleteCampaignRequest(
      widget.campaignRequestId,
      accessToken,
    );

    if (!mounted) return;
    await handleServiceResponse(context, result, onSuccess: () {
      if (result.data == true) _isDeleted = true;
    });

    setState(() => _isLoading = false);
  }
}
