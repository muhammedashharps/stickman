// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/statistics_provider.dart';
import '../theme/app_theme.dart';
import '../utils/format_utils.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StatisticsProvider>(
      builder: (context, stats, child) {
        if (!stats.isLoaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.backgroundBlack,
          appBar: AppBar(
            title: Text(
              'Statistics',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.accent,
              labelColor: AppColors.accent,
              unselectedLabelColor: AppColors.textGrey,
              tabs: const [
                Tab(text: 'Today'),
                Tab(text: 'Week'),
                Tab(text: 'Month'),
                Tab(text: 'Year'),
              ],
            ),
          ),
          body: stats.sessions.isEmpty
              ? _buildEmptyState()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildDailyView(stats),
                    _buildWeeklyView(stats),
                    _buildMonthlyView(stats, context),
                    _buildYearlyView(stats),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 80,
              color: AppColors.textGrey.withOpacity(0.5),
            ),
            const SizedBox(height: 20),
            Text(
              'No Focus Sessions Yet',
              style: GoogleFonts.outfit(
                color: AppColors.textWhite,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete your first focus session to see your statistics here.',
              style: TextStyle(color: AppColors.textGrey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // TODAY VIEW
  Widget _buildDailyView(StatisticsProvider stats) {
    final today = DateTime.now();
    final todaySessions = stats.sessionsForDay(today);
    final todayHours = stats.hoursForDay(today);
    final todayMinutes = (todayHours * 60).round();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatCard(
            title: "Today's Focus",
            value: formatDuration(todayMinutes),
            subtitle: '${todaySessions.length} sessions completed',
            color: AppColors.accent,
          ),
          const SizedBox(height: 20),

          Text(
            'Sessions Today',
            style: GoogleFonts.outfit(
              color: AppColors.textWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (todaySessions.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  'No sessions yet today',
                  style: TextStyle(color: AppColors.textGrey),
                ),
              ),
            )
          else
            ...todaySessions.map((session) => _buildSessionTile(session)),

          const SizedBox(height: 24),
          _buildStatCard(
            title: 'Current Streak',
            value: '${stats.currentStreak} days',
            subtitle: 'Keep it going!',
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  // WEEKLY VIEW
  Widget _buildWeeklyView(StatisticsProvider stats) {
    final weeklyData = stats.weeklyData;
    final totalWeekHours = weeklyData.values.fold(0.0, (a, b) => a + b);
    final totalWeekMinutes = (totalWeekHours * 60).round();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatCard(
            title: 'This Week',
            value: formatDuration(totalWeekMinutes),
            subtitle: 'Total focus time',
            color: AppColors.accent,
          ),
          const SizedBox(height: 20),

          Text(
            'Daily Breakdown',
            style: GoogleFonts.outfit(
              color: AppColors.textWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildWeeklyChart(stats),
          const SizedBox(height: 20),

          ...weeklyData.entries.map((entry) {
            final day = entry.key;
            final hours = entry.value;
            final isToday =
                day.day == DateTime.now().day &&
                day.month == DateTime.now().month;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isToday
                    ? AppColors.accent.withOpacity(0.1)
                    : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: isToday
                    ? Border.all(color: AppColors.accent.withOpacity(0.5))
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('EEEE').format(day),
                    style: GoogleFonts.outfit(
                      color: isToday ? AppColors.accent : AppColors.textWhite,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    formatDuration((hours * 60).round()),
                    style: GoogleFonts.outfit(
                      color: isToday ? AppColors.accent : AppColors.textGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // MONTHLY VIEW - with clickable days
  Widget _buildMonthlyView(StatisticsProvider stats, BuildContext context) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    double totalMonthHours = 0;
    final Map<int, double> dailyHours = {};

    for (int i = 1; i <= daysInMonth; i++) {
      final day = DateTime(now.year, now.month, i);
      final hours = stats.hoursForDay(day);
      dailyHours[i] = hours;
      totalMonthHours += hours;
    }

    final totalMonthMinutes = (totalMonthHours * 60).round();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatCard(
            title: DateFormat('MMMM yyyy').format(now),
            value: formatDuration(totalMonthMinutes),
            subtitle: 'Total focus this month',
            color: AppColors.accent,
          ),
          const SizedBox(height: 20),

          Text(
            'Tap a day to see details',
            style: TextStyle(color: AppColors.textGrey, fontSize: 13),
          ),
          const SizedBox(height: 8),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: daysInMonth,
            itemBuilder: (context, index) {
              final dayNum = index + 1;
              final hours = dailyHours[dayNum] ?? 0;
              final intensity = hours > 0 ? (hours / 2).clamp(0.2, 1.0) : 0.0;
              final isToday = dayNum == now.day;
              final dayDate = DateTime(now.year, now.month, dayNum);

              return GestureDetector(
                onTap: () => _showDayStats(context, stats, dayDate),
                child: Container(
                  decoration: BoxDecoration(
                    color: hours > 0
                        ? AppColors.accent.withOpacity(intensity)
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(6),
                    border: isToday
                        ? Border.all(color: Colors.white, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$dayNum',
                      style: TextStyle(
                        color: hours > 0.5 ? Colors.white : AppColors.textGrey,
                        fontSize: 12,
                        fontWeight: isToday
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'No focus',
                style: TextStyle(color: AppColors.textGrey, fontSize: 11),
              ),
              const SizedBox(width: 16),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '< 1 hour',
                style: TextStyle(color: AppColors.textGrey, fontSize: 11),
              ),
              const SizedBox(width: 16),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '1+ hours',
                style: TextStyle(color: AppColors.textGrey, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // YEARLY VIEW
  Widget _buildYearlyView(StatisticsProvider stats) {
    final now = DateTime.now();
    final months = <Map<String, dynamic>>[];

    for (int m = 1; m <= 12; m++) {
      final daysInMonth = DateTime(now.year, m + 1, 0).day;
      double monthHours = 0;
      for (int d = 1; d <= daysInMonth; d++) {
        monthHours += stats.hoursForDay(DateTime(now.year, m, d));
      }
      months.add({
        'month': m,
        'name': DateFormat('MMMM').format(DateTime(now.year, m)),
        'hours': monthHours,
      });
    }

    final totalYearHours = months.fold(
      0.0,
      (sum, m) => sum + (m['hours'] as double),
    );
    final totalYearMinutes = (totalYearHours * 60).round();
    final maxMonthHours = months
        .map((m) => m['hours'] as double)
        .reduce((a, b) => a > b ? a : b);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatCard(
            title: '${now.year}',
            value: formatDuration(totalYearMinutes),
            subtitle: 'Total focus this year',
            color: AppColors.accent,
          ),
          const SizedBox(height: 20),

          Text(
            'Monthly Breakdown',
            style: GoogleFonts.outfit(
              color: AppColors.textWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          ...months.map((m) {
            final hours = m['hours'] as double;
            final percentage = maxMonthHours > 0 ? hours / maxMonthHours : 0.0;
            final isCurrentMonth = m['month'] == now.month;
            final minutes = (hours * 60).round();

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isCurrentMonth
                    ? AppColors.accent.withOpacity(0.1)
                    : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: isCurrentMonth
                    ? Border.all(color: AppColors.accent.withOpacity(0.5))
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        m['name'],
                        style: GoogleFonts.outfit(
                          color: isCurrentMonth
                              ? AppColors.accent
                              : AppColors.textWhite,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        formatDuration(minutes),
                        style: GoogleFonts.outfit(
                          color: isCurrentMonth
                              ? AppColors.accent
                              : AppColors.textGrey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: AppColors.surfaceDark,
                      valueColor: AlwaysStoppedAnimation(
                        isCurrentMonth
                            ? AppColors.accent
                            : AppColors.accent.withOpacity(0.6),
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // Show day statistics in bottom sheet
  void _showDayStats(
    BuildContext context,
    StatisticsProvider stats,
    DateTime day,
  ) {
    final sessions = stats.sessionsForDay(day);
    final hours = stats.hoursForDay(day);
    final minutes = (hours * 60).round();
    final dateFormat = DateFormat('EEEE, MMMM d');

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textGrey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                dateFormat.format(day),
                style: GoogleFonts.outfit(
                  color: AppColors.textWhite,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            formatDuration(minutes),
                            style: GoogleFonts.outfit(
                              color: AppColors.accent,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Focus Time',
                            style: TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${sessions.length}',
                            style: GoogleFonts.outfit(
                              color: AppColors.textWhite,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Sessions',
                            style: TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (sessions.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  'Sessions',
                  style: GoogleFonts.outfit(
                    color: AppColors.textWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...sessions.take(5).map((s) => _buildSessionTile(s)),
                if (sessions.length > 5)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '+ ${sessions.length - 5} more sessions',
                      style: TextStyle(color: AppColors.textGrey, fontSize: 12),
                    ),
                  ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: AppColors.textGrey, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: AppColors.textGrey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionTile(dynamic session) {
    final timeFormat = DateFormat('h:mm a');
    final durationMin = session.durationMinutes.round();
    final endTime = session.completedAt;
    final startTime = endTime.subtract(
      Duration(seconds: session.durationSeconds),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            session.wasCompleted ? Icons.check_circle : Icons.cancel,
            color: session.wasCompleted
                ? AppColors.success
                : AppColors.textGrey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.scenario,
                  style: GoogleFonts.outfit(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${timeFormat.format(startTime)} - ${timeFormat.format(endTime)}',
                  style: TextStyle(color: AppColors.textGrey, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            formatDuration(durationMin),
            style: GoogleFonts.outfit(
              color: AppColors.textGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(StatisticsProvider stats) {
    final weeklyData = stats.weeklyData;
    final maxHours = weeklyData.values.isEmpty
        ? 1.0
        : weeklyData.values.reduce((a, b) => a > b ? a : b);
    final maxY = (maxHours + 0.5).ceilToDouble();

    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY < 1 ? 1 : maxY,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                  final index = value.toInt();
                  if (index >= 0 && index < weeklyData.length) {
                    final date = weeklyData.keys.elementAt(index);
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        days[date.weekday - 1],
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) => Text(
                  formatDuration((value * 60).round()),
                  style: TextStyle(color: AppColors.textGrey, fontSize: 10),
                ),
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: AppColors.surfaceDark, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          barGroups: weeklyData.entries.toList().asMap().entries.map((entry) {
            final index = entry.key;
            final hours = entry.value.value;
            final isToday = index == weeklyData.length - 1;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: hours,
                  color: isToday
                      ? AppColors.accent
                      : AppColors.accent.withOpacity(0.5),
                  width: 20,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
