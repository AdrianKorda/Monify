import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_image_view.dart';
import '../../widgets/custom_quantity_selector.dart';
import '../../models/koltseg.dart';
import '../../services/supabase_koltseg_service.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:async';
import '../widgets/empty_state_widget.dart';
import '../core/currency/currency_service.dart';
import '../core/currency/currency.dart';
import '../core/localization/language_service.dart';
import '../core/localization/app_strings.dart';

class KoltsegListaPage extends StatefulWidget {
  const KoltsegListaPage({Key? key}) : super(key: key);

  @override
  State<KoltsegListaPage> createState() => _KoltsegListaPageState();
}

class _KoltsegListaPageState extends State<KoltsegListaPage>
    with TickerProviderStateMixin {
  final SupabaseKoltsegService _koltsegService = SupabaseKoltsegService();
  List<Koltseg> _koltsegek = [];
  String _szuresTipus = 'osszes';
  int _osszegOsszesen = 0;
  int? _dailyLimit;
  int? _weeklyLimit;
  int? _monthlyLimit;
  int? _balance;
  final Map<int, TextEditingController> _mennyisegControllers = {};
  OverlayEntry? _dropdownOverlay;
  final LayerLink _layerLink = LayerLink();
  bool _dropdownVisible = false;
  final GlobalKey _titleKey = GlobalKey();

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

  String localizedCategoryFromHu(String huCategory) {
    switch (huCategory) {
      case 'Élelmiszer':
        return AppStrings.categoryFood;
      case 'Közlekedés':
        return AppStrings.categoryTransport;
      case 'Szórakozás':
        return AppStrings.categoryFun;
      case 'Lakhatás':
        return AppStrings.categoryHousing;
      case 'Egészség':
        return AppStrings.categoryHealth;
      case 'Ruházat':
        return AppStrings.categoryClothing;
      case 'Utazás':
        return AppStrings.categoryTravel;
      case 'Oktatás':
        return AppStrings.categoryEducation;
      default:
        return AppStrings.categoryOther;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserLimits();
    _loadKoltsegek();
  }

  Future<void> _loadUserLimits() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final response = await Supabase.instance.client
        .from('profiles')
        .select('daily_limit, weekly_limit, monthly_limit, balance')
        .eq('user_id', userId)
        .maybeSingle();

    if (response != null) {
      setState(() {
        _dailyLimit = response['daily_limit'];
        _weeklyLimit = response['weekly_limit'];
        _monthlyLimit = response['monthly_limit'];
        _balance = response['balance'];
      });
    }
  }

  Future<void> _loadKoltsegek() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final now = DateTime.now();
    List<Koltseg> koltsegek = [];

    if (_szuresTipus == '24ora') {
      koltsegek = await _koltsegService.getFilteredKoltsegek(
        DateTime(now.year, now.month, now.day),
        userId,
      );
    } else if (_szuresTipus == '1het') {
      final today = DateTime(now.year, now.month, now.day);
      final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
      final endOfWeek = startOfWeek.add(
        const Duration(days: 6, hours: 23, minutes: 59),
      );
      koltsegek = await _koltsegService.getFilteredKoltsegekRange(
        startOfWeek,
        endOfWeek,
        userId,
      );
    } else if (_szuresTipus == '1honap') {
      koltsegek = await _koltsegService.getFilteredKoltsegek(
        DateTime(now.year, now.month, 1),
        userId,
      );
    } else {
      koltsegek = await _koltsegService.getKoltsegekForUser(userId);
    }

    final osszegHuf = koltsegek.fold(0, (sum, item) {
      final priceHuf = item.osszeg.toDouble();
      return sum + (priceHuf * item.mennyiseg).round();
    });

    setState(() {
      _koltsegek = koltsegek;
      _osszegOsszesen = osszegHuf;
      for (var k in koltsegek) {
        if (k.id != null && !_mennyisegControllers.containsKey(k.id)) {
          _mennyisegControllers[k.id!] = TextEditingController(
            text: k.mennyiseg.toString(),
          );
        }
      }
    });
  }

  final Map<int, int> _pendingDiffs = {};
  final Map<int, Timer> _debounceTimers = {};

  void changeQuantityDebounced(Koltseg k, int newQty) {
    final oldQty = k.mennyiseg;
    final diffQty = newQty - oldQty;
    if (diffQty == 0) return;

    final priceHuf = k.osszeg.toDouble();
    final diffMoney = (diffQty * priceHuf).round(); // int

    setState(() {
      final index = _koltsegek.indexWhere((e) => e.id == k.id);
      _koltsegek[index] = k.copyWith(mennyiseg: newQty);
      _osszegOsszesen += diffMoney;
      _balance = (_balance ?? 0) - diffMoney;
    });

    _pendingDiffs[k.id!] = (_pendingDiffs[k.id!] ?? 0) + diffMoney;

    _debounceTimers[k.id!]?.cancel();

    _debounceTimers[k.id!] = Timer(const Duration(milliseconds: 400), () async {
      final totalDiff = _pendingDiffs.remove(k.id!) ?? 0;

      await Supabase.instance.client
          .from('koltsegek')
          .update({'mennyiseg': newQty})
          .eq('id', k.id!);

      final userId = Supabase.instance.client.auth.currentUser!.id;
      await Supabase.instance.client.rpc(
        'update_balance_diff',
        params: {'p_user_id': userId, 'p_diff': -totalDiff},
      );
    });
  }

  Future<void> _koltsegTorlese(int id) async {
    final index = _koltsegek.indexWhere((k) => k.id == id);
    if (index == -1) return;

    final k = _koltsegek[index];
    final diffMoney = k.osszeg * k.mennyiseg;

    final priceHuf = (k.osszeg * k.mennyiseg).round();
    setState(() {
      _koltsegek.removeAt(index);
      _osszegOsszesen -= priceHuf;
      _balance = (_balance ?? 0) + priceHuf;
    });

    await _koltsegService.deleteKoltseg(id);

    final userId = Supabase.instance.client.auth.currentUser!.id;
    await Supabase.instance.client.rpc(
      'update_balance_diff',
      params: {'p_user_id': userId, 'p_diff': diffMoney},
    );
  }

  double _hufToSelected(int huf) {
    switch (CurrencyService.selectedCurrency) {
      case Currency.eur:
        return huf * CurrencyService.eurRate;
      case Currency.rsd:
        return huf * CurrencyService.rsdRate;
      default:
        return huf.toDouble();
    }
  }

  int _selectedToHuf(double value) {
    switch (CurrencyService.selectedCurrency) {
      case Currency.eur:
        return (value / CurrencyService.eurRate).round();
      case Currency.rsd:
        return (value / CurrencyService.rsdRate).round();
      default:
        return value.round();
    }
  }

  Future<void> _updateLimitsDialog() async {
    final dailyController = TextEditingController(
      text: _dailyLimit != null
          ? _hufToSelected(_dailyLimit!).toStringAsFixed(
              CurrencyService.selectedCurrency == Currency.huf ? 0 : 2,
            )
          : '',
    );

    final weeklyController = TextEditingController(
      text: _weeklyLimit != null
          ? _hufToSelected(_weeklyLimit!).toStringAsFixed(
              CurrencyService.selectedCurrency == Currency.huf ? 0 : 2,
            )
          : '',
    );

    final monthlyController = TextEditingController(
      text: _monthlyLimit != null
          ? _hufToSelected(_monthlyLimit!).toStringAsFixed(
              CurrencyService.selectedCurrency == Currency.huf ? 0 : 2,
            )
          : '',
    );

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.editLimits),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: dailyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText:
                    '${AppStrings.dailyLimit} (${CurrencyService.symbol})',
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: weeklyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText:
                    '${AppStrings.weeklyLimit} (${CurrencyService.symbol})',
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: monthlyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText:
                    '${AppStrings.monthlyLimit} (${CurrencyService.symbol})',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final dailyInput =
                  double.tryParse(dailyController.text.trim()) ?? 0;
              final weeklyInput =
                  double.tryParse(weeklyController.text.trim()) ?? 0;
              final monthlyInput =
                  double.tryParse(monthlyController.text.trim()) ?? 0;

              final newDaily = _selectedToHuf(dailyInput);
              final newWeekly = _selectedToHuf(weeklyInput);
              final newMonthly = _selectedToHuf(monthlyInput);

              await _saveNewLimits(
                newDaily: newDaily,
                newWeekly: newWeekly,
                newMonthly: newMonthly,
              );

              Navigator.pop(context);
            },
            child: Text(AppStrings.save),
          ),
        ],
      ),
    );
  }

  Future<void> _saveNewLimits({
    required int newDaily,
    required int newWeekly,
    required int newMonthly,
  }) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await Supabase.instance.client
          .from('profiles')
          .update({
            'daily_limit': newDaily,
            'weekly_limit': newWeekly,
            'monthly_limit': newMonthly,
          })
          .eq('user_id', userId);

      setState(() {
        _dailyLimit = newDaily;
        _weeklyLimit = newWeekly;
        _monthlyLimit = newMonthly;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Limitek frissítve')));
    } catch (e) {
      //debugPrint('❌ Hiba limit mentésekor: $e');
    }
  }

  int limitMaradt() {
    switch (_szuresTipus) {
      case 'osszes':
        return _balance ?? 0;
      case '24ora':
        return (_dailyLimit ?? 0) - _osszegOsszesen;
      case '1het':
        return (_weeklyLimit ?? 0) - _osszegOsszesen;
      case '1honap':
        return (_monthlyLimit ?? 0) - _osszegOsszesen;
      default:
        return 0;
    }
  }

  void _showKoltsegDetails(Koltseg k) {
    final dateTime = DateTime.parse(k.datum).toLocal();
    final formattedDate = DateFormat('yyyy.MM.dd HH:mm').format(dateTime);

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.h)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.all(20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow(AppStrings.name, k.megnevezes),
              _detailRow(AppStrings.category, k.kategoria ?? AppStrings.other),
              _detailRow(AppStrings.date, formattedDate),
              _detailRow(
                AppStrings.unitPrice,
                CurrencyService.format(k.osszeg.toDouble()),
              ),
              _detailRow(AppStrings.quantity, k.mennyiseg.toString()),
              const Divider(height: 24),
              _detailRow(
                AppStrings.total,
                CurrencyService.format((k.osszeg * k.mennyiseg).toDouble()),
                isBold: true,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: LanguageService.notifier,
      builder: (context, _, __) {
        return Scaffold(
          backgroundColor: const Color(0xFFF1F1F1),
          body: Column(
            children: [
              _buildHeaderSection(),
              Expanded(child: _buildExpenseSection()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderSection() {
    final maradtHuf = limitMaradt();
    final osszegHuf = _osszegOsszesen;

    String remainingLabel;

    if (_szuresTipus == 'osszes') {
      remainingLabel = maradtHuf >= 0 ? AppStrings.balance : AppStrings.missing;
    } else {
      remainingLabel = maradtHuf >= 0
          ? AppStrings.hasLeft
          : AppStrings.pastLimit;
    }

    String formattedMaradt;
    String formattedOsszeg;

    switch (CurrencyService.selectedCurrency) {
      case Currency.eur:
        final maradtEur = maradtHuf * CurrencyService.eurRate;
        final osszegEur = osszegHuf * CurrencyService.eurRate;
        formattedMaradt = '${maradtEur.toStringAsFixed(2)} €';
        formattedOsszeg = '${osszegEur.toStringAsFixed(2)} €';
        break;
      case Currency.rsd:
        final maradtRsd = maradtHuf * CurrencyService.rsdRate;
        final osszegRsd = osszegHuf * CurrencyService.rsdRate;
        formattedMaradt = '${maradtRsd.toStringAsFixed(0)} RSD';
        formattedOsszeg = '${osszegRsd.toStringAsFixed(0)} RSD';
        break;
      default:
        formattedMaradt = '${maradtHuf.toStringAsFixed(0)} Ft';
        formattedOsszeg = '${osszegHuf.toStringAsFixed(0)} Ft';
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(0, 36.h, 0, 26.h),
      decoration: BoxDecoration(color: const Color(0xFF9B5DE0)),
      child: Column(
        children: [
          CompositedTransformTarget(
            link: _layerLink,
            child: CustomAppBar(
              titleKey: _titleKey,
              title: _szuresTipus == 'osszes'
                  ? AppStrings.filterAll
                  : _szuresTipus == '24ora'
                  ? AppStrings.filterDaily
                  : _szuresTipus == '1het'
                  ? AppStrings.filterWeekly
                  : AppStrings.filterMonthly,
              titleColor: Colors.white,
              backgroundColor: Colors.transparent,
              horizontalPadding: 28.h,
              showArrowIcon: true,
              arrowIconColor: Colors.white,
              onLeadingTap: _toggleDropdown,
              trailingIcon: ImageConstant.imgEdit05,
              onTrailingTap: _updateLimitsDialog,
            ),
          ),

          SizedBox(height: 28.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    formattedMaradt,
                    style: TextStyleHelper.instance.display36MediumWorkSans
                        .copyWith(color: Colors.white),
                  ),
                ),
                SizedBox(width: 18.h),
                Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: Text(
                    remainingLabel,
                    style: TextStyleHelper.instance.title20RegularWorkSans
                        .copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 6.h),

          if (_szuresTipus != 'osszes')
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.h),
              child: _buildProgressBar(),
            ),

          SizedBox(height: 8.h),

          Padding(
            padding: EdgeInsets.only(left: 16.h),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '$formattedOsszeg ${AppStrings.spent}',
                style: TextStyleHelper.instance.title15RegularWorkSans.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleDropdown() {
    if (_dropdownVisible) {
      _dropdownOverlay?.remove();
      _dropdownVisible = false;
    } else {
      _showDropdown();
      _dropdownVisible = true;
    }
  }

  void _showDropdown() {
    RenderBox? box = _titleKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final size = box.size;
    final position = box.localToGlobal(Offset.zero);

    const double dropWidth = 160;
    final double left = position.dx + (size.width / 2) - (dropWidth / 2);
    final double top = position.dy + size.height + 8;

    _dropdownOverlay = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  _toggleDropdown();
                },
                child: Container(color: Colors.transparent),
              ),
            ),

            Positioned(
              left: left,
              top: top,
              width: dropWidth,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.h),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _dropdownItem(AppStrings.filterAll, 'osszes'),
                      _dropdownItem(AppStrings.filterDaily, '24ora'),
                      _dropdownItem(AppStrings.filterWeekly, '1het'),
                      _dropdownItem(AppStrings.filterMonthly, '1honap'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_dropdownOverlay!);
  }

  Widget _dropdownItem(String text, String value) {
    return InkWell(
      onTap: () {
        setState(() {
          _szuresTipus = value;
        });
        _toggleDropdown();
        _loadKoltsegek();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 12.h),
        child: Text(
          text,
          style: TextStyleHelper.instance.title16RegularWorkSans.copyWith(
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final limit = _szuresTipus == '24ora'
        ? _dailyLimit ?? 0
        : _szuresTipus == '1het'
        ? _weeklyLimit ?? 0
        : _szuresTipus == '1honap'
        ? _monthlyLimit ?? 0
        : (_balance ?? _osszegOsszesen);

    double percent = limit > 0 ? _osszegOsszesen / limit : 0;

    Color barColor = percent <= 1.0
        ? const Color(0xFF6B46C1)
        : const Color.fromARGB(255, 199, 16, 3);

    return Container(
      width: double.infinity,
      height: 26.h,
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(12.h),
      ),
      child: Row(
        children: [
          Expanded(
            flex: (percent.clamp(0.0, 1.0) * 100).toInt(),
            child: Container(
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(12.h),
              ),
            ),
          ),
          Expanded(
            flex: 100 - (percent.clamp(0.0, 1.0) * 100).toInt(),
            child: const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseSection() {
    // 🔹 EMPTY STATE
    if (_koltsegek.isEmpty) {
      return Center(
        child: EmptyStateWidget(
          imagePath: ImageConstant.imgNoData,
          title: AppStrings.noExpenses,
          subtitle: _szuresTipus == 'osszes'
              ? AppStrings.noExpensesAll
              : AppStrings.noExpensesFiltered,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(16.h, 22.h, 16.h, 0.h),
      child: SlidableAutoCloseBehavior(
        child: ListView.separated(
          itemCount: _koltsegek.length,
          separatorBuilder: (context, index) => SizedBox(height: 26.h),
          itemBuilder: (context, index) {
            final k = _koltsegek[index];
            final kategoriHu = k.kategoria ?? 'Egyéb';
            final kategoriText = localizedCategoryFromHu(kategoriHu);

            return Slidable(
              key: ValueKey(k.id),
              endActionPane: ActionPane(
                motion: const DrawerMotion(),
                extentRatio: 0.25,
                children: [
                  CustomSlidableAction(
                    backgroundColor: Colors.transparent,
                    onPressed: (_) async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(AppStrings.delete),
                          content: Text(AppStrings.deleteConfirm),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(AppStrings.cancel),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(AppStrings.delete),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        _koltsegTorlese(k.id!);
                      }
                    },
                    child: const Center(
                      child: Icon(Icons.delete, color: Colors.red, size: 34),
                    ),
                  ),
                ],
              ),
              child: ExpenseItemWidget(
                title: k.megnevezes,
                category: kategoriText,
                iconPath: categoryIcons[kategoriHu] ?? ImageConstant.otherLogo,
                amount:
                    '-${CurrencyService.format((k.osszeg * k.mennyiseg).toDouble())}',
                quantity: k.mennyiseg,
                onIncrement: () => changeQuantityDebounced(k, k.mennyiseg + 1),
                onDecrement: () {
                  if (k.mennyiseg > 1) {
                    changeQuantityDebounced(k, k.mennyiseg - 1);
                  }
                },
                onTap: () => _showKoltsegDetails(k),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyleHelper.instance.body14RegularWorkSans.copyWith(),
          ),
          Text(
            value,
            style: TextStyleHelper.instance.body14RegularWorkSans.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class ExpenseItemWidget extends StatelessWidget {
  final String? title;
  final String? category;
  final String? iconPath;
  final String? amount;
  final int? quantity;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback? onTap;

  const ExpenseItemWidget({
    Key? key,
    this.title,
    this.category,
    this.iconPath,
    this.amount,
    this.quantity,
    this.onIncrement,
    this.onDecrement,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.h),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CustomImageView(
              imagePath: iconPath ?? ImageConstant.otherLogo,
              height: 40.h,
              width: 40.h,
            ),
            SizedBox(width: 24.h),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title ?? 'Ismeretlen tétel',
                    style: TextStyleHelper.instance.title16RegularWorkSans
                        .copyWith(color: const Color(0xFF131851)),
                  ),
                  Text(
                    category ?? 'Egyéb',
                    style: TextStyleHelper.instance.label11RegularWorkSans
                        .copyWith(color: const Color(0xFF4E4E4E)),
                  ),
                ],
              ),
            ),

            CustomQuantitySelector(
              quantity: quantity ?? 1,
              amount: amount ?? '-320 Ft',
              onIncrement: onIncrement,
              onDecrement: onDecrement,
              amountColor: const Color(0xFFA10303),
            ),
          ],
        ),
      ),
    );
  }
}
