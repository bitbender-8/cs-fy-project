import 'package:flutter/material.dart';
import 'package:mobile/models/campaign_request.dart';
import 'package:mobile/models/server/filters.dart';
import 'package:mobile/services/providers.dart';
import 'package:provider/provider.dart';

class CampaignRequestFilterDialog extends StatefulWidget {
  final CampaignRequestFilter currentFilters;

  const CampaignRequestFilterDialog({
    super.key,
    required this.currentFilters,
  });

  @override
  State<CampaignRequestFilterDialog> createState() =>
      _CampaignRequestFilterDialogState();
}

class _CampaignRequestFilterDialogState
    extends State<CampaignRequestFilterDialog> {
  late CampaignRequestType? _campaignRequestType;
  late bool? _isResolved;
  late ResolutionType? _resolutionType;
  late DateTime? _minRequestDate;
  late DateTime? _maxRequestDate;
  late DateTime? _minResolutionDate;
  late DateTime? _maxResolutionDate;
  late String? _title;

  @override
  void initState() {
    super.initState();
    _campaignRequestType = widget.currentFilters.campaignRequestType;
    _isResolved = widget.currentFilters.isResolved;
    _resolutionType = widget.currentFilters.resolutionType;
    _minRequestDate = widget.currentFilters.minRequestDate;
    _maxRequestDate = widget.currentFilters.maxRequestDate;
    _minResolutionDate = widget.currentFilters.minResolutionDate;
    _maxResolutionDate = widget.currentFilters.maxResolutionDate;
    _title = widget.currentFilters.title;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final ownerRecipientId = userProvider.user!.id;

    return Dialog(
      insetPadding: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 650),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Filter Campaign Requests',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      _buildFilterCard(
                        colorScheme: colorScheme,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Type and Resolution',
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 12),
                            GridView.count(
                              shrinkWrap: true,
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 2.2,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                _buildDropdown<CampaignRequestType>(
                                  label: 'Request Type',
                                  value: _campaignRequestType,
                                  items: CampaignRequestType.values,
                                  getItemLabel: (e) => e.value,
                                  onChanged: (val) => setState(
                                      () => _campaignRequestType = val),
                                  colorScheme: colorScheme,
                                ),
                                _buildDropdown<ResolutionType>(
                                  label: 'Resolution Type',
                                  value: _resolutionType,
                                  items: ResolutionType.values,
                                  getItemLabel: (e) => e.value,
                                  onChanged: (val) =>
                                      setState(() => _resolutionType = val),
                                  colorScheme: colorScheme,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildDropdown<bool>(
                              label: 'Resolved',
                              value: _isResolved,
                              items: [true, false],
                              getItemLabel: (e) => e ? 'Yes' : 'No',
                              onChanged: (val) =>
                                  setState(() => _isResolved = val),
                              colorScheme: colorScheme,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildFilterCard(
                        colorScheme: colorScheme,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Request Dates',
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            GridView.count(
                              shrinkWrap: true,
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 2.2,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                _buildDatePicker(
                                    'Min',
                                    _minRequestDate,
                                    (date) =>
                                        setState(() => _minRequestDate = date),
                                    colorScheme),
                                _buildDatePicker(
                                    'Max',
                                    _maxRequestDate,
                                    (date) =>
                                        setState(() => _maxRequestDate = date),
                                    colorScheme),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text('Resolution Dates',
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            GridView.count(
                              shrinkWrap: true,
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 2.2,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                _buildDatePicker(
                                    'Min',
                                    _minResolutionDate,
                                    (date) => setState(
                                        () => _minResolutionDate = date),
                                    colorScheme),
                                _buildDatePicker(
                                    'Max',
                                    _maxResolutionDate,
                                    (date) => setState(
                                        () => _maxResolutionDate = date),
                                    colorScheme),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: colorScheme.error),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text('Cancel',
                            style: TextStyle(color: colorScheme.error)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _campaignRequestType = null;
                            _isResolved = null;
                            _resolutionType = null;
                            _minRequestDate = null;
                            _maxRequestDate = null;
                            _minResolutionDate = null;
                            _maxResolutionDate = null;
                            _title = null;
                          });
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          foregroundColor: colorScheme.onSurface.withAlpha(150),
                          side: BorderSide(color: colorScheme.scrim),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Reset'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ElevatedButton(
                        onPressed: () {
                          final updatedFilters = widget.currentFilters.copyWith(
                            ownerRecipientId: ownerRecipientId,
                            campaignRequestType: _campaignRequestType,
                            isResolved: _isResolved,
                            resolutionType: _resolutionType,
                            minRequestDate: _minRequestDate,
                            maxRequestDate: _maxRequestDate,
                            minResolutionDate: _minResolutionDate,
                            maxResolutionDate: _maxResolutionDate,
                            title: _title,
                          );
                          Navigator.of(context).pop(updatedFilters);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Apply'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  //****** Page sub-components
  Widget _buildFilterCard({
    required Widget child,
    required ColorScheme colorScheme,
    EdgeInsetsGeometry padding =
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline, width: 1.0),
      ),
      child: child,
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required void Function(T?) onChanged,
    String Function(T)? getItemLabel,
    required ColorScheme colorScheme,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: colorScheme.onSurface.withAlpha(180)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
      isExpanded: true,
      items: items.map((e) {
        return DropdownMenuItem<T>(
          value: e,
          child: Text(
            getItemLabel?.call(e) ?? e.toString(),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDatePicker(
    String label,
    DateTime? selectedDate,
    void Function(DateTime?) onPicked,
    ColorScheme colorScheme,
  ) {
    return InkWell(
      onTap: () async {
        final picked = await _selectDate(context, selectedDate, colorScheme);
        if (picked != null) onPicked(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: colorScheme.onSurface.withAlpha(180)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
          suffixIcon: Icon(Icons.calendar_today, color: colorScheme.primary),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        ),
        child: Text(
          _formatDate(selectedDate),
          style: TextStyle(
            color: selectedDate == null
                ? colorScheme.onSurface.withAlpha(140)
                : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  //****** Helper functions
  String _formatDate(DateTime? date) {
    if (date == null) return 'Not set';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<DateTime?> _selectDate(
      BuildContext context, DateTime? initialDate, ColorScheme colorScheme) {
    return showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: colorScheme.primary,
              onPrimary: colorScheme.onPrimary,
              surface: colorScheme.surface,
              onSurface: colorScheme.onSurface,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
