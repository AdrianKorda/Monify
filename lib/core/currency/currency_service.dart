import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'currency.dart';
import 'package:flutter/material.dart';

class CurrencyService {
  static Currency selectedCurrency = Currency.huf;

  // HUF → EUR-t API-ból fogjuk
  static double eurRate = 0.0;

  // HUF → RSD fixált árfolyam
  static const double rsdRate = 0.3046;

  static const _currencyKey = 'selected_currency';

  // 🌍 API LEKÉRÉS
  static Future<void> fetchRates() async {
    try {
      final url = Uri.parse(
        'https://api.frankfurter.app/latest?amount=1&from=HUF&to=EUR',
      );

      final response = await http.get(url);
      if (response.statusCode != 200) return;

      final data = json.decode(response.body);
      eurRate = (data['rates']['EUR'] as num).toDouble();
    } catch (e) {
      debugPrint('❌ Hiba HUF→EUR lekéréskor: $e');
      eurRate = 0.00259; // fallback
    }
  }

  static final ValueNotifier<Currency> notifier = ValueNotifier(
    selectedCurrency,
  );

  static Future<void> saveCurrency(Currency currency) async {
    selectedCurrency = currency;
    notifier.value = currency;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, currency.name);
  }

  static Future<void> loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_currencyKey);

    if (saved != null) {
      selectedCurrency = Currency.values.firstWhere((c) => c.name == saved);
    }
  }

  static double fromHuf(double amount) {
    switch (selectedCurrency) {
      case Currency.eur:
        return amount * eurRate;
      case Currency.rsd:
        return amount * rsdRate;
      default:
        return amount; // HUF
    }
  }

  static String get symbol {
    switch (selectedCurrency) {
      case Currency.eur:
        return '€';
      case Currency.rsd:
        return 'RSD';
      default:
        return 'Ft';
    }
  }

  static String format(double amountHuf) {
    final converted = fromHuf(amountHuf);

    switch (selectedCurrency) {
      case Currency.eur:
        return '${converted.toStringAsFixed(2)} €';
      case Currency.rsd:
        return '${converted.toStringAsFixed(0)} RSD';
      default:
        return '${converted.toStringAsFixed(0)} Ft';
    }
  }
}
