import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/app_export.dart';
import '../widgets/custom_icon_button.dart';
import '../widgets/custom_transaction_item.dart';
import '../widgets/empty_state_widget.dart';
import '../core/currency/currency_service.dart';
import '../core/currency/currency.dart';
import '../core/localization/language_service.dart';
import '../core/localization/app_strings.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeOverviewPage extends StatefulWidget {
  const HomeOverviewPage({super.key, this.onProfileTap});

  final VoidCallback? onProfileTap;

  @override
  State<HomeOverviewPage> createState() => _HomeOverviewPageState();
}

class _HomeOverviewPageState extends State<HomeOverviewPage> {
  String? _nev;
  double _balanceHuf = 0.0;
  String? _avatarUrl;
  List<Map<String, dynamic>> _recentExpenses = [];

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

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadRecentExpenses();

    CurrencyService.notifier.addListener(() {
      setState(() {});
    });
  }

  Future<void> _loadUserData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select('full_name, balance, avatar_path')
          .eq('user_id', user.id)
          .maybeSingle();

      if (response == null) return;

      String? avatarUrl;
      String? avatarPath = response['avatar_path'];

      if (avatarPath != null && avatarPath.isNotEmpty) {
        final cleanPath = avatarPath.startsWith('/') 
            ? avatarPath.substring(1) 
            : avatarPath;
        
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        avatarUrl = '${Supabase.instance.client.storage
            .from('avatars')
            .getPublicUrl(cleanPath)}?t=$timestamp';
      }

      setState(() {
        _nev = response['full_name'] ?? AppStrings.user;
        _balanceHuf = (response['balance'] as num?)?.toDouble() ?? 0.0;
        _avatarUrl = avatarUrl;
      });
    } catch (e) {
      //debugPrint('❌ Profil betöltési hiba: $e');
    }
  }

  Future<void> _updateBalanceDialog() async {
    final currentValue = CurrencyService.fromHuf(_balanceHuf);
    final controller = TextEditingController(
      text: currentValue.toStringAsFixed(
        CurrencyService.selectedCurrency == Currency.eur ? 2 : 0,
      ),
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.editBalance),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: '${AppStrings.newBalance} (${CurrencyService.symbol})',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final input =
                  double.tryParse(controller.text.replaceAll(',', '.')) ?? 0.0;

              double newBalanceHuf;
              switch (CurrencyService.selectedCurrency) {
                case Currency.eur:
                  newBalanceHuf = input / CurrencyService.eurRate;
                  break;
                case Currency.rsd:
                  newBalanceHuf = input / CurrencyService.rsdRate;
                  break;
                default:
                  newBalanceHuf = input;
              }

              await _updateBalance(newBalanceHuf);
              Navigator.pop(context);
            },
            child: Text(AppStrings.save),
          ),
        ],
      ),
    );
  }

  Future<void> _updateBalance(double newBalanceHuf) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      await Supabase.instance.client
          .from('profiles')
          .update({'balance': newBalanceHuf.round()})
          .eq('user_id', userId);

      setState(() => _balanceHuf = newBalanceHuf);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppStrings.balanceUpdated)));
    } finally {}
  }

  Future<void> _loadRecentExpenses() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final response = await Supabase.instance.client
        .from('koltsegek')
        .select('megnevezes, osszeg, mennyiseg, datum, kategoria')
        .eq('user_id', userId)
        .order('datum', ascending: false)
        .limit(6);

    setState(() {
      _recentExpenses = (response as List<dynamic>).map((e) {
        final amountHuf = (e['osszeg'] as num).toDouble() * e['mennyiseg'];
        return {
          "iconPath": categoryIcons[e['kategoria']] ?? ImageConstant.otherLogo,
          "title": e['megnevezes'] ?? AppStrings.unknown,
          "subtitle": _formatDateTime(e['datum']),
          "amount": "-${CurrencyService.format(amountHuf)}",
          "amountColor": appTheme.red_900,
        };
      }).toList();
    });
  }

  String _formatDateTime(dynamic value) {
    if (value == null) return '';
    final d = DateTime.parse(value.toString()).toLocal();
    return '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')} · ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: LanguageService.notifier,
      builder: (context, _, __) {
        return Scaffold(
          backgroundColor: appTheme.blue_gray_50,
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.h, vertical: 14.h),
              child: ListView(
                children: [
                  _buildGreetingSection(),
                  SizedBox(height: 12.h),
                  _buildBalanceCard(),
                  SizedBox(height: 22.h),
                  _buildRecentExpensesSection(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGreetingSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.hello,
              style: TextStyleHelper.instance.display36RegularWorkSans,
            ),
            Text(
              '${_nev ?? ""}!',
              style: TextStyleHelper.instance.display36RegularWorkSans.copyWith(
                color: appTheme.blue_gray_900,
              ),
            ),
          ],
        ),

        GestureDetector(
          onTap: widget.onProfileTap,
          child: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[300],
            child: _avatarUrl != null && _avatarUrl!.isNotEmpty
                ? ClipOval(
                    child: CachedNetworkImage(
                      key: ValueKey(_avatarUrl),
                      imageUrl: _avatarUrl!,
                      fit: BoxFit.cover,
                      width: 60,
                      height: 60,
                      placeholder: (context, url) => const CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                      errorWidget: (context, url, error) {
                        return Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.grey[600],
                        );
                      },
                    ),
                  )
                : Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.grey[600],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.h),
        gradient: LinearGradient(
          colors: [appTheme.color190000, appTheme.deep_purple_300],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.balance),
              Text(
                CurrencyService.format(_balanceHuf),
                style: TextStyleHelper.instance.headline28RegularWorkSans,
              ),
            ],
          ),
          CustomIconButton(
            iconPath: ImageConstant.imgGroup4,
            onPressed: _updateBalanceDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentExpensesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.recentExpenses,
          style: TextStyleHelper.instance.title20RegularWorkSans,
        ),
        SizedBox(height: 18.h),
        if (_recentExpenses.isEmpty)
          EmptyStateWidget(
            imagePath: 'assets/illustrations/empty_expenses.svg',
            title: AppStrings.noExpenses,
            subtitle: AppStrings.noExpensesSubtitle,
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentExpenses.length,
            separatorBuilder: (_, __) => SizedBox(height: 26.h),
            itemBuilder: (_, i) {
              final t = _recentExpenses[i];
              return CustomTransactionItem(
                iconPath: t['iconPath'],
                title: t['title'],
                subtitle: t['subtitle'],
                amount: t['amount'],
                amountColor: t['amountColor'],
              );
            },
          ),
      ],
    );
  }
}