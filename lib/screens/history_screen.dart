import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/signin_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _selectedYear = DateTime.now().year;
  int _touchedIndexH1 = -1;
  int _touchedIndexH2 = -1;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SignInProvider>();
    final stats = provider.getYearlyStats(_selectedYear);
    final currentYear = DateTime.now().year;

    return Scaffold(
      appBar: AppBar(title: const Text('历史统计')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Year Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_selectedYear > 2025)
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {
                      setState(() {
                        _selectedYear--;
                      });
                    },
                  )
                else
                  const SizedBox(width: 48),

                Text(
                  '$_selectedYear',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                if (_selectedYear < currentYear)
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                      setState(() {
                        _selectedYear++;
                      });
                    },
                  )
                else
                  const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 20),

            _buildPieChartSection(
              title: '上半年',
              stats: stats,
              startMonth: 1,
              endMonth: 6,
              touchedIndex: _touchedIndexH1,
              onTouch: (index) => setState(() => _touchedIndexH1 = index),
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),

            _buildPieChartSection(
              title: '下半年',
              stats: stats,
              startMonth: 7,
              endMonth: 12,
              touchedIndex: _touchedIndexH2,
              onTouch: (index) => setState(() => _touchedIndexH2 = index),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChartSection({
    required String title,
    required Map<int, int> stats,
    required int startMonth,
    required int endMonth,
    required int touchedIndex,
    required Function(int) onTouch,
  }) {
    bool hasData = false;
    for (int i = startMonth; i <= endMonth; i++) {
      if ((stats[i] ?? 0) > 0) {
        hasData = true;
        break;
      }
    }

    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 250,
          child: hasData
              ? PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          onTouch(-1);
                          return;
                        }
                        onTouch(
                          pieTouchResponse.touchedSection!.touchedSectionIndex,
                        );
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 0,
                    centerSpaceRadius: 40,
                    sections: _generateSections(
                      stats,
                      startMonth,
                      endMonth,
                      touchedIndex,
                    ),
                  ),
                )
              : const Center(
                  child: Text('暂无数据', style: TextStyle(color: Colors.grey)),
                ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _generateSections(
    Map<int, int> stats,
    int startMonth,
    int endMonth,
    int touchedIndex,
  ) {
    final List<PieChartSectionData> sections = [];

    final List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];

    int sectionIndex = 0;
    for (int i = startMonth; i <= endMonth; i++) {
      final count = stats[i] ?? 0;
      if (count > 0) {
        final isTouched = sectionIndex == touchedIndex;
        final radius = isTouched ? 60.0 : 50.0;
        final monthName = _getMonthName(i);

        sections.add(
          PieChartSectionData(
            color: colors[sectionIndex % colors.length],
            value: count.toDouble(),
            title: '', // Use badgeWidget instead
            radius: radius,
            badgeWidget: _buildBadge(monthName, count),
            badgePositionPercentageOffset: .98,
          ),
        );
        sectionIndex++;
      }
    }
    return sections;
  }

  Widget _buildBadge(String monthName, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$monthName ',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: '$count次',
              style: const TextStyle(
                color: Colors.amberAccent,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    return '$month月';
  }
}
