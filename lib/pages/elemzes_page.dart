import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_koltseg_service.dart';
import '../models/koltseg.dart';
import '../widgets/analytics_chart_header.dart';
import '../core/app_export.dart';
import '../widgets/empty_state_widget.dart';
import '../core/currency/currency_service.dart';
import '../core/currency/currency.dart';
import '../core/localization/app_strings.dart';

class ElemzesPage extends StatefulWidget {
  const ElemzesPage({super.key});

  @override
  _ElemzesPageState createState() => _ElemzesPageState();
}

enum ElemzesTipus { napi, heti, havi }

class _ElemzesPageState extends State<ElemzesPage> {
  final _service = SupabaseKoltsegService();
  DateTime _selectedMonth = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  DateTime _selectedWeek = DateTime.now(); // itt a hétfő dátumát fogjuk tárolni
  // alapértelmezett: aktuális hónap
  ElemzesTipus _tipus = ElemzesTipus.havi;

  final Map<String, String> categoryIcons = {
    'Élelmiszer': ImageConstant.imgExpenseLogo,
    'Közlekedés': ImageConstant.transportLogo,
    'Szórakozás': ImageConstant.funLogo,
    'Lakhatás': ImageConstant.livingCostLogo,
    'Egészség': ImageConstant.healthLogo,
    'Ruházat': ImageConstant.clothLogo,
    'Utazás': ImageConstant.travelLogo,
    'Oktatás': ImageConstant.educationLogo,
    'Egyéb': ImageConstant.otherLogo,
  };

  DateTimeRange _getSelectedRange() {
    switch (_tipus) {
      case ElemzesTipus.napi:
        final start = DateTime(
          _selectedDay.year,
          _selectedDay.month,
          _selectedDay.day,
        );
        return DateTimeRange(
          start: start,
          end: start.add(const Duration(days: 1)),
        );

      case ElemzesTipus.heti:
        final start = DateTime(
          _selectedWeek.year,
          _selectedWeek.month,
          _selectedWeek.day,
        );
        final end = start.add(const Duration(days: 7));

        return DateTimeRange(start: start, end: end);

      case ElemzesTipus.havi:
        final start = DateTime(_selectedMonth.year, _selectedMonth.month, 1);

        final end = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
        return DateTimeRange(start: start, end: end);
    }
  }

  SideTitles _buildBottomTitles(ElemzesTipus tipus) {
    return SideTitles(
      showTitles: true,
      interval: _getBottomInterval(tipus),
      reservedSize: 48, // 👈 nagyobb hely az alsó sávnak
      getTitlesWidget: (value, meta) {
        final int v = value.toInt();

        switch (tipus) {
          // 🕐 NAPI – órák
          case ElemzesTipus.napi:
            if (v % 6 != 0) return const SizedBox.shrink();
            return SideTitleWidget(
              axisSide: meta.axisSide,
              space: 14,
              child: Text(
                "$v",
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            );

          // 📅 HETI – napok
          case ElemzesTipus.heti:
            const days = ["", "H", "K", "Sz", "Cs", "P", "Sz", "V"];
            if (v < 1 || v > 7) return const SizedBox.shrink();
            return SideTitleWidget(
              axisSide: meta.axisSide,
              space: 14,
              child: Text(
                days[v],
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            );

          // 🗓 HAVI – dátumok
          case ElemzesTipus.havi:
            if (v == 1 || v % 5 == 0) {
              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 14,
                child: Text(
                  "$v",
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              );
            }
            return const SizedBox.shrink();
        }
      },
    );
  }

  double _getBottomInterval(ElemzesTipus tipus) {
    switch (tipus) {
      case ElemzesTipus.napi:
        return 1; // órák
      case ElemzesTipus.heti:
        return 1; // napok
      case ElemzesTipus.havi:
        return 1; // napok
    }
  }

  Map<int, int> fillDaily(Map<int, int> raw) {
    final filled = <int, int>{};
    for (int i = 0; i < 24; i++) {
      filled[i] = raw[i] ?? 0;
    }
    return filled;
  }

  Map<int, int> fillWeekly(Map<int, int> raw) {
    final filled = <int, int>{};
    for (int i = 1; i <= 7; i++) {
      filled[i] = raw[i] ?? 0;
    }
    return filled;
  }

  Map<int, int> fillMonthly(Map<int, int> raw, DateTime selectedMonth) {
    final daysInMonth = DateTime(
      selectedMonth.year,
      selectedMonth.month + 1,
      0,
    ).day;

    final filled = <int, int>{};
    for (int i = 1; i <= daysInMonth; i++) {
      filled[i] = raw[i] ?? 0;
    }
    return filled;
  }

  String _getCategoryIcon(String? category) {
    return categoryIcons[category ?? 'Egyéb'] ?? ImageConstant.otherLogo;
  }

  Map<int, int> aggregateKoltsegek(
    List<Koltseg> koltsegek,
    ElemzesTipus tipus,
  ) {
    final Map<int, int> totals = {};

    for (final k in koltsegek) {
      final date = DateTime.parse(k.datum);

      int key;
      switch (tipus) {
        case ElemzesTipus.napi:
          key = date.hour; // 0–23
          break;
        case ElemzesTipus.heti:
          key = date.weekday; // 1–7
          break;
        case ElemzesTipus.havi:
          key = date.day; // 1–31
          break;
      }

      final amount = k.osszeg * k.mennyiseg;
      totals[key] = (totals[key] ?? 0) + amount;
    }

    return totals;
  }

  double _getMaxYDisplay(Iterable<int> values) {
    if (values.isEmpty) return 100;

    final maxHuf = values.reduce((a, b) => a > b ? a : b);
    final maxDisplay = _displayFromHuf(maxHuf);

    return (maxDisplay * 1.2).ceilToDouble();
  }

  double _getIntervalDisplay(Iterable<int> values) {
    if (values.isEmpty) return 100;

    final maxHuf = values.reduce((a, b) => a > b ? a : b);
    final max = _displayFromHuf(maxHuf);

    if (max <= 100) return 20;
    if (max <= 500) return 100;
    if (max <= 2000) return 200;
    if (max <= 10000) return 1000;
    return (max / 5).ceilToDouble();
  }

  Future<List<MapEntry<String, int>>> _getTopCategories() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return [];

    final range = _getSelectedRange();

    final response = await Supabase.instance.client
        .from('koltsegek')
        .select()
        .eq('user_id', userId)
        .gte('datum', range.start.toIso8601String())
        .lt('datum', range.end.toIso8601String());

    final List data = response as List;

    // összevonás kategóriánként
    final Map<String, int> totals = {};
    for (var e in data) {
      final kat = (e['kategoria'] ?? 'Egyéb') as String;
      final osszeg =
          (e['osszeg'] as num).toInt() * (e['mennyiseg'] as num? ?? 1).toInt();
      totals[kat] = (totals[kat] ?? 0) + osszeg;
    }

    // nagyobb elöl
    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted;
  }

  Future<List<Map<String, dynamic>>> _getTopExpenses() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return [];

    final range = _getSelectedRange();

    final response = await Supabase.instance.client
        .from('koltsegek')
        .select()
        .eq('user_id', userId)
        .gte('datum', range.start.toIso8601String())
        .lt('datum', range.end.toIso8601String());

    // 🔥 Rendezés osszeg * mennyiseg alapján
    response.sort((a, b) {
      final double totalA =
          (a['osszeg'] as num).toDouble() * (a['mennyiseg'] as num).toDouble();
      final double totalB =
          (b['osszeg'] as num).toDouble() * (b['mennyiseg'] as num).toDouble();

      return totalB.compareTo(totalA);
    });

    return response.take(5).toList();
  }

  double _displayFromHuf(int huf) {
    switch (CurrencyService.selectedCurrency) {
      case Currency.eur:
        return huf * CurrencyService.eurRate;
      case Currency.rsd:
        return huf * CurrencyService.rsdRate;
      default:
        return huf.toDouble();
    }
  }

  String _formatDisplayValue(double value, {bool compact = false}) {
    if (compact) {
      if (value >= 1000000) {
        return "${(value / 1000000).toStringAsFixed(1)}M";
      } else if (value >= 1000) {
        return "${(value / 1000).toStringAsFixed(1)}k";
      }
    }

    // max 2 tizedes, .00 levágva
    final str = value.toStringAsFixed(2);
    return str.endsWith('.00') ? str.substring(0, str.length - 3) : str;
  }

  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return Center(child: Text(AppStrings.error));

    Future<Map<int, int>> future;

    switch (_tipus) {
      case ElemzesTipus.napi:
        future = _service.getDailyKoltsegek(_selectedDay, userId).then((list) {
          var totals = aggregateKoltsegek(list, _tipus);
          return fillDaily(totals);
        });
        break;

      case ElemzesTipus.heti:
        future = _service.getWeeklyKoltsegek(_selectedWeek, userId).then((
          list,
        ) {
          var totals = aggregateKoltsegek(list, _tipus);
          return fillWeekly(totals);
        });
        break;

      case ElemzesTipus.havi:
        future = _service
            .getMonthlyKoltsegek(
              _selectedMonth.year,
              _selectedMonth.month,
              userId,
            )
            .then((list) {
              var totals = aggregateKoltsegek(list, _tipus);
              return fillMonthly(totals, _selectedMonth);
            });
    }

    return FutureBuilder<Map<int, int>>(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final totals = snapshot.data!;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                color: appTheme.purple_500.withOpacity(0.0),
                child: AnalyticsChartHeader(
                  tipus: _tipus,
                  onTypeChanged: (newType) {
                    setState(() {
                      _tipus = newType;

                      if (newType == ElemzesTipus.heti) {
                        final now = DateTime.now();
                        _selectedWeek = now.subtract(
                          Duration(days: now.weekday - 1),
                        );
                      }

                      if (newType == ElemzesTipus.napi) {
                        _selectedDay = DateTime.now();
                      }

                      if (newType == ElemzesTipus.havi) {
                        final now = DateTime.now();
                        _selectedMonth = DateTime(now.year, now.month);
                      }
                    });
                  },
                  chartData: _buildStyledLineChartData(totals),
                ),
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${AppStrings.expensesByCategory}:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF131751),
                      ),
                    ),
                    const SizedBox(height: 10),

                    FutureBuilder<List<MapEntry<String, int>>>(
                      future: _getTopCategories(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData)
                          return Center(child: CircularProgressIndicator());

                        final categories = snapshot.data!;
                        if (categories.isEmpty) {
                          return Center(
                            child: EmptyStateWidget(
                              imagePath:
                                  ImageConstant.imgNoData,
                              title: AppStrings.noData,
                              subtitle: AppStrings.noDataInTimeStamp,
                            ),
                          );
                        }

                        bool showAll = false;

                        return StatefulBuilder(
                          builder: (context, setInnerState) {
                            final topCategory = categories.first;
                            final restCategories = showAll
                                ? categories.skip(1).toList()
                                : categories.skip(1).take(3).toList();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: appTheme.purple_500.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 64,
                                        height: 64,
                                        decoration: BoxDecoration(
                                          color: appTheme.purple_500
                                              .withOpacity(0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: SvgPicture.asset(
                                            _getCategoryIcon(topCategory.key),
                                            width: 36,
                                            height: 36,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 16),

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              topCategory.key,
                                              style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color: appTheme.purple_500,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              CurrencyService.format(
                                                topCategory.value.toDouble(),
                                              ),
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: appTheme.purple_500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // következő 3 kategória
                                ...restCategories.map(
                                  (e) => ListTile(
                                    leading: Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: appTheme.purple_500.withOpacity(
                                          0.12,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: SvgPicture.asset(
                                          _getCategoryIcon(e.key),
                                          width: 22,
                                          height: 22,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      e.key,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    trailing: Text(
                                      CurrencyService.format(
                                        e.value.toDouble(),
                                      ),
                                    ),
                                  ),
                                ),
                                if (categories.length > 4)
                                  TextButton(
                                    onPressed: () {
                                      setInnerState(() => showAll = !showAll);
                                    },
                                    child: Text(
                                      showAll
                                          ? AppStrings.less
                                          : AppStrings.more,
                                      style: TextStyle(
                                        color: appTheme.purple_500,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    Text(
                      "${AppStrings.topExpenses}:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF131751),
                      ),
                    ),
                    const SizedBox(height: 10),

                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: _getTopExpenses(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData)
                          return Center(child: CircularProgressIndicator());

                        final topExpenses = snapshot.data!;
                        if (topExpenses.isEmpty){
                          return Center(
                            child: EmptyStateWidget(
                              imagePath: ImageConstant.imgNoData,
                              title: AppStrings.noData,
                              subtitle: AppStrings.noDataInTimeStamp,
                            ),
                          );
                        }

                        final topExpense = topExpenses.first;
                        final restExpenses = topExpenses.skip(1).toList();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTopExpenseCard(topExpense),
                            const SizedBox(height: 12),

                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: restExpenses.length,
                              itemBuilder: (context, index) {
                                final e = restExpenses[index];
                                final date = DateTime.parse(e['datum']);
                                final int hufAmount =
                                    (e['osszeg'] as num).toInt() *
                                    ((e['mennyiseg'] ?? 1) as num).toInt();

                                return ListTile(
                                  leading: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: appTheme.purple_500.withOpacity(
                                        0.12,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        _getCategoryIcon(e['kategoria']),
                                        width: 22,
                                        height: 22,
                                      ),
                                    ),
                                  ),
                                  title: Text("${e['megnevezes']}"),
                                  subtitle: Text(
                                    "${date.year}.${date.month}.${date.day} "
                                    "${date.hour}:${date.minute.toString().padLeft(2, '0')}",
                                  ),
                                  trailing: Text(
                                    CurrencyService.format(
                                      hufAmount.toDouble(),
                                    ),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: appTheme.purple_500,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopExpenseCard(Map<String, dynamic> e) {
    final date = DateTime.parse(e['datum']);
    final int amount =
        (e['osszeg'] as num).toInt() * ((e['mennyiseg'] ?? 1) as num).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: appTheme.purple_500.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: appTheme.purple_500.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                _getCategoryIcon(e['kategoria']),
                width: 36,
                height: 36,
              ),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e['megnevezes'],
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: appTheme.purple_500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  CurrencyService.format(amount.toDouble()),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B46C1),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${date.year}.${date.month}.${date.day} "
                  "${date.hour}:${date.minute.toString().padLeft(2, '0')}",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  LineChartData _buildStyledLineChartData(Map<int, int> totals) {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: _getIntervalDisplay(totals.values),
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: appTheme.white_A700.withOpacity(0.15),
            strokeWidth: 1,
          );
        },
      ),

      titlesData: FlTitlesData(
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(sideTitles: _buildBottomTitles(_tipus)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            interval: _getIntervalDisplay(totals.values),
            getTitlesWidget: (value, meta) {
              return Text(
                _formatDisplayValue(value, compact: true),
                style: TextStyle(
                  color: appTheme.white_A700.withOpacity(0.7),
                  fontSize: 10,
                ),
              );
            },
          ),
        ),
      ),

      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (spots) {
            return spots.map((spot) {
              return LineTooltipItem(
                "${_formatDisplayValue(spot.y)} ${CurrencyService.symbol}",
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList();
          },
        ),
      ),

      borderData: FlBorderData(show: false),
      maxY: _getMaxYDisplay(totals.values),

      lineBarsData: [
        LineChartBarData(
          isCurved: true,
          color: appTheme.white_A700,
          barWidth: 3,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                appTheme.purple_500.withOpacity(0.3),
                appTheme.purple_500.withOpacity(0.3),
              ],
            ),
          ),
          spots: totals.entries.map((e) {
            final displayValue = double.parse(
              _displayFromHuf(e.value).toStringAsFixed(2),
            );
            return FlSpot(e.key.toDouble(), displayValue);
          }).toList(),
        ),
      ],
    );
  }
}
