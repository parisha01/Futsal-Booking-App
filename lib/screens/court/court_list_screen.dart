import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/court.dart';
import '../../widgets/court_card.dart';
import 'court_details_screen.dart';
import '../booking/booking_screen.dart';
import 'rankings_screen.dart';
import 'compare_screen.dart';

enum _SortOption { priceLowHigh, priceHighLow, ratingHighest }
enum _TimeOfDay { morning, afternoon, evening }

extension on _TimeOfDay {
  String get label {
    switch (this) {
      case _TimeOfDay.morning:
        return 'Morning';
      case _TimeOfDay.afternoon:
        return 'Afternoon';
      case _TimeOfDay.evening:
        return 'Evening';
    }
  }
}

/// Displays search/filtered results as a scrollable list. Supports the
/// full "search and filter courts by location, price, and time"
/// functional requirement: a text search, a Filter sheet (price range +
/// time of day + location), and a Sort dropdown — the sort interaction
/// was the one added to the Figma prototype after Priya's user-testing
/// feedback that the filter looked tappable but did nothing.
class CourtListScreen extends StatefulWidget {
  const CourtListScreen({super.key});

  @override
  State<CourtListScreen> createState() => _CourtListScreenState();
}

class _CourtListScreenState extends State<CourtListScreen> {
  final _searchController = TextEditingController();
  _SortOption _sort = _SortOption.priceLowHigh;
  String _query = '';

  RangeValues _priceRange = const RangeValues(0, 50);
  final Set<_TimeOfDay> _selectedTimes = {};
  final Set<String> _selectedLocations = {};

  bool _compareMode = false;
  final Set<String> _selectedForCompare = {};

  List<String> get _allLocations => CourtRepository.courts
      .map((c) => c.location.split(',').first.trim())
      .toSet()
      .toList();

  _TimeOfDay _categorize(String slot) {
    final isPm = slot.toLowerCase().contains('pm');
    final hourStr = slot.split(':').first;
    var hour = int.tryParse(hourStr) ?? 12;
    if (isPm && hour != 12) hour += 12;
    if (hour < 12) return _TimeOfDay.morning;
    if (hour < 17) return _TimeOfDay.afternoon;
    return _TimeOfDay.evening;
  }

  bool get _hasActiveFilters =>
      _priceRange.start > 0 ||
      _priceRange.end < 50 ||
      _selectedTimes.isNotEmpty ||
      _selectedLocations.isNotEmpty;

  int get _activeFilterCount =>
      (_priceRange.start > 0 || _priceRange.end < 50 ? 1 : 0) +
      (_selectedTimes.isNotEmpty ? 1 : 0) +
      (_selectedLocations.isNotEmpty ? 1 : 0);

  List<Court> get _filteredSorted {
    var list = CourtRepository.courts.where((c) {
      final matchesQuery = c.name.toLowerCase().contains(_query.toLowerCase());
      final matchesPrice = c.pricePerHour >= _priceRange.start && c.pricePerHour <= _priceRange.end;
      final matchesTime = _selectedTimes.isEmpty ||
          c.availableSlots.any((s) => _selectedTimes.contains(_categorize(s)));
      final matchesLocation = _selectedLocations.isEmpty ||
          _selectedLocations.contains(c.location.split(',').first.trim());
      return matchesQuery && matchesPrice && matchesTime && matchesLocation;
    }).toList();

    switch (_sort) {
      case _SortOption.priceLowHigh:
        list.sort((a, b) => a.pricePerHour.compareTo(b.pricePerHour));
        break;
      case _SortOption.priceHighLow:
        list.sort((a, b) => b.pricePerHour.compareTo(a.pricePerHour));
        break;
      case _SortOption.ratingHighest:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }
    return list;
  }

  void _openSortMenu() async {
    final selected = await showModalBottomSheet<_SortOption>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 12),
            _sortTile('Price: Low to High', _SortOption.priceLowHigh),
            _sortTile('Price: High to Low', _SortOption.priceHighLow),
            _sortTile('Rating: Highest first', _SortOption.ratingHighest),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (selected != null) setState(() => _sort = selected);
  }

  Widget _sortTile(String label, _SortOption option) {
    final selected = option == _sort;
    return ListTile(
      title: Text(label,
          style: TextStyle(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            color: selected ? AppColors.primary : AppColors.textPrimary,
          )),
      trailing: selected ? const Icon(Icons.check_rounded, color: AppColors.primary) : null,
      onTap: () => Navigator.pop(context, option),
    );
  }

  void _openFilterSheet() async {
    RangeValues tempRange = _priceRange;
    Set<_TimeOfDay> tempTimes = {..._selectedTimes};
    Set<String> tempLocations = {..._selectedLocations};

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  top: AppSpacing.md,
                  bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                                color: AppColors.border, borderRadius: BorderRadius.circular(2))),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Filters', style: Theme.of(context).textTheme.titleLarge),
                          TextButton(
                            onPressed: () => setModalState(() {
                              tempRange = const RangeValues(0, 50);
                              tempTimes.clear();
                              tempLocations.clear();
                            }),
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Price per hour', style: Theme.of(context).textTheme.titleMedium),
                      Text(
                        '\$${tempRange.start.round()} - \$${tempRange.end.round()}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      RangeSlider(
                        min: 0,
                        max: 50,
                        divisions: 10,
                        activeColor: AppColors.primary,
                        inactiveColor: AppColors.border,
                        values: tempRange,
                        labels: RangeLabels(
                          '\$${tempRange.start.round()}',
                          '\$${tempRange.end.round()}',
                        ),
                        onChanged: (v) => setModalState(() => tempRange = v),
                      ),
                      const SizedBox(height: 12),
                      Text('Time of day', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: _TimeOfDay.values.map((t) {
                          final selected = tempTimes.contains(t);
                          return FilterChip(
                            label: Text(t.label),
                            selected: selected,
                            onSelected: (_) => setModalState(() {
                              selected ? tempTimes.remove(t) : tempTimes.add(t);
                            }),
                            selectedColor: AppColors.primaryLight,
                            checkmarkColor: AppColors.primaryDark,
                            labelStyle: TextStyle(
                              color: selected ? AppColors.primaryDark : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      Text('Location', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _allLocations.map((loc) {
                          final selected = tempLocations.contains(loc);
                          return FilterChip(
                            label: Text(loc),
                            selected: selected,
                            onSelected: (_) => setModalState(() {
                              selected ? tempLocations.remove(loc) : tempLocations.add(loc);
                            }),
                            selectedColor: AppColors.primaryLight,
                            checkmarkColor: AppColors.primaryDark,
                            labelStyle: TextStyle(
                              color: selected ? AppColors.primaryDark : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _priceRange = tempRange;
                            _selectedTimes
                              ..clear()
                              ..addAll(tempTimes);
                            _selectedLocations
                              ..clear()
                              ..addAll(tempLocations);
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Apply filters'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final courts = _filteredSorted;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Court list'),
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard_rounded),
            tooltip: 'Rankings',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RankingsScreen()),
            ),
          ),
          IconButton(
            icon: Icon(_compareMode ? Icons.close_rounded : Icons.compare_arrows_rounded),
            tooltip: _compareMode ? 'Cancel compare' : 'Compare venues',
            onPressed: () => setState(() {
              _compareMode = !_compareMode;
              _selectedForCompare.clear();
            }),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: const InputDecoration(
                      hintText: 'Search courts...',
                      prefixIcon: Icon(Icons.search_rounded, color: AppColors.textMuted),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _openFilterSheet,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                          decoration: BoxDecoration(
                            color: _hasActiveFilters ? AppColors.primaryLight : AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            border: Border.all(
                                color: _hasActiveFilters ? AppColors.primary : AppColors.border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.tune_rounded,
                                  size: 16,
                                  color: _hasActiveFilters ? AppColors.primaryDark : AppColors.textPrimary),
                              const SizedBox(width: 4),
                              Text('Filter${_hasActiveFilters ? ' ($_activeFilterCount)' : ''}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: _hasActiveFilters ? AppColors.primaryDark : AppColors.textPrimary,
                                  )),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _openSortMenu,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text('Sort', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                              SizedBox(width: 4),
                              Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text('${courts.length} found', style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                  if (_compareMode) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        'Select 2-3 courts to compare (${_selectedForCompare.length} selected)',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: courts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.search_off_rounded, size: 44, color: AppColors.textMuted),
                          const SizedBox(height: 10),
                          Text('No courts match your filters',
                              style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    )
                  : ListView(
                      padding: EdgeInsets.fromLTRB(
                          AppSpacing.lg, 0, AppSpacing.lg, _compareMode ? 90 : AppSpacing.lg),
                      children: courts.map((c) {
                        final card = CourtCard(
                          court: c,
                          onTap: _compareMode
                              ? () => setState(() {
                                    if (_selectedForCompare.contains(c.id)) {
                                      _selectedForCompare.remove(c.id);
                                    } else if (_selectedForCompare.length < 3) {
                                      _selectedForCompare.add(c.id);
                                    }
                                  })
                              : () => Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => CourtDetailsScreen(court: c)),
                                  ),
                          onBookNow: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => BookingScreen(court: c)),
                          ),
                        );
                        if (!_compareMode) return card;
                        final selected = _selectedForCompare.contains(c.id);
                        return Stack(
                          children: [
                            Opacity(opacity: selected ? 1 : 0.7, child: card),
                            Positioned(
                              top: 10,
                              left: 10,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: selected ? AppColors.primary : Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.primary, width: 2),
                                ),
                                padding: const EdgeInsets.all(3),
                                child: Icon(
                                  selected ? Icons.check_rounded : Icons.circle_outlined,
                                  size: 16,
                                  color: selected ? Colors.white : AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
      bottomSheet: (_compareMode && _selectedForCompare.length >= 2)
          ? Container(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 12, AppSpacing.lg, 20),
              decoration: BoxDecoration(
                color: AppColors.background,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, -3))],
              ),
              child: ElevatedButton(
                onPressed: () {
                  final selectedCourts = CourtRepository.courts
                      .where((c) => _selectedForCompare.contains(c.id))
                      .toList();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => CompareScreen(courts: selectedCourts)),
                  );
                },
                child: Text('Compare ${_selectedForCompare.length} courts'),
              ),
            )
          : null,
    );
  }
}
