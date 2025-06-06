import 'package:flutter/material.dart';
import 'package:mobile/components/campaign_card.dart';
import 'package:mobile/components/campaign_filter_dialog.dart';
import 'package:mobile/models/campaign.dart';
import 'package:mobile/models/server/errors.dart';
import 'package:mobile/models/server/filters.dart';
import 'package:mobile/services/campaign_service.dart';
import 'package:mobile/services/providers.dart';
import 'package:mobile/services/recipient_service.dart';
import 'package:provider/provider.dart';

class CampaignListPage extends StatefulWidget {
  final bool isPublicList;
  const CampaignListPage({super.key, this.isPublicList = true});

  @override
  State<CampaignListPage> createState() => _CampaignListPageState();
}

class _CampaignListPageState extends State<CampaignListPage> {
  final List<Campaign> _campaigns = [];
  bool _isLoading = false, _hasMore = true, _initialLoadAttempted = false;
  int _currentPage = 1;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  CampaignFilter _filters = CampaignFilter();

  @override
  void initState() {
    super.initState();
    _fetchCampaigns();
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
                });
              },
            ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
    );

    return Column(
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
                      _filters.title = value.isEmpty ? null : value;
                      _campaigns.clear();
                      _currentPage = 1;
                      _hasMore = true;
                      _initialLoadAttempted = false;
                    });
                    _fetchCampaigns();
                  },
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () async {
                  final newFilters = await showDialog<CampaignFilter>(
                    context: context,
                    builder: (context) => CampaignFilterDialog(
                      currentFilters: _filters,
                      showSensitiveFields: !widget.isPublicList,
                    ),
                  );

                  if (newFilters != null && mounted) {
                    setState(() {
                      _filters = newFilters.copyWith(title: _filters.title);
                      _campaigns.clear();
                      _currentPage = 1;
                      _hasMore = true;
                      _initialLoadAttempted = false;
                    });
                    _fetchCampaigns();
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
    );
  }

  //****** Page sections
  Widget _buildContent(ColorScheme colorScheme) {
    final bool showInitialScreen = _isLoading && !_initialLoadAttempted;
    final bool showNoResultsScreen =
        _campaigns.isEmpty && _initialLoadAttempted && !_isLoading;

    if (showInitialScreen) {
      return const Center(child: CircularProgressIndicator());
    } else if (showNoResultsScreen) {
      return Center(
        child: Text(
          'No matching campaigns found.',
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 18),
        ),
      );
    } else {
      // Display the list of campaigns, or a small loader at the bottom if more are loading
      return RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _campaigns.clear();
            _currentPage = 1;
            _hasMore = true;
            _initialLoadAttempted = false;
          });
          await _fetchCampaigns();
        },
        child: ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: _campaigns.length + (_hasMore && _isLoading ? 1 : 0),
          itemBuilder: (context, index) => index == _campaigns.length
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              : CampaignCard(
                  campaignData: _campaigns[index],
                  isPublic: widget.isPublicList),
        ),
      );
    }
  }

  //****** Helper methods
  void _onScroll() {
    final currentScrollPos = _scrollController.position.pixels;
    final maxScrollExtent = _scrollController.position.maxScrollExtent;

    if (currentScrollPos >= maxScrollExtent * 0.95 && !_isLoading && _hasMore) {
      _fetchCampaigns();
    }
  }

  Future<void> _fetchCampaigns() async {
    if (!_hasMore || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final accessToken = userProvider.credentials?.accessToken;
    final recipientService = Provider.of<RecipientService>(
      context,
      listen: false,
    );

    _filters = _filters.copyWith(
      page: _currentPage,
      ownerRecipientId: widget.isPublicList ? null : userProvider.user?.id,
    );
    debugPrint(
      "[INFO]: Fetching page: $_currentPage with filters: ${_filters.toMap()}",
    );

    if (!widget.isPublicList && accessToken == null) {
      showErrorSnackBar(context, 'Authentication error. Please log in again.');
      setState(() => _isLoading = false);
      return;
    }

    final result = await Provider.of<CampaignService>(
      context,
      listen: false,
    ).getCampaigns(_filters, widget.isPublicList ? null : accessToken);

    if (!mounted) return;
    await handleServiceResponse(context, result, onSuccess: () async {
      if (result.data == null) return;

      final newCampaigns = result.data!.toTypedList(
        (data) => Campaign.fromJson(data),
      );

      final campaignsWithOwners = <Campaign>[];

      for (final campaign in newCampaigns) {
        if (!mounted) return;

        try {
          if (campaign.campaignOwner == null) {
            final recipientResult = await recipientService.getRecipientById(
              campaign.ownerRecipientId,
              accessToken,
            );

            final owner = recipientResult.data;
            if (owner != null) {
              campaignsWithOwners.add(campaign.copyWith(campaignOwner: owner));
            } else {
              debugPrint(
                  "[WARNING]: Failed to fetch recipient for campaign ${campaign.id}");
              campaignsWithOwners.add(campaign);
            }
          } else {
            campaignsWithOwners.add(campaign);
          }
        } catch (e) {
          debugPrint(
              "[ERROR]: Exception fetching recipient for campaign ${campaign.id}: $e");
          campaignsWithOwners.add(campaign);
        }
      }

      if (!mounted) return;

      setState(() {
        _campaigns.addAll(campaignsWithOwners);
        _currentPage++;
        _hasMore = result.data!.pageNo < result.data!.pageCount;

        debugPrint(
          "[INFO]: Fetched page ${result.data!.pageNo}, "
          "Total pages: ${result.data!.pageCount}, Has more: $_hasMore",
        );
      });
    }, onValidationErrors: (error) {
      debugPrint("[ERROR]: Error fetching campaigns $error");
    });

    if (mounted) {
      setState(() => _isLoading = false);
      if (!_initialLoadAttempted) _initialLoadAttempted = true;
    }
  }
}
