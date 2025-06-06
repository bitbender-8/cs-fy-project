import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/components/campaign_request_card.dart';
import 'package:mobile/components/campaign_request_filter_dialog.dart';
import 'package:mobile/models/campaign.dart';
import 'package:mobile/models/campaign_request.dart';
import 'package:mobile/models/server/errors.dart';
import 'package:mobile/models/server/filters.dart';
import 'package:mobile/services/campaign_request_service.dart';
import 'package:mobile/services/campaign_service.dart';
import 'package:mobile/services/providers.dart';
import 'package:provider/provider.dart';

class CampaignRequestsPage extends StatefulWidget {
  const CampaignRequestsPage({super.key});

  @override
  State<CampaignRequestsPage> createState() => _CampaignRequestsPageState();
}

class _CampaignRequestsPageState extends State<CampaignRequestsPage>
    with FormErrorHelpers<CampaignRequestsPage> {
  // ****** Search bar fields
  final List<CampaignRequest> _campaignRequests = [];
  bool _isLoading = false, _hasMore = true, _initialLoadAttempted = false;
  int _currentPage = 1;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  CampaignRequestFilter _filters = CampaignRequestFilter();

  // ****** Campaign request pop-up fields
  final _createFormKey = GlobalKey<FormState>();
  String?
      _selectedRequestTypeString; // Store the string value of the selected type

  // Common fields for request
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _justificationController =
      TextEditingController();

  // Fields for Post Update
  final TextEditingController _newPostContentController =
      TextEditingController();
  final TextEditingController _newPostTitleController = TextEditingController();

  // Fields for other request types
  final TextEditingController _newGoalController = TextEditingController();
  final TextEditingController _newEndDateDisplayController =
      TextEditingController();
  DateTime? _selectedNewEndDate;
  CampaignStatus? _selectedNewStatus;

  bool _isCreatingRequest = false;

  // Campaign Search fields
  final TextEditingController _campaignSearchController =
      TextEditingController();
  List<Campaign> _campaignSearchResults = [];
  Campaign? _selectedCampaign;
  bool _isSearchingCampaigns = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchCampaignRequests();
    _scrollController.addListener(_onScroll);
    // _selectedRequestTypeString is initialized in _resetCampaignRequestFields
    // which is called when the bottom sheet is shown.
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _titleController.dispose();
    _justificationController.dispose();
    _newPostContentController.dispose();
    _newPostTitleController.dispose();
    _newGoalController.dispose();
    _newEndDateDisplayController.dispose();
    _campaignSearchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _clearDynamicFields() {
    _newPostTitleController.clear();
    _newPostContentController.clear();
    _newGoalController.clear();
    _newEndDateDisplayController.clear();
    _selectedNewEndDate = null;
    _selectedNewStatus = null;
    // Clear server errors associated with these fields if any
    clearServerError('newPost.title');
    clearServerError('newPost.content');
    clearServerError('newGoal');
    clearServerError('newStatus');
    clearServerError('newEndDate');
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    final colorScheme = currentTheme.colorScheme;

    final searchBarDecoration = InputDecoration(
      hintText: 'Search by title',
      prefixIcon: const Icon(Icons.search_rounded),
      suffixIcon: _searchController.text.isEmpty
          ? null
          : IconButton(
              icon: const Icon(Icons.clear_rounded),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _filters = _filters.copyWith(title: null);
                  _campaignRequests.clear();
                  _currentPage = 1;
                  _hasMore = true;
                  _initialLoadAttempted = false;
                });
                _fetchCampaignRequests();
              },
            ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
    );

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: searchBarDecoration,
                    onSubmitted: (value) {
                      setState(() {
                        _filters = _filters.copyWith(
                            title: value.isEmpty ? null : value);
                        _campaignRequests.clear();
                        _currentPage = 1;
                        _hasMore = true;
                        _initialLoadAttempted = false;
                      });
                      _fetchCampaignRequests();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () async {
                    final newFilters = await showDialog<CampaignRequestFilter>(
                      context: context,
                      builder: (context) => CampaignRequestFilterDialog(
                        currentFilters: _filters,
                      ),
                    );

                    if (newFilters != null && mounted) {
                      setState(() {
                        _filters = newFilters.copyWith(title: _filters.title);
                        _campaignRequests.clear();
                        _currentPage = 1;
                        _hasMore = true;
                        _initialLoadAttempted = false;
                      });
                      _fetchCampaignRequests();
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.tune_rounded,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(child: _buildContent(colorScheme))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateRequestBottomSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent(ColorScheme colorScheme) {
    final bool showInitialScreen =
        _isLoading && !_initialLoadAttempted && _campaignRequests.isEmpty;
    final bool showNoResultsScreen =
        _campaignRequests.isEmpty && _initialLoadAttempted && !_isLoading;

    if (showInitialScreen) {
      return const Center(child: CircularProgressIndicator());
    } else if (showNoResultsScreen) {
      return Center(
        child: Text(
          'No matching campaign requests found.',
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 18),
        ),
      );
    } else {
      return RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _campaignRequests.clear();
            _currentPage = 1;
            _hasMore = true;
            _initialLoadAttempted = false;
          });
          await _fetchCampaignRequests();
        },
        child: ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: _campaignRequests.length + (_hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _campaignRequests.length) {
                return _hasMore && _isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : const SizedBox.shrink();
              }
              return CampaignRequestCard(
                  campaignRequest: _campaignRequests[index]);
            }),
      );
    }
  }

  void _showCreateRequestBottomSheet(BuildContext context) {
    clearAllServerErrors();
    _resetCampaignRequestFields(); // Initializes _selectedRequestTypeString

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final currentTheme = Theme.of(ctx);

        return StatefulBuilder(builder:
            (BuildContext modalBuilderContext, StateSetter setModalState) {
          void performModalCampaignSearch(String query) {
            if (query.length < 3) {
              setModalState(() {
                _campaignSearchResults.clear();
                _isSearchingCampaigns = false;
              });
              return;
            }
            setModalState(() {
              _isSearchingCampaigns = true;
              _campaignSearchResults.clear();
            });

            final userProvider =
                Provider.of<UserProvider>(this.context, listen: false);
            final accessToken = userProvider.credentials?.accessToken;

            if (accessToken == null) {
              if (mounted) {
                showErrorSnackBar(
                    this.context, 'Authentication error for campaign search.');
              }
              setModalState(() => _isSearchingCampaigns = false);
              return;
            }

            final campaignService =
                Provider.of<CampaignService>(this.context, listen: false);
            final filter = CampaignFilter(title: query);

            campaignService.getCampaigns(filter, accessToken).then((result) {
              if (!this.mounted) return;
              handleServiceResponse(
                this.context,
                result,
                onSuccess: () {
                  if (result.data != null) {
                    setModalState(() {
                      _campaignSearchResults = result.data!.toTypedList(
                        (data) => Campaign.fromJson(data),
                      );
                    });
                  }
                },
                onValidationErrors: (errors) {
                  debugPrint("[ERROR]: Error searching campaigns: $errors");
                  if (this.mounted) {
                    showErrorSnackBar(this.context,
                        'Failed to search campaigns: ${errors['detail']?.first ?? 'Unknown error'}');
                  }
                },
              ).whenComplete(() {
                if (this.mounted) {
                  setModalState(() {
                    _isSearchingCampaigns = false;
                  });
                }
              });
            });
          }

          void _onModalCampaignSearchTextChanged() {
            if (_debounce?.isActive ?? false) _debounce!.cancel();
            _debounce = Timer(const Duration(milliseconds: 500), () {
              final currentQuery = _campaignSearchController.text;
              if (currentQuery.isNotEmpty && currentQuery.length >= 3) {
                performModalCampaignSearch(currentQuery);
              } else {
                setModalState(() {
                  _campaignSearchResults.clear();
                  _isSearchingCampaigns = false;
                });
              }
            });
          }

          Widget _buildDynamicRequestFields() {
            if (_selectedRequestTypeString == null) {
              return const SizedBox.shrink();
            }
            // Use string comparison with .value from your enum extensions
            if (_selectedRequestTypeString ==
                CampaignRequestType.postUpdate.value) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _newPostTitleController,
                    decoration: InputDecoration(
                      labelText: 'New Post Title',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.subtitles_outlined),
                      errorText: getServerError('newPost.title'),
                    ),
                    onChanged: (value) => clearServerError('newPost.title'),
                    validator: (value) {
                      if (_selectedRequestTypeString ==
                              CampaignRequestType.postUpdate.value &&
                          (value == null || value.isEmpty)) {
                        return 'Please enter a title for the new post';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _newPostContentController,
                    decoration: InputDecoration(
                      labelText: 'New Post Content',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.text_snippet),
                      errorText: getServerError('newPost.content'),
                    ),
                    onChanged: (value) => clearServerError('newPost.content'),
                    maxLines: 5,
                    validator: (value) {
                      if (_selectedRequestTypeString ==
                              CampaignRequestType.postUpdate.value &&
                          (value == null || value.isEmpty)) {
                        return 'Please enter content for the new post';
                      }
                      return null;
                    },
                  ),
                ],
              );
            } else if (_selectedRequestTypeString ==
                CampaignRequestType.statusChange.value) {
              return DropdownButtonFormField<CampaignStatus>(
                value: _selectedNewStatus,
                decoration: InputDecoration(
                  labelText: 'New Status',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.toggle_on_outlined),
                  errorText: getServerError('newStatus'),
                ),
                hint: const Text('Select new status'),
                items: CampaignStatus.values.map((CampaignStatus status) {
                  return DropdownMenuItem<CampaignStatus>(
                    value: status,
                    child: Text(
                        status.value), // Using .value for display as requested
                  );
                }).toList(),
                onChanged: (CampaignStatus? newValue) {
                  setModalState(() {
                    _selectedNewStatus = newValue;
                  });
                  clearServerError('newStatus');
                },
                validator: (value) {
                  if (_selectedRequestTypeString ==
                          CampaignRequestType.statusChange.value &&
                      value == null) {
                    return 'Please select a new status';
                  }
                  return null;
                },
              );
            } else if (_selectedRequestTypeString ==
                CampaignRequestType.goalAdjustment.value) {
              return TextFormField(
                controller: _newGoalController,
                decoration: InputDecoration(
                  labelText: 'New Goal Amount',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.track_changes_outlined),
                  errorText: getServerError('newGoal'),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) => clearServerError('newGoal'),
                validator: (value) {
                  if (_selectedRequestTypeString ==
                      CampaignRequestType.goalAdjustment.value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a new goal amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                  }
                  return null;
                },
              );
            } else if (_selectedRequestTypeString ==
                CampaignRequestType.endDateExtension.value) {
              return TextFormField(
                controller: _newEndDateDisplayController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'New End Date',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                  errorText: getServerError('newEndDate'),
                ),
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context:
                        modalBuilderContext, // Use modal's context for date picker
                    initialDate: _selectedNewEndDate ??
                        DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now().add(const Duration(days: 1)),
                    lastDate: DateTime(DateTime.now().year + 5),
                  );
                  if (pickedDate != null) {
                    setModalState(() {
                      _selectedNewEndDate = pickedDate;
                      _newEndDateDisplayController.text =
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                    });
                    clearServerError('newEndDate');
                  }
                },
                validator: (value) {
                  if (_selectedRequestTypeString ==
                          CampaignRequestType.endDateExtension.value &&
                      _selectedNewEndDate == null) {
                    return 'Please select a new end date';
                  }
                  return null;
                },
              );
            }
            return const SizedBox.shrink(); // Default empty case
          }

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(modalBuilderContext)
                  .viewInsets
                  .bottom, // Use modal's context
              left: 16.0,
              right: 16.0,
              top: 20.0,
            ),
            child: Form(
              key: _createFormKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Create new campaign request',
                      style: currentTheme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      // Campaign Search
                      controller: _campaignSearchController,
                      decoration: InputDecoration(
                        labelText: _selectedCampaign != null
                            ? 'Selected Campaign: ${_selectedCampaign!.title}'
                            : 'Search Campaign by Title',
                        hintText: 'Type to search campaigns (min 3 chars)',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.campaign),
                        suffixIcon: _isSearchingCampaigns
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : (_selectedCampaign != null
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      setModalState(() {
                                        _selectedCampaign = null;
                                        _campaignSearchController.clear();
                                        _campaignSearchResults.clear();
                                        _isSearchingCampaigns = false;
                                      });
                                    },
                                  )
                                : (_campaignSearchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          setModalState(() {
                                            _campaignSearchController.clear();
                                            _campaignSearchResults.clear();
                                            _isSearchingCampaigns = false;
                                            if (_debounce?.isActive ?? false) {
                                              _debounce!.cancel();
                                            }
                                          });
                                        })
                                    : null)),
                      ),
                      readOnly: _selectedCampaign != null,
                      onChanged: (value) => _onModalCampaignSearchTextChanged(),
                      validator: (value) {
                        if (_selectedCampaign == null) {
                          return 'Please select a campaign.';
                        }
                        return null;
                      },
                      onTap: () {
                        if (_selectedCampaign != null) {
                          setModalState(() {
                            _selectedCampaign = null;
                            _campaignSearchResults.clear();
                          });
                        }
                      },
                      onFieldSubmitted: (value) {
                        if (_debounce?.isActive ?? false) _debounce!.cancel();
                        if (value.length >= 3) {
                          performModalCampaignSearch(value);
                        } else {
                          setModalState(() {
                            _campaignSearchResults.clear();
                            _isSearchingCampaigns = false;
                          });
                        }
                      },
                    ),
                    if (_isSearchingCampaigns && _campaignSearchResults.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    if (_campaignSearchResults.isNotEmpty &&
                        _selectedCampaign == null)
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _campaignSearchResults.length,
                          itemBuilder: (context, index) {
                            final campaign = _campaignSearchResults[index];
                            return ListTile(
                              title: Text(campaign.title),
                              subtitle: Text(campaign.id ?? 'No Id'),
                              onTap: () {
                                setModalState(() {
                                  _selectedCampaign = campaign;
                                  _campaignSearchController.text =
                                      campaign.title;
                                  _campaignSearchResults.clear();
                                  _isSearchingCampaigns = false;
                                });
                              },
                            );
                          },
                        ),
                      ),
                    if (!_isSearchingCampaigns &&
                        _campaignSearchController.text.length >= 3 &&
                        _campaignSearchResults.isEmpty &&
                        _selectedCampaign == null)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(child: Text("No campaigns found.")),
                      ),
                    const SizedBox(height: 16),
                    // Request Type Dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Request type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.rule_folder_outlined),
                      ),
                      value: _selectedRequestTypeString, // Use the string value
                      hint: const Text('Select request type'),
                      onChanged: (String? newValue) {
                        setModalState(() {
                          _selectedRequestTypeString = newValue;
                          _clearDynamicFields(); // Clear fields when type changes
                        });
                      },
                      items: CampaignRequestType.values.map((type) {
                        return DropdownMenuItem<String>(
                          value: type.value, // Store the string value
                          child: Text(type.value), // Display the string value
                        );
                      }).toList(),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please select a request type'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    // Common Fields: Title and Justification
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Request Title',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.title),
                        errorText: getServerError('title'),
                      ),
                      onChanged: (value) => clearServerError('title'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a request title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _justificationController,
                      decoration: InputDecoration(
                        labelText: 'Justification',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.notes),
                        errorText: getServerError('justification'),
                      ),
                      onChanged: (value) => clearServerError('justification'),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a justification';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Dynamically built fields
                    _buildDynamicRequestFields(),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () => Navigator.of(modalBuilderContext)
                              .pop(), // Use modal's context
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isCreatingRequest
                              ? null
                              : () => _handleCreateRequest(
                                  modalBuilderContext), // Pass modal's context
                          child: _isCreatingRequest
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Create'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  void _onScroll() {
    final currentScrollPos = _scrollController.position.pixels;
    final maxScrollExtent = _scrollController.position.maxScrollExtent;
    if (currentScrollPos >= maxScrollExtent * 0.95 && !_isLoading && _hasMore) {
      _fetchCampaignRequests();
    }
  }

  Future<void> _fetchCampaignRequests() async {
    if (!_hasMore || _isLoading) return;
    setState(() {
      _isLoading = true;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final accessToken = userProvider.credentials?.accessToken;
    final ownerId = userProvider.user?.id;

    _filters = _filters.copyWith(page: _currentPage, ownerRecipientId: ownerId);
    debugPrint(
        "[INFO]: Fetching page: $_currentPage with filters: ${_filters.toMap()}");

    if (accessToken == null) {
      if (mounted) {
        showErrorSnackBar(
            context, 'Authentication error. Please log in again.');
      }
      setState(() => _isLoading = false);
      return;
    }

    final result =
        await Provider.of<CampaignRequestService>(context, listen: false)
            .getCampaignRequests(_filters, accessToken);

    if (!mounted) return;

    List<CampaignRequest> newCampaignRequests = [];
    await handleServiceResponse(
      context,
      result,
      onSuccess: () async {
        if (result.data != null) {
          newCampaignRequests = result.data!
              .toTypedList((data) => CampaignRequest.fromJson(data));
        }
        setState(() {
          _campaignRequests.addAll(newCampaignRequests);
          _currentPage++;
          _hasMore = result.data != null &&
              result.data!.pageNo < result.data!.pageCount;
          debugPrint(
              "[INFO]: Fetched page ${result.data?.pageNo}, Total pages: ${result.data?.pageCount}, Has more: $_hasMore");
        });
      },
      onValidationErrors: (errors) {
        debugPrint("[ERROR]: Error fetching campaign requests $errors");
        if (mounted) {
          showErrorSnackBar(context,
              'Failed to load requests: ${errors['detail']?.first ?? 'Unknown error'}');
        }
      },
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (!_initialLoadAttempted) _initialLoadAttempted = true;
      });
    }
  }

  Future<void> _handleCreateRequest(BuildContext modalContext) async {
    clearAllServerErrors();
    if (!_createFormKey.currentState!.validate()) {
      // _createFormKey.currentState!.validate(); // Already called by the if condition
      return;
    }
    if (_selectedCampaign?.id == null) {
      if (mounted) {
        showErrorSnackBar(
            context, 'Selected campaign has no ID or is not selected.');
      }
      return;
    }
    if (_selectedRequestTypeString == null ||
        _selectedRequestTypeString!.isEmpty) {
      if (mounted) showErrorSnackBar(context, 'Please select a request type.');
      return;
    }

    setState(() {
      _isCreatingRequest = true;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final accessToken = userProvider.credentials?.accessToken;
    final ownerRecipientId = userProvider.user?.id;

    if (accessToken == null) {
      if (mounted) {
        showErrorSnackBar(
            context, 'Authentication error. Please log in again.');
        setState(() {
          _isCreatingRequest = false;
        });
      }
      return;
    }
    if (ownerRecipientId == null) {
      if (mounted) {
        showErrorSnackBar(context, 'User information not found.');
        setState(() {
          _isCreatingRequest = false;
        });
      }
      return;
    }

    // Convert the string back to enum type for switch, or use string directly
    // Assuming your CampaignRequestType has a helper like .fromValue()
    CampaignRequestType requestTypeEnum;
    try {
      requestTypeEnum =
          CampaignRequestType.fromValue(_selectedRequestTypeString!);
    } catch (e) {
      if (mounted) showErrorSnackBar(context, "Invalid request type selected.");
      setState(() {
        _isCreatingRequest = false;
      });
      return;
    }

    CampaignRequest newRequest;
    try {
      // Use the enum for the switch
      switch (requestTypeEnum) {
        case CampaignRequestType.goalAdjustment:
          if (_newGoalController.text.isEmpty ||
              double.tryParse(_newGoalController.text) == null) {
            if (mounted) {
              showErrorSnackBar(context, "New goal amount is invalid.");
            }
            setState(() {
              _isCreatingRequest = false;
            });
            return;
          }
          newRequest = GoalAdjustmentRequest(
            campaignId: _selectedCampaign!.id!,
            ownerRecipientId: ownerRecipientId,
            title: _titleController.text,
            justification: _justificationController.text,
            newGoal: _newGoalController
                .text, // Assuming newGoal is a String in your model
          );
          break;
        case CampaignRequestType.statusChange:
          if (_selectedNewStatus == null) {
            if (mounted) {
              showErrorSnackBar(context, "Please select a new status.");
            }
            setState(() {
              _isCreatingRequest = false;
            });
            return;
          }
          newRequest = StatusChangeRequest(
            campaignId: _selectedCampaign!.id!,
            ownerRecipientId: ownerRecipientId,
            title: _titleController.text,
            justification: _justificationController.text,
            newStatus: _selectedNewStatus!,
          );
          break;
        case CampaignRequestType.postUpdate:
          if (_newPostTitleController.text.isEmpty ||
              _newPostContentController.text.isEmpty) {
            if (mounted) {
              showErrorSnackBar(
                  context, "Post title and content cannot be empty.");
            }
            setState(() {
              _isCreatingRequest = false;
            });
            return;
          }
          newRequest = PostUpdateRequest(
            campaignId: _selectedCampaign!.id!,
            ownerRecipientId: ownerRecipientId,
            title: _titleController.text,
            justification: _justificationController.text,
            newPost: CampaignPost(
              title: _newPostTitleController.text,
              campaignId: _selectedCampaign!.id!,
              content: _newPostContentController.text,
            ),
          );
          break;
        case CampaignRequestType.endDateExtension:
          if (_selectedNewEndDate == null) {
            if (mounted) {
              showErrorSnackBar(context, "Please select a new end date.");
            }
            setState(() {
              _isCreatingRequest = false;
            });
            return;
          }
          newRequest = EndDateExtensionRequest(
            campaignId: _selectedCampaign!.id!,
            ownerRecipientId: ownerRecipientId,
            title: _titleController.text,
            justification: _justificationController.text,
            newEndDate: _selectedNewEndDate!,
          );
          break;
        // default: // Should not be reached if fromValue is robust
        //   throw Exception("Unhandled request type: $requestTypeEnum");
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, "Error preparing request: ${e.toString()}");
        setState(() {
          _isCreatingRequest = false;
        });
      }
      return;
    }

    final result =
        await Provider.of<CampaignRequestService>(context, listen: false)
            .createCampaignRequest(newRequest, accessToken);

    if (!mounted) return;
    await handleServiceResponse(context, result, onSuccess: () {
      clearAllServerErrors();
      setState(() {
        _campaignRequests.clear();
        _currentPage = 1;
        _hasMore = true;
        _initialLoadAttempted = false;
      });
      Navigator.of(modalContext).pop();
      _fetchCampaignRequests();
      if (mounted) {
        showInfoSnackBar(context, 'Campaign request created successfully!');
      }
    }, onValidationErrors: (errors) {
      debugPrint("[ERROR]: Validation errors during request creation: $errors");
      if (mounted) {
        setServerErrors(errors);
        showErrorSnackBar(context,
            'Failed to create request: ${errors['detail']?.first ?? 'Validation failed'}');
        _createFormKey.currentState?.validate();
      }
    });

    if (mounted) {
      setState(() {
        _isCreatingRequest = false;
      });
    }
  }

  void _resetCampaignRequestFields() {
    _titleController.clear();
    _justificationController.clear();

    _clearDynamicFields(); // Clears all type-specific fields

    // Set initial request type to "End Date Extension"
    _selectedRequestTypeString = CampaignRequestType.endDateExtension.value;

    _campaignSearchController.clear();
    _campaignSearchResults.clear();
    _selectedCampaign = null;
    _isSearchingCampaigns = false;
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _createFormKey.currentState?.reset(); // Resets form validation state
    clearAllServerErrors();
  }
}
