import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:toastification/toastification.dart';
import '../providers/signin_provider.dart';
import 'history_screen.dart';
import 'dart:math';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  void _previousMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
    });
  }

  Color _getColorForCount(int count, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (count == 0) {
      return isDark ? Colors.grey[800]! : Colors.grey.withOpacity(0.2);
    }

    final primary = Theme.of(context).primaryColor;
    if (count <= 1)
      return isDark ? primary.withOpacity(0.5) : primary.withOpacity(0.3);
    if (count <= 3)
      return isDark ? primary.withOpacity(0.7) : primary.withOpacity(0.6);
    return primary;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SignInProvider>();
    final daysInMonth = DateUtils.getDaysInMonth(
      _focusedDay.year,
      _focusedDay.month,
    );
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;
    final offset = firstWeekday - 1;

    final selectedDate = _selectedDay ?? DateTime.now();
    final dayRecords = provider.getSignInsForDay(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('总览'),
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Month Navigation
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _previousMonth,
                ),
                Text(
                  DateFormat.yMMMM('zh_CN').format(_focusedDay),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _nextMonth,
                ),
              ],
            ),
          ),

          // Heatmap Grid
          Builder(
            builder: (context) {
              // Calculate number of weeks needed
              final totalCells = daysInMonth + offset;
              final weeksNeeded = (totalCells / 7).ceil();
              final cellSize = 50.0;
              final spacing = 4.0;
              final bottomPadding = 24.0;
              final gridHeight =
                  (weeksNeeded * cellSize) +
                  ((weeksNeeded - 1) * spacing) +
                  bottomPadding;

              return SizedBox(
                height: gridHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                        ),
                    itemCount: daysInMonth + offset,
                    itemBuilder: (context, index) {
                      if (index < offset) {
                        return const SizedBox();
                      }
                      final day = index - offset + 1;
                      final currentDate = DateTime(
                        _focusedDay.year,
                        _focusedDay.month,
                        day,
                      );
                      final count = provider.getCountForDay(currentDate);

                      final isSelected =
                          _selectedDay != null &&
                          currentDate.year == _selectedDay!.year &&
                          currentDate.month == _selectedDay!.month &&
                          currentDate.day == _selectedDay!.day;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDay = currentDate;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: _getColorForCount(count, context),
                            borderRadius: BorderRadius.circular(4),
                            border: isSelected
                                ? Border.all(color: Colors.blueAccent, width: 2)
                                : Border.all(
                                    color:
                                        DateTime.now().year ==
                                                currentDate.year &&
                                            DateTime.now().month ==
                                                currentDate.month &&
                                            DateTime.now().day ==
                                                currentDate.day
                                        ? Theme.of(context).primaryColor
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$day',
                                style: TextStyle(
                                  color: count > 2
                                      ? Colors.white
                                      : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (count > 0)
                                Text(
                                  '$count',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: count > 2
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),

          // Selected Day Details
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Text(
              DateFormat.yMMMMd('zh_CN').format(selectedDate),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),

          Expanded(
            child: dayRecords.isEmpty
                ? const Center(child: Text('暂无签到记录'))
                : ListView.separated(
                    itemCount: dayRecords.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final record = dayRecords[index];
                      // Generate a random color for the dot, or use a consistent one
                      final color = Colors
                          .primaries[Random().nextInt(Colors.primaries.length)];

                      return Dismissible(
                        key: ValueKey(record),
                        direction: DismissDirection.startToEnd,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          provider.deleteSignIn(record);
                          toastification.show(
                            context: context,
                            title: const Text('记录已删除'),
                            type: ToastificationType.info,
                            autoCloseDuration: const Duration(seconds: 2),
                            alignment: Alignment.bottomCenter,
                          );
                        },
                        child: ListTile(
                          leading: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          title: Text(DateFormat('HH:mm').format(record)),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
