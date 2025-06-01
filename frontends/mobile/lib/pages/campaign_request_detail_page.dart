import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/models/campaign_request.dart';
import 'package:mobile/services/campaign_request_service.dart';
import 'package:mobile/components/custom_appbar.dart';
import 'package:mobile/config.dart' as config;

class CampaignRequestDetailPage extends StatefulWidget {
  final String requestId;

  const CampaignRequestDetailPage({super.key, required this.requestId});

  @override
  State<CampaignRequestDetailPage> createState() =>
      _CampaignRequestDetailPageState();
}

class _CampaignRequestDetailPageState extends State<CampaignRequestDetailPage> {
  final CampaignRequestService _campaignRequestService =
      CampaignRequestService();
  CampaignRequest? _campaignRequest;
  bool _isLoading = true;
  String? _errorMessage;

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _justificationController;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _justificationController = TextEditingController();
    _fetchCampaignRequestDetails();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _justificationController.dispose();
    super.dispose();
  }

  Future<void> _fetchCampaignRequestDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    const String accessToken = config.placeholderAccessToken;

    final result = await _campaignRequestService.getCampaignRequestById(
        widget.requestId, accessToken);

    if (mounted) {
      setState(() {
        if (result.data != null) {
          _campaignRequest = result.data;
          // Initialize controllers if data is fetched successfully
          _titleController.text = _campaignRequest!.title;
          _justificationController.text = _campaignRequest!.justification;
        } else {
          _errorMessage =
              result.error?.toString() ?? 'Failed to load campaign request details.';
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _handleUpdateRequest() async {
    if (_formKey.currentState!.validate() && _campaignRequest != null) {
      setState(() {
        _isUpdating = true;
      });

      const String accessToken = config.placeholderAccessToken; // Replace with actual token

      final result = await _campaignRequestService.updateCampaignRequest(
        _campaignRequest!.id!,
        accessToken,
        title: _titleController.text,
        justification: _justificationController.text,
      );

      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
        if (result.data != null) {
          setState(() {
            _campaignRequest = result.data;
          });
          Navigator.of(context).pop(); // Close the bottom sheet
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Request updated successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(result.error?.toString() ?? 'Failed to update request.')),
          );
        }
      }
    }
  }

  void _showEditBottomSheet(BuildContext context) {
    if (_campaignRequest == null) return;

    // Ensure controllers are up-to-date with current _campaignRequest values
    _titleController.text = _campaignRequest!.title;
    _justificationController.text = _campaignRequest!.justification;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Important for keyboard to not cover fields
      builder: (BuildContext ctx) {
        final currentTheme = Theme.of(ctx);
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom, // Adjust for keyboard
            left: 16.0,
            right: 16.0,
            top: 20.0,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Edit campaign request',
                  style: currentTheme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'New title',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _justificationController,
                  decoration: const InputDecoration(
                    labelText: 'New justification',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.notes),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a justification';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isUpdating ? null : _handleUpdateRequest,
                      child: _isUpdating
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Submit'),
                    ),
                  ],
                ),
                const SizedBox(height: 20), // Padding at the bottom
              ],
            ),
          ),
        );
      },
    );
  }

// ...existing _formatRequestType, _formatDate, _getResolutionStatusText methods...
  String _formatRequestType(String type) {
    switch (type) {
      case 'GOAL_ADJUSTMENT_REQUEST':
        return 'Goal Adjustment';
      case 'STATUS_CHANGE_REQUEST':
        return 'Status Change';
      case 'POST_UPDATE_REQUEST':
        return 'Post Update';
      case 'END_EXTENSION_REQUEST':
        return 'End Date Extension';
      default:
        return type
            .replaceAll('_', ' ')
            .toLowerCase()
            .split(' ')
            .map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
            .join(' ');
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd/MM/yy').format(date);
  }

  String _getResolutionStatusText(ResolutionType? resolutionType) {
    if (resolutionType == null) {
      return 'Pending';
    }
    switch (resolutionType) {
      case ResolutionType.accepted:
        return 'Accepted';
      case ResolutionType.rejected:
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData currentTheme = Theme.of(context);

    return Scaffold(
      appBar: const CustomAppBar(pageTitle: "Request Details"),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: currentTheme.colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : _campaignRequest == null
                  ? const Center(child: Text('Campaign request not found.'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _campaignRequest!.title, // This will update after successful edit
                                style: currentTheme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              Row(
                                children: [
                                  Text(
                                    'Type: ${_formatRequestType(_campaignRequest!.type)}',
                                    style: currentTheme.textTheme.bodyLarge,
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Status: ${_getResolutionStatusText(_campaignRequest!.resolutionType)}',
                                    style: currentTheme.textTheme.bodyLarge?.copyWith(
                                      color: _campaignRequest!.resolutionType == ResolutionType.accepted
                                          ? Colors.green
                                          : _campaignRequest!.resolutionType == ResolutionType.rejected
                                              ? Colors.red
                                              : Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                'Request Date: ${_formatDate(_campaignRequest!.requestDate)}',
                                style: currentTheme.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                'Resolution Date: ${_formatDate(_campaignRequest!.resolutionDate)}',
                                style: currentTheme.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 16.0),
                              Text(
                                'Justification:',
                                style: currentTheme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                _campaignRequest!.justification, // This will update
                                style: currentTheme.textTheme.bodyMedium,
                                textAlign: TextAlign.justify,
                              ),
                              const SizedBox(height: 24.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      _showEditBottomSheet(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: currentTheme.colorScheme.secondaryContainer,
                                      foregroundColor: currentTheme.colorScheme.onSecondaryContainer,
                                    ),
                                    child: const Text('Edit'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      // TODO: Implement Delete functionality
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: currentTheme.colorScheme.errorContainer,
                                      foregroundColor: currentTheme.colorScheme.onErrorContainer,
                                    ),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
    );
  }
}