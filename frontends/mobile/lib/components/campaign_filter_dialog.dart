import 'package:flutter/material.dart';
import 'package:mobile/models/campaign.dart';
import 'package:mobile/models/server/filters.dart';

class CampaignFilterDialog extends StatefulWidget {
  final CampaignFilter currentFilters;
  final bool showSensitiveFields;

  const CampaignFilterDialog({
    super.key,
    required this.currentFilters,
    this.showSensitiveFields = false,
  });

  @override
  State<CampaignFilterDialog> createState() => _CampaignFilterDialogState();
}

class _CampaignFilterDialogState extends State<CampaignFilterDialog> {
  late String? _selectedCategory;
  late CampaignStatus? _selectedStatus;
  late DateTime? _minLaunchDate;
  late DateTime? _maxLaunchDate;
  late DateTime? _minSubmissionDate;
  late DateTime? _maxSubmissionDate;
  late DateTime? _minVerificationDate;
  late DateTime? _maxVerificationDate;
  late DateTime? _minDenialDate;
  late DateTime? _maxDenialDate;
  late bool _isPublic;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.currentFilters.category;
    _selectedStatus = widget.currentFilters.status;
    _minLaunchDate = widget.currentFilters.minLaunchDate;
    _maxLaunchDate = widget.currentFilters.maxLaunchDate;
    _minSubmissionDate = widget.currentFilters.minSubmissionDate;
    _maxSubmissionDate = widget.currentFilters.maxSubmissionDate;
    _minVerificationDate = widget.currentFilters.minVerificationDate;
    _maxVerificationDate = widget.currentFilters.maxVerificationDate;
    _minDenialDate = widget.currentFilters.minDenialDate;
    _maxDenialDate = widget.currentFilters.maxDenialDate;
    _isPublic = widget.currentFilters.isPublic ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

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
                'Filter Campaigns',
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
                      if (widget.showSensitiveFields)
                        _buildFilterCard(
                          colorScheme: colorScheme,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: SwitchListTile(
                            title: Text('Only Public Campaigns',
                                style: TextStyle(color: colorScheme.onSurface)),
                            value: _isPublic,
                            onChanged: (val) => setState(() => _isPublic = val),
                            activeColor: colorScheme.primary,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      const SizedBox(height: 12),
                      _buildFilterCard(
                        colorScheme: colorScheme,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Type and Status',
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
                                _buildDropdown<String>(
                                  label: 'Category',
                                  value: _selectedCategory,
                                  items: CampaignCategories.values
                                      .map((e) => e.value)
                                      .toList(),
                                  onChanged: (val) =>
                                      setState(() => _selectedCategory = val),
                                  colorScheme: colorScheme,
                                ),
                                _buildDropdown<CampaignStatus>(
                                  label: 'Status',
                                  value: _selectedStatus,
                                  items: CampaignStatus.values,
                                  getItemLabel: (e) => e.value,
                                  onChanged: (val) =>
                                      setState(() => _selectedStatus = val),
                                  colorScheme: colorScheme,
                                ),
                              ],
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
                            Text('Launch Dates',
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
                                    _minLaunchDate,
                                    (date) =>
                                        setState(() => _minLaunchDate = date),
                                    colorScheme),
                                _buildDatePicker(
                                    'Max',
                                    _maxLaunchDate,
                                    (date) =>
                                        setState(() => _maxLaunchDate = date),
                                    colorScheme),
                              ],
                            ),
                            if (widget.showSensitiveFields) ...[
                              const SizedBox(height: 16),
                              Text('Submission Dates',
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
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
                                      _minSubmissionDate,
                                      (date) => setState(
                                          () => _minSubmissionDate = date),
                                      colorScheme),
                                  _buildDatePicker(
                                      'Max',
                                      _maxSubmissionDate,
                                      (date) => setState(
                                          () => _maxSubmissionDate = date),
                                      colorScheme),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text('Verification Dates',
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
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
                                      _minVerificationDate,
                                      (date) => setState(
                                          () => _minVerificationDate = date),
                                      colorScheme),
                                  _buildDatePicker(
                                      'Max',
                                      _maxVerificationDate,
                                      (date) => setState(
                                          () => _maxVerificationDate = date),
                                      colorScheme),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text('Denial Dates',
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
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
                                      _minDenialDate,
                                      (date) =>
                                          setState(() => _minDenialDate = date),
                                      colorScheme),
                                  _buildDatePicker(
                                      'Max',
                                      _maxDenialDate,
                                      (date) =>
                                          setState(() => _maxDenialDate = date),
                                      colorScheme),
                                ],
                              ),
                            ],
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
                            _selectedCategory = null;
                            _selectedStatus = null;
                            _minLaunchDate = null;
                            _maxLaunchDate = null;
                            _minSubmissionDate = null;
                            _maxSubmissionDate = null;
                            _minVerificationDate = null;
                            _maxVerificationDate = null;
                            _minDenialDate = null;
                            _maxDenialDate = null;
                            _isPublic = false;
                          });
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          foregroundColor:
                              colorScheme.onSurface.withValues(alpha: 0.6),
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
                            category: _selectedCategory,
                            status: _selectedStatus,
                            minLaunchDate: _minLaunchDate,
                            maxLaunchDate: _maxLaunchDate,
                            minSubmissionDate: _minSubmissionDate,
                            maxSubmissionDate: _maxSubmissionDate,
                            minVerificationDate: _minVerificationDate,
                            maxVerificationDate: _maxVerificationDate,
                            minDenialDate: _minDenialDate,
                            maxDenialDate: _maxDenialDate,
                            isPublic: _isPublic,
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

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Not set';
    }
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year.toString()}';
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
        labelStyle:
            TextStyle(color: colorScheme.onSurface.withValues(alpha: .7)),
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
      selectedItemBuilder: (context) {
        return items
            .map((e) => Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    getItemLabel?.call(e) ?? e.toString(),
                    style: TextStyle(color: colorScheme.onSurface),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ))
            .toList();
      },
    );
  }

  Widget _buildDatePicker(String label, DateTime? selectedDate,
      void Function(DateTime?) onPicked, ColorScheme colorScheme) {
    return InkWell(
      onTap: () async {
        final picked = await _selectDate(context, selectedDate, colorScheme);
        if (picked != null) onPicked(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              TextStyle(color: colorScheme.onSurface.withValues(alpha: .7)),
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
                  ? colorScheme.onSurface.withValues(alpha: .6)
                  : colorScheme.onSurface),
        ),
      ),
    );
  }

  Future<DateTime?> _selectDate(BuildContext context, DateTime? initialDate,
      ColorScheme colorScheme) async {
    return await showDatePicker(
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
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
  }

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
}
