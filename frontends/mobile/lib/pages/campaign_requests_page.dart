import 'package:flutter/material.dart';
import 'package:mobile/models/campaign_request.dart';
import 'package:mobile/services/campaign_request_service.dart';
import 'package:mobile/pages/campaign_request_detail_page.dart';
import 'package:mobile/config.dart' as config;

class CampaignRequestsPage extends StatefulWidget {
  const CampaignRequestsPage({super.key});

  @override
  State<CampaignRequestsPage> createState() => _CampaignRequestsPageState();
}

class _CampaignRequestsPageState extends State<CampaignRequestsPage> {
  final CampaignRequestService _campaignRequestService =
      CampaignRequestService();
  List<CampaignRequest> _campaignRequests = [];
  bool _isLoading = true;
  String? _errorMessage;

  // For Create New Request Bottom Sheet
  final _createFormKey = GlobalKey<FormState>();
  String? _selectedRequestType;
  final _titleController = TextEditingController();
  final _justificationController = TextEditingController();
  bool _isCreating = false;

  // TODO: Replace with actual campaign ID source
  final String _placeholderCampaignId = "default-campaign-id";

  final List<Map<String, String>> _requestTypes = [
    {'value': 'GOAL_ADJUSTMENT_REQUEST', 'displayName': 'Goal Adjustment'},
    {'value': 'STATUS_CHANGE_REQUEST', 'displayName': 'Status Change'},
    {'value': 'POST_UPDATE_REQUEST', 'displayName': 'Post Update'},
    {'value': 'END_EXTENSION_REQUEST', 'displayName': 'End Date Extension'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchCampaignRequests();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _justificationController.dispose();
    super.dispose();
  }

  Future<void> _fetchCampaignRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    const String accessToken = config.placeholderAccessToken;

    final result = await _campaignRequestService.getCampaignRequests(
        accessToken: accessToken);

    if (mounted) {
      setState(() {
        if (result.data != null) {
          _campaignRequests = List<CampaignRequest>.from(result.data!.items);
        } else {
          _errorMessage =
              result.error?.toString() ?? 'Failed to load campaign requests.';
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _handleCreateRequest() async {
    if (_createFormKey.currentState!.validate() && _selectedRequestType != null) {
      setState(() {
        _isCreating = true;
      });

      const String accessToken = config.placeholderAccessToken;

      final result = await _campaignRequestService.createCampaignRequest(
        campaignId: _placeholderCampaignId, // TODO: Use actual campaign ID
        accessToken: accessToken,
        requestType: _selectedRequestType!,
        title: _titleController.text,
        justification: _justificationController.text,
      );

      if (mounted) {
        setState(() {
          _isCreating = false;
        });
        if (result.data != null) {
          Navigator.of(context).pop(); // Close the bottom sheet
          _titleController.clear();
          _justificationController.clear();
          _selectedRequestType = null;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Request created successfully!')),
          );
          _fetchCampaignRequests(); // Refresh the list
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(result.error?.toString() ?? 'Failed to create request.')),
          );
        }
      }
    }
  }

  void _showCreateRequestBottomSheet(BuildContext context) {
    // Reset fields when opening
    _titleController.clear();
    _justificationController.clear();
    _selectedRequestType = null;
    if (_createFormKey.currentState != null) {
      _createFormKey.currentState!.reset();
    }


    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext ctx) {
        final currentTheme = Theme.of(ctx);
        // Use a StatefulWidget for the bottom sheet's content
        // to manage dropdown state locally if needed, or manage via _selectedRequestType in parent.
        // For simplicity, managing _selectedRequestType in _CampaignRequestsPageState.
        // We need to use StatefulBuilder to update the dropdown selection UI.
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 16.0,
                right: 16.0,
                top: 20.0,
              ),
              child: Form(
                key: _createFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Create new campaign request',
                      style: currentTheme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Request type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.rule_folder_outlined),
                      ),
                      value: _selectedRequestType,
                      hint: const Text('Select request type'),
                      onChanged: (String? newValue) {
                        setModalState(() { // Use modal's state setter
                          _selectedRequestType = newValue;
                        });
                        // Also update the parent state if needed, though here it's directly used
                        setState(() {
                           _selectedRequestType = newValue;
                        });
                      },
                      items: _requestTypes.map<DropdownMenuItem<String>>((Map<String, String> type) {
                        return DropdownMenuItem<String>(
                          value: type['value'],
                          child: Text(type['displayName']!),
                        );
                      }).toList(),
                      validator: (value) => value == null ? 'Please select a request type' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
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
                        labelText: 'Justification',
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
                          onPressed: _isCreating ? null : _handleCreateRequest,
                          child: _isCreating
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Create'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final ThemeData currentTheme = Theme.of(context);

    return Scaffold( // Added Scaffold to use FloatingActionButton
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search requests...',
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
                    onChanged: (value) {
                      // TODO: Implement search functionality
                    },
                  ),
                ),
                const SizedBox(width: 8.0),
                Container(
                  decoration: BoxDecoration(
                    color: currentTheme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.filter_list,
                      color: currentTheme.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () {
                      // TODO: Implement filter functionality
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            _errorMessage!,
                            style:
                                TextStyle(color: currentTheme.colorScheme.error),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : _campaignRequests.isEmpty
                        ? const Center(child: Text('No campaign requests found.'))
                        : ListView.builder(
                            itemCount: _campaignRequests.length,
                            itemBuilder: (context, index) {
                              final request = _campaignRequests[index];
                              return _CampaignRequestCard(request: request);
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateRequestBottomSheet(context);
        },
        backgroundColor: currentTheme.colorScheme.primary,
        foregroundColor: currentTheme.colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CampaignRequestCard extends StatelessWidget {
  final CampaignRequest request;

  const _CampaignRequestCard({required this.request});

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
            .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
            .join(' ');
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return "${date.day}/${date.month}/${date.year % 100}";
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

  Color _getResolutionStatusColor(
      ResolutionType? resolutionType, ThemeData theme) {
    if (resolutionType == null) {
      return Colors.orange; // Pending
    }
    switch (resolutionType) {
      case ResolutionType.accepted:
        return Colors.green; // Accepted
      case ResolutionType.rejected:
        return Colors.red; // Rejected
      default:
        return theme.colorScheme.onSurfaceVariant; // Unknown
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData currentTheme = Theme.of(context);
    return GestureDetector(
        onTap: () {
          print("shit request $request");
          if (request.id != null) {
            
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    CampaignRequestDetailPage(requestId: request.id!),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
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
                        request.title,
                        style: currentTheme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      'Status: ${_getResolutionStatusText(request.resolutionType)}',
                      style: currentTheme.textTheme.bodySmall?.copyWith(
                        color: _getResolutionStatusColor(
                            request.resolutionType, currentTheme),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Type: ${_formatRequestType(request.type)}',
                  style: currentTheme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Date: ${_formatDate(request.requestDate)}',
                  style: currentTheme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ));
  }
}
