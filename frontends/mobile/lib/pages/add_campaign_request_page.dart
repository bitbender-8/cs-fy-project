import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mobile/utils/utils.dart';
import 'package:provider/provider.dart';

import 'package:mobile/components/custom_appbar.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/campaign.dart';
import 'package:mobile/models/campaign_request.dart';
import 'package:mobile/models/server/errors.dart';
import 'package:mobile/models/server/filters.dart';
import 'package:mobile/services/campaign_request_service.dart';
import 'package:mobile/services/campaign_service.dart';
import 'package:mobile/services/providers.dart';
import 'package:mobile/utils/validators.dart';

class AddCampaignRequestPage extends StatefulWidget {
  const AddCampaignRequestPage({super.key});

  @override
  State<AddCampaignRequestPage> createState() => _AddCampaignRequestPageState();
}

class _AddCampaignRequestPageState extends State<AddCampaignRequestPage>
    with FormErrorHelpers<AddCampaignRequestPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Form fields
  var _campaignRequestType = CampaignRequestType.endDateExtension;
  CampaignStatus? _newStatus;
  String? _title, _justification, _newGoal;
  CampaignPost? _newCampaignPost;

  // Controllers for fields that need initial values or direct manipulation
  final TextEditingController _newEndDateController = TextEditingController();
  final TextEditingController _campaignSearchController =
      TextEditingController();

  // Campaign search related
  final List<Campaign> _campaignSearchResults = [];
  bool _isSearchingCampaigns = false;
  Campaign? _selectedCampaign;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _campaignSearchController.addListener(_onCampaignSearchTextChanged);
    _resetCampaignRequestFields(); // Initialize fields on load
  }

  @override
  void dispose() {
    _newEndDateController.dispose();
    _campaignSearchController.removeListener(_onCampaignSearchTextChanged);
    _campaignSearchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final titleStyle = Theme.of(context)
        .textTheme
        .titleLarge
        ?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold);

    return Scaffold(
      appBar: const CustomAppBar(pageTitle: 'Create Campaign Request'),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: ListView(
                children: [
                  const SizedBox(height: 8.0),
                  Text('Campaign Selection', style: titleStyle),
                  const Divider(height: 24, thickness: 2.0),
                  const SizedBox(height: 8.0),
                  _buildCampaignSelectionSection(context, colorScheme),
                  const SizedBox(height: 20.0),
                  Text('Request Information', style: titleStyle),
                  const Divider(height: 24, thickness: 2.0),
                  const SizedBox(height: 8.0),
                  ..._buildCommonRequestInformationSection(
                      context, colorScheme),
                  const SizedBox(height: 20.0),
                  Text('Request Details', style: titleStyle),
                  const Divider(height: 24, thickness: 2.0),
                  const SizedBox(height: 8.0),
                  _buildDynamicRequestFields(colorScheme),
                  const SizedBox(height: 40.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed:
                              _isLoading ? null : _resetCampaignRequestFields,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            foregroundColor:
                                colorScheme.onSurface.withValues(alpha: 0.6),
                            side: BorderSide(color: colorScheme.scrim),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text("Reset"),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: TextButton(
                          onPressed: _submitCampaignRequest,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text("Submit"),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          if (_isLoading) ...[
            ModalBarrier(
              color: Colors.black.withValues(alpha: 0.5),
              dismissible: false,
            ),
            const Center(
              child: CircularProgressIndicator(),
            )
          ],
        ],
      ),
    );
  }

  //****** Page sections
  Widget _buildCampaignSelectionSection(
      BuildContext context, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _campaignSearchController,
          decoration: InputDecoration(
            labelText: _selectedCampaign != null
                ? 'Selected Campaign: ${_selectedCampaign!.title}'
                : 'Search Campaign by Title',
            hintText: 'Type to search campaigns (min 3 chars)',
            border: const OutlineInputBorder(),
            prefixIcon: Icon(Icons.campaign, color: colorScheme.primary),
            suffixIcon: _isSearchingCampaigns
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : (_selectedCampaign != null
                    ? IconButton(
                        icon: Icon(Icons.clear, color: colorScheme.error),
                        onPressed: () {
                          setState(() {
                            _selectedCampaign = null;
                            _campaignSearchController.clear();
                            _campaignSearchResults.clear();
                            _isSearchingCampaigns = false;
                            // Reset dynamic fields when campaign is deselected if it affects their validity
                            _resetDynamicFields();
                          });
                        },
                      )
                    : (_campaignSearchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: colorScheme.error),
                            onPressed: () {
                              setState(() {
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
          validator: (value) {
            if (_selectedCampaign == null) {
              return 'Please select a campaign.';
            }
            return null;
          },
          onTap: () {
            if (_selectedCampaign != null) {
              setState(() {
                _selectedCampaign = null;
                _campaignSearchResults.clear();
              });
            }
          },
          onFieldSubmitted: (value) {
            if (_debounce?.isActive ?? false) _debounce!.cancel();
            if (value.length >= 3) {
              _performCampaignSearch(value);
            } else {
              setState(() {
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
        if (_campaignSearchResults.isNotEmpty && _selectedCampaign == null)
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _campaignSearchResults.length,
              itemBuilder: (context, index) {
                final campaign = _campaignSearchResults[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: colorScheme.outline),
                      borderRadius: BorderRadius.circular(8),
                      color: colorScheme.surfaceContainer, // no background
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        setState(() {
                          _selectedCampaign = campaign;
                          _campaignSearchController.text = campaign.title;
                          _campaignSearchResults.clear();
                          _isSearchingCampaigns = false;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 10.0),
                        child: Row(
                          children: [
                            Icon(Icons.campaign,
                                size: 20, color: colorScheme.primary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    campaign.title,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurface,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Submitted: ${DateFormat("MMM dd, yyyy").format(campaign.submissionDate!)}",
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
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
      ],
    );
  }

  List<Widget> _buildCommonRequestInformationSection(
      BuildContext context, ColorScheme colorScheme) {
    return <Widget>[
      DropdownButtonFormField<CampaignRequestType>(
        decoration: InputDecoration(
          labelText: 'Request type',
          border: const OutlineInputBorder(),
          prefixIcon:
              Icon(Icons.rule_folder_outlined, color: colorScheme.primary),
        ),
        value: _campaignRequestType,
        hint: const Text('Select request type'),
        onChanged: (CampaignRequestType? newValue) {
          setState(() {
            _campaignRequestType = newValue!;
            _resetDynamicFields(); // Clear fields when type changes
          });
        },
        items: CampaignRequestType.values.map((type) {
          return DropdownMenuItem<CampaignRequestType>(
            value: type,
            child: Text(type.value),
          );
        }).toList(),
        validator: (value) =>
            value == null ? 'Please select a request type' : null,
      ),
      const SizedBox(height: 16),
      TextFormField(
        initialValue: _title,
        decoration: InputDecoration(
          labelText: 'Request Title',
          border: const OutlineInputBorder(),
          prefixIcon: Icon(Icons.title, color: colorScheme.primary),
          errorText: getServerError('title'),
        ),
        onChanged: (value) {
          _title = value;
          clearServerError('title');
        },
        validator: (value) {
          return validNonEmptyString(value, max: 100);
        },
      ),
      const SizedBox(height: 16),
      TextFormField(
        initialValue: _justification,
        decoration: InputDecoration(
          labelText: 'Justification',
          border: const OutlineInputBorder(),
          prefixIcon: Icon(Icons.notes, color: colorScheme.primary),
          errorText: getServerError('justification'),
        ),
        onChanged: (value) {
          _justification = value;
          clearServerError('justification');
        },
        maxLines: 3,
        validator: (value) {
          return validNonEmptyString(value);
        },
      ),
    ];
  }

  Widget _buildDynamicRequestFields(ColorScheme colorScheme) {
    switch (_campaignRequestType) {
      case CampaignRequestType.postUpdate:
        return Column(
          children: [
            // TODO: Fix the old post is displayed.
            TextFormField(
              initialValue:
                  _newCampaignPost?.title ?? 'Select a campaign first',
              decoration: InputDecoration(
                labelText: 'Post Title',
                border: const OutlineInputBorder(),
                prefixIcon:
                    Icon(Icons.subtitles_outlined, color: colorScheme.primary),
                errorText: getServerError('newPost.title'),
              ),
              onChanged: (value) {
                setState(() {
                  _newCampaignPost = (_newCampaignPost ??
                          CampaignPost(
                            campaignId: _selectedCampaign?.id ??
                                '', // Ensure campaignId is passed
                            title: '',
                            content: '',
                          ))
                      .copyWith(title: value);
                });
                clearServerError('newPost.title');
              },
              validator: (value) {
                return validNonEmptyString(value, max: 100);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue:
                  _newCampaignPost?.content ?? 'Select a campaign first',
              decoration: InputDecoration(
                labelText: 'Post Content',
                border: const OutlineInputBorder(),
                prefixIcon:
                    Icon(Icons.text_snippet, color: colorScheme.primary),
                errorText: getServerError('newPost.content'),
              ),
              onChanged: (value) {
                setState(() {
                  _newCampaignPost = (_newCampaignPost ??
                          CampaignPost(
                            campaignId: _selectedCampaign?.id ??
                                '', // Ensure campaignId is passed
                            title: '',
                            content: '',
                          ))
                      .copyWith(content: value);
                });
                clearServerError('newPost.content');
              },
              maxLines: 5,
              validator: (value) {
                return validNonEmptyString(value);
              },
            ),
          ],
        );
      case CampaignRequestType.statusChange:
        return Column(
          children: [
            TextFormField(
              initialValue:
                  _selectedCampaign?.status?.value ?? 'Select a campaign first',
              decoration: InputDecoration(
                labelText: 'Old Status',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.info,
                  color: Theme.of(context).disabledColor,
                ),
                hintText: _selectedCampaign?.status?.value ??
                    'Select a campaign first',
              ),
              readOnly: true,
              enabled: false,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<CampaignStatus>(
              value: _newStatus,
              decoration: InputDecoration(
                labelText: 'New Status',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(Icons.info, color: colorScheme.primary),
                errorText: getServerError('newStatus'),
              ),
              hint: _selectedCampaign != null
                  ? const Text('Select new status')
                  : const Text('Select a campaign first'),
              items: CampaignStatus.getValidStatusTransitions(
                _selectedCampaign?.status,
              ).map((CampaignStatus status) {
                return DropdownMenuItem<CampaignStatus>(
                  value: status,
                  child: Text(status.value),
                );
              }).toList(),
              onChanged: (CampaignStatus? newValue) {
                setState(() => _newStatus = newValue);
                clearServerError('newStatus');
              },
              validator: (value) {
                if (value == null) return 'Please select a new status';
                return null;
              },
            ),
          ],
        );
      case CampaignRequestType.goalAdjustment:
        return Column(
          children: [
            TextFormField(
              initialValue: _selectedCampaign?.fundraisingGoal ??
                  'Select a campaign first',
              decoration: InputDecoration(
                labelText: 'Old goal',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.track_changes_outlined,
                  color: Theme.of(context).disabledColor,
                ),
                suffixText: 'ETB',
                hintText: _selectedCampaign?.fundraisingGoal ??
                    'Select a campaign first',
              ),
              readOnly: true,
              enabled: false,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _newGoal,
              decoration: InputDecoration(
                labelText: 'New Goal Amount',
                border: const OutlineInputBorder(),
                suffixText: 'ETB',
                prefixIcon: Icon(Icons.track_changes_outlined,
                    color: colorScheme.primary),
                errorText: getServerError('newGoal'),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              onChanged: (value) {
                _newGoal = value;
                clearServerError('newGoal');
              },
              validator: (value) {
                return validMoneyAmount(value, AppConfig.maxMoneyAmount);
              },
            ),
          ],
        );
      case CampaignRequestType.endDateExtension:
        return Column(
          children: [
            TextFormField(
              initialValue: _selectedCampaign?.endDate != null
                  ? DateFormat("MMM dd, yyyy")
                      .format(_selectedCampaign!.endDate!)
                  : 'Select a campaign first',
              decoration: InputDecoration(
                labelText: 'Old end date',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.calendar_today_outlined,
                  color: Theme.of(context).disabledColor,
                ),
                hintText: _selectedCampaign?.endDate != null
                    ? DateFormat("MMM dd, yyyy")
                        .format(_selectedCampaign!.endDate!)
                    : 'Select a campaign first',
              ),
              readOnly: true,
              enabled: false,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _newEndDateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'New End Date',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today_outlined,
                    color: colorScheme.primary),
                errorText: getServerError('newEndDate'),
              ),
              onTap: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _newEndDateController.text.isNotEmpty
                      ? DateTime.parse(_newEndDateController.text)
                      : DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now().add(const Duration(days: 1)),
                  lastDate: DateTime(DateTime.now().year + 5),
                );
                if (pickedDate != null) {
                  setState(() {
                    _newEndDateController.text =
                        formatDate(pickedDate);
                  });
                  clearServerError('newEndDate');
                }
              },
              validator: (value) {
                return validDate(value, isPast: false);
              },
            ),
          ],
        );
    }
  }

  //****** Helper functions
  Future<void> _performCampaignSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _campaignSearchResults.clear();
        _isSearchingCampaigns = false;
      });
      return;
    }
    setState(() {
      _isSearchingCampaigns = true;
      _campaignSearchResults.clear();
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final accessToken = userProvider.credentials?.accessToken;

    if (accessToken == null) {
      if (mounted) {
        showErrorSnackBar(context, 'Authentication error for campaign search.');
      }
      setState(() => _isSearchingCampaigns = false);
      return;
    }

    final filter =
        CampaignFilter(title: query, ownerRecipientId: userProvider.user?.id);
    final campaignService = Provider.of<CampaignService>(
      context,
      listen: false,
    );
    final result = await campaignService.getCampaigns(filter, accessToken);

    if (!mounted) return;
    await handleServiceResponse(
      context,
      result,
      onSuccess: () {
        if (result.data != null) {
          setState(() {
            _campaignSearchResults.addAll(result.data!.toTypedList(
              (data) => Campaign.fromJson(data),
            ));
          });
        }
      },
      onValidationErrors: (errors) {
        debugPrint("[ERROR]: Error searching campaigns: $errors");
        if (mounted) {
          showErrorSnackBar(
            context,
            'Failed to search campaigns: ${errors['detail']?.first ?? 'Unknown error'}',
          );
        }
      },
    );

    setState(() => _isSearchingCampaigns = false);
  }

  void _onCampaignSearchTextChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final currentQuery = _campaignSearchController.text;
      if (currentQuery.isNotEmpty && currentQuery.isNotEmpty) {
        _performCampaignSearch(currentQuery);
      } else {
        setState(() {
          _campaignSearchResults.clear();
          _isSearchingCampaigns = false;
        });
      }
    });
  }

  Future<void> _submitCampaignRequest() async {
    setState(() {
      _isLoading = true;
      clearAllServerErrors();
    });

    if (!_formKey.currentState!.validate()) {
      setState(() => _isLoading = false);
      return;
    }
    _formKey.currentState!.save();

    if (_selectedCampaign?.id == null) {
      if (mounted) {
        showErrorSnackBar(context, 'A campaign must be selected.');
      }
      setState(() => _isLoading = false);
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final accessToken = userProvider.credentials?.accessToken;
    final ownerRecipientId = userProvider.user?.id;

    if (accessToken == null || ownerRecipientId == null) {
      if (mounted) {
        showErrorSnackBar(
          context,
          'Authentication error. Please log in again.',
        );
      }
      setState(() => _isLoading = false);
      return;
    }

    CampaignRequest newRequest;

    try {
      switch (_campaignRequestType) {
        case CampaignRequestType.endDateExtension:
          final endDateErrMsg = validDate(
            _newEndDateController.text,
            isPast: false,
          );

          if (endDateErrMsg != null) {
            if (mounted) showErrorSnackBar(context, endDateErrMsg);
            setState(() => _isLoading = false);
            return;
          }

          newRequest = EndDateExtensionRequest(
            campaignId: _selectedCampaign!.id!,
            ownerRecipientId: ownerRecipientId,
            title: _title!,
            justification: _justification!,
            newEndDate: DateTime.parse(_newEndDateController.text),
          );
          break;
        case CampaignRequestType.goalAdjustment:
          final newGoalErrMsg =
              validMoneyAmount(_newGoal, AppConfig.maxMoneyAmount);

          if (newGoalErrMsg != null) {
            if (mounted) showErrorSnackBar(context, newGoalErrMsg);
            setState(() => _isLoading = false);
            return;
          }

          newRequest = GoalAdjustmentRequest(
            campaignId: _selectedCampaign!.id!,
            ownerRecipientId: ownerRecipientId,
            title: _title!,
            justification: _justification!,
            newGoal: _newGoal!,
          );
          break;
        case CampaignRequestType.postUpdate:
          final campaignPostTitleErrMsg = validNonEmptyString(
            _newCampaignPost?.title,
            max: 100,
          );
          final campaignPostContentErrMsg = validNonEmptyString(
            _newCampaignPost?.content,
          );

          if (campaignPostContentErrMsg?.isNotEmpty ?? false) {
            if (mounted) showErrorSnackBar(context, campaignPostContentErrMsg!);
            setState(() => _isLoading = false);
            return;
          }

          if (campaignPostTitleErrMsg?.isNotEmpty ?? false) {
            if (mounted) showErrorSnackBar(context, campaignPostTitleErrMsg!);
            setState(() => _isLoading = false);
            return;
          }

          newRequest = PostUpdateRequest(
            campaignId: _selectedCampaign!.id!,
            ownerRecipientId: ownerRecipientId,
            title: _title!,
            justification: _justification!,
            newPost: _newCampaignPost!.copyWith(
              campaignId: _selectedCampaign!.id!,
            ),
          );
          break;
        case CampaignRequestType.statusChange:
          if (_newStatus == null) {
            if (mounted) {
              showErrorSnackBar(context, "Please select a new status");
            }
            setState(() => _isLoading = false);
            return;
          }

          newRequest = StatusChangeRequest(
            campaignId: _selectedCampaign!.id!,
            ownerRecipientId: ownerRecipientId,
            title: _title!,
            justification: _justification!,
            newStatus: _newStatus!,
          );
          break;
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, "Error preparing request: ${e.toString()}");
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final result = await Provider.of<CampaignRequestService>(
      context,
      listen: false,
    ).createCampaignRequest(newRequest, accessToken);

    if (!mounted) return;
    await handleServiceResponse(context, result, onSuccess: () async {
      clearAllServerErrors();

      if (!mounted) return;
      await showSuccessDialog(
        context,
        'Your campaign request has been submitted successfully!',
      );

      if (!mounted) return;
      Navigator.of(context).pop();
    }, onValidationErrors: (fieldErrors) {
      setState(() => setServerErrors(fieldErrors));
      _formKey.currentState?.validate();
    });

    setState(() => _isLoading = false);
  }

  void _resetCampaignRequestFields() {
    setState(() {
      _title = null;
      _justification = null;

      _resetDynamicFields();
      _campaignRequestType =
          CampaignRequestType.endDateExtension; // Set a default type

      _campaignSearchController.clear();
      _campaignSearchResults.clear();
      _selectedCampaign = null;
      _isSearchingCampaigns = false;
    });

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _formKey.currentState?.reset();
    clearAllServerErrors();
  }

  void _resetDynamicFields() {
    setState(() {
      _newCampaignPost = null;
      _newGoal = null;
      _newStatus = null;
      _newEndDateController.clear();
    });

    // Clear server errors associated with these fields if any
    clearServerError('newPost.title');
    clearServerError('newPost.content');
    clearServerError('newGoal');
    clearServerError('newStatus');
    clearServerError('newEndDate');
  }
}
