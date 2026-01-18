import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_koltseg_service.dart';
import '../models/koltseg.dart';
import '../../core/app_export.dart';
import '../core/currency/currency_service.dart';
import '../core/currency/currency.dart';
import '../core/localization/app_strings.dart';

class KoltsegHozzaadasPage extends StatefulWidget {
  @override
  State<KoltsegHozzaadasPage> createState() => _KoltsegHozzaadasPageState();
}

class _KoltsegHozzaadasPageState extends State<KoltsegHozzaadasPage> {
  final SupabaseKoltsegService _koltsegService = SupabaseKoltsegService();

  final _megnevezesController = TextEditingController();
  final _osszegController = TextEditingController();
  final _mennyisegController = TextEditingController(text: '1');

  DateTime _kivalasztottDatum = DateTime.now();
  String? _kivalasztottKategoria;

  final List<Map<String, dynamic>> _kategoriak = [
    {
      'hu': 'Élelmiszer',
      'text': AppStrings.categoryFood,
      'ikon': ImageConstant.imgExpenseLogo,
    },
    {
      'hu': 'Közlekedés',
      'text': AppStrings.categoryTransport,
      'ikon': ImageConstant.transportLogo,
    },
    {
      'hu': 'Szórakozás',
      'text': AppStrings.categoryFun,
      'ikon': ImageConstant.funLogo,
    },
    {
      'hu': 'Lakhatás',
      'text': AppStrings.categoryHousing,
      'ikon': ImageConstant.livingCostLogo,
    },
    {
      'hu': 'Egészség',
      'text': AppStrings.categoryHealth,
      'ikon': ImageConstant.healthLogo,
    },
    {
      'hu': 'Ruházat',
      'text': AppStrings.categoryClothing,
      'ikon': ImageConstant.clothLogo,
    },
    {
      'hu': 'Utazás',
      'text': AppStrings.categoryTravel,
      'ikon': ImageConstant.travelLogo,
    },
    {
      'hu': 'Oktatás',
      'text': AppStrings.categoryEducation,
      'ikon': ImageConstant.educationLogo,
    },
    {
      'hu': 'Egyéb',
      'text': AppStrings.categoryOther,
      'ikon': ImageConstant.otherLogo,
    },
  ];

  double _parseAmountInput(String raw) {
    return double.tryParse(raw.replaceAll(',', '.')) ?? 0;
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

  String get _amountHint {
    switch (CurrencyService.selectedCurrency) {
      case Currency.eur:
        return '0.00 €';
      case Currency.rsd:
        return '0 RSD';
      default:
        return '0 Ft';
    }
  }

  Future<void> _ujKoltsegHozzaadasa() async {
    final mennyiseg = int.tryParse(_mennyisegController.text) ?? 1;

    if (mennyiseg <= 0 ||
        _megnevezesController.text.isEmpty ||
        _osszegController.text.isEmpty ||
        _kivalasztottKategoria == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppStrings.errorOccurred)));
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppStrings.errorOccurred)));
      return;
    }

    final parsed = _parseAmountInput(_osszegController.text);
    if (parsed <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppStrings.errorOccurred)));
      return;
    }

    final totalHuf = _selectedToHuf(parsed);
    final unitPrice = (totalHuf / mennyiseg).round();

    final ujKoltseg = Koltseg(
      megnevezes: _megnevezesController.text.trim(),
      osszeg: unitPrice,
      mennyiseg: mennyiseg,
      datum: _kivalasztottDatum.toIso8601String(),
      userId: user.id,
      kategoria: _kivalasztottKategoria!,
    );

    try {
      await _koltsegService.insertKoltsegWithBalanceUpdate(ujKoltseg, totalHuf);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.expenseSaved),
        ),
      );

      _megnevezesController.clear();
      _osszegController.clear();
      _mennyisegController.text = '1';

      setState(() {
        _kivalasztottDatum = DateTime.now();
        _kivalasztottKategoria = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.errorOccurred),
          backgroundColor: Colors.red[600],
        ),
      );
    }
  }

  Future<void> _datumValasztas() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _kivalasztottDatum,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _kivalasztottDatum = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F1F1),
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFFF1F1F1),
          statusBarIconBrightness: Brightness.dark,
        ),
        title: Text(
          AppStrings.addExpense,
          style: const TextStyle(color: Colors.black, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).unfocus();

          if (_kivalasztottKategoria != null) {
            setState(() => _kivalasztottKategoria = null);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _input(
                AppStrings.name,
                _megnevezesController,
                AppStrings.exampleName,
              ),
              const SizedBox(height: 16),

              _input(
                AppStrings.total,
                _osszegController,
                _amountHint,
                type: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),

              _input(
                AppStrings.quantity,
                _mennyisegController,
                '1',
                type: TextInputType.number,
              ),

              const SizedBox(height: 20),

              Text(
                AppStrings.date,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),

              InkWell(
                onTap: _datumValasztas,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_kivalasztottDatum.year}-${_kivalasztottDatum.month}-${_kivalasztottDatum.day}',
                      ),
                      const Icon(Icons.calendar_today, size: 18),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                AppStrings.category,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              _buildKategoriaGrid(),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _ujKoltsegHozzaadasa,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B46C1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    AppStrings.save,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input(
    String label,
    TextEditingController c,
    String hint, {
    TextInputType? type,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: c,
          keyboardType: type,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[300],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKategoriaGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: _kategoriak.length,
      itemBuilder: (context, i) {
        final k = _kategoriak[i];
        final selected = _kivalasztottKategoria == k['hu'];

        return GestureDetector(
          onTap: () => setState(() => _kivalasztottKategoria = k['hu']),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: selected ? Colors.deepPurple : Colors.deepPurple[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(child: SvgPicture.asset(k['ikon'], width: 26)),
              ),
              const SizedBox(height: 6),
              Text(
                k['text'],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _megnevezesController.dispose();
    _osszegController.dispose();
    _mennyisegController.dispose();
    super.dispose();
  }
}
