import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:mobile/components/campaign_request_card.dart';
import 'package:mobile/components/campaign_request_filter_dialog.dart';
import 'package:mobile/components/page_with_floating_button.dart';
import 'package:mobile/models/campaign_request.dart';
import 'package:mobile/models/server/errors.dart';
import 'package:mobile/models/server/filters.dart';
import 'package:mobile/pages/add_campaign_request_page.dart';
import 'package:mobile/services/campaign_request_service.dart';
import 'package:mobile/services/providers.dart';

class CampaignRequestsPage extends StatefulWidget {
  const CampaignRequestsPage({super.key});

  @override
  State<CampaignRequestsPage> createState() => _CampaignRequestsPageState();
}

class _CampaignRequestsPageState extends State<CampaignRequestsPage> {
  final List<CampaignRequest> _campaignRequests = [];
  bool _isLoading = false, _hasMore = true, _initialLoadAttempted = false;
  int _currentPage = 1;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  CampaignRequestFilter _filters = CampaignRequestFilter();

  @override
  void initState() {
    super.initState();
    _fetchCampaignRequests();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
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

    return PageWithFloatingButton(
      onFabPressed: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AddCampaignRequestPage()),
      ),
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
    );
  }

  //****** Page sections
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
              campaignRequest: _campaignRequests[index],
              afterPop: () async {
                setState(() {
                  _campaignRequests.clear();
                  _currentPage = 1;
                  _hasMore = true;
                  _initialLoadAttempted = false;
                });
                await _fetchCampaignRequests();
              },
            );
          },
        ),
      );
    }
  }

  //****** Helper functions
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
          context,
          'Authentication error. Please log in again.',
        );
      }
      setState(() => _isLoading = false);
      return;
    }

    final result = await Provider.of<CampaignRequestService>(
      context,
      listen: false,
    ).getCampaignRequests(_filters, accessToken);

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
            "[INFO]: Fetched page ${result.data?.pageNo}, Total pages: ${result.data?.pageCount}, Has more: $_hasMore",
          );
        });
      },
      onValidationErrors: (errors) {
        debugPrint("[ERROR]: Error fetching campaign requests $errors");
        if (mounted) {
          showErrorSnackBar(
            context,
            'Failed to load requests: ${errors['detail']?.first ?? 'Unknown error'}',
          );
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
}
