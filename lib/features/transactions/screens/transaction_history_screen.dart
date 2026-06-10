import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../shared/models/transaction_model.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/transaction_tile.dart';

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends ConsumerState<TransactionHistoryScreen> {
  String _searchQuery = '';
  int _selectedFilter = 0;
  DateTimeRange? _dateRange;
  String _dateFilterLabel = 'All Time';

  Future<void> _selectDateRange(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      initialDateRange: _dateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: AppColors.primary,
                    onPrimary: Colors.white,
                    surface: Color(0xFF121212),
                    onSurface: Colors.white,
                  )
                : const ColorScheme.light(
                    primary: AppColors.primary,
                    onPrimary: Colors.white,
                  ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateRange = picked;
        _dateFilterLabel = '${_formatDate(picked.start)} - ${_formatDate(picked.end)}';
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showFilterOptions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF121212) : AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter by Date',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _DateFilterOption(
                label: 'Today',
                isDark: isDark,
                onTap: () {
                  final now = DateTime.now();
                  final today = DateTime(now.year, now.month, now.day);
                  setState(() {
                    _dateRange = DateTimeRange(start: today, end: now);
                    _dateFilterLabel = 'Today';
                  });
                  Navigator.pop(context);
                },
              ),
              _DateFilterOption(
                label: 'This Week',
                isDark: isDark,
                onTap: () {
                  final now = DateTime.now();
                  final weekAgo = now.subtract(const Duration(days: 7));
                  setState(() {
                    _dateRange = DateTimeRange(start: weekAgo, end: now);
                    _dateFilterLabel = 'This Week';
                  });
                  Navigator.pop(context);
                },
              ),
              _DateFilterOption(
                label: 'This Month',
                isDark: isDark,
                onTap: () {
                  final now = DateTime.now();
                  final monthAgo = DateTime(now.year, now.month - 1, now.day);
                  setState(() {
                    _dateRange = DateTimeRange(start: monthAgo, end: now);
                    _dateFilterLabel = 'This Month';
                  });
                  Navigator.pop(context);
                },
              ),
              _DateFilterOption(
                label: 'Last 3 Months',
                isDark: isDark,
                onTap: () {
                  final now = DateTime.now();
                  final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
                  setState(() {
                    _dateRange = DateTimeRange(start: threeMonthsAgo, end: now);
                    _dateFilterLabel = 'Last 3 Months';
                  });
                  Navigator.pop(context);
                },
              ),
              _DateFilterOption(
                label: 'Custom Range',
                isDark: isDark,
                icon: Icons.date_range_rounded,
                onTap: () {
                  Navigator.pop(context);
                  _selectDateRange(context);
                },
              ),
              const SizedBox(height: 8),
              if (_dateRange != null)
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _dateRange = null;
                        _dateFilterLabel = 'All Time';
                      });
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Clear Filter',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<String> filters = [
      context.loc('all'),
      context.loc('sent'),
      context.loc('received'),
      context.loc('payments'),
    ];
    
    // Filter logic
    final filteredTransactions = transactions.where((tx) {
      // Search filter
      if (_searchQuery.isNotEmpty && !tx.title.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      // Type filter
      if (_selectedFilter == 1 && (tx.isCredit || tx.type == TransactionType.receive)) return false;
      if (_selectedFilter == 2 && !tx.isCredit) return false;
      if (_selectedFilter == 3 && tx.type != TransactionType.payment) return false;
      
      // Date filter
      if (_dateRange != null) {
        final txDate = tx.date;
        if (txDate.isBefore(_dateRange!.start) || txDate.isAfter(_dateRange!.end)) {
          return false;
        }
      }
      
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? Colors.black : AppColors.background,
      appBar: AppBar(
        title: Text(context.loc('transaction_history')),
        backgroundColor: isDark ? Colors.black : AppColors.background,
        iconTheme: IconThemeData(color: isDark ? Colors.white : AppColors.textPrimary),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list_rounded, color: isDark ? Colors.white : AppColors.textPrimary),
            onPressed: () => _showFilterOptions(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: context.loc('search_transactions'),
                hintStyle: TextStyle(color: isDark ? Colors.white38 : AppColors.textHint),
                prefixIcon: Icon(Icons.search_rounded, color: isDark ? Colors.white38 : AppColors.textHint),
                filled: true,
                fillColor: isDark ? const Color(0xFF121212) : AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ).animate().fadeIn().slideY(begin: -0.1),
          ),
          
          // Date filter chip
          if (_dateRange != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          _dateFilterLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => setState(() {
                            _dateRange = null;
                            _dateFilterLabel = 'All Time';
                          }),
                          child: Icon(Icons.close_rounded, size: 16, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideX(begin: -0.1),
                ],
              ),
            ),
          
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: filters.length,
              itemBuilder: (context, i) {
                final isSelected = _selectedFilter == i;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(
                      filters[i],
                      style: TextStyle(
                        color: isSelected 
                            ? (isDark ? Colors.black : Colors.white) 
                            : (isDark ? Colors.white70 : AppColors.textPrimary),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (v) => setState(() => _selectedFilter = i),
                    backgroundColor: isDark ? const Color(0xFF1E1E1E) : AppColors.surfaceVariant,
                    selectedColor: isDark ? Colors.white : AppColors.primary,
                    checkmarkColor: isDark ? Colors.black : Colors.white,
                    side: isDark ? BorderSide(color: isSelected ? Colors.white : const Color(0xFF2D2D2D)) : null,
                  ),
                ).animate().fadeIn(delay: Duration(milliseconds: 100 + (i * 50)));
              },
            ),
          ),
          
          Expanded(
            child: filteredTransactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_rounded,
                          size: 64,
                          color: isDark ? Colors.white24 : AppColors.textHint.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          context.loc('no_transactions_found'),
                          style: TextStyle(
                            color: isDark ? Colors.white60 : AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: filteredTransactions.length,
                    itemBuilder: (context, i) {
                      return TransactionTile(
                        transaction: filteredTransactions[i],
                        onTap: () => context.push('/transaction-detail', extra: filteredTransactions[i]),
                      ).animate().fadeIn(delay: Duration(milliseconds: 200 + (i * 50))).slideY(begin: 0.1);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _DateFilterOption extends StatelessWidget {
  final String label;
  final bool isDark;
  final IconData? icon;
  final VoidCallback onTap;

  const _DateFilterOption({
    required this.label,
    required this.isDark,
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon ?? Icons.calendar_today_rounded,
        color: isDark ? Colors.white70 : AppColors.textPrimary,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isDark ? Colors.white : AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}