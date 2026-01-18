import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/localization/language.dart';
import '../core/localization/language_service.dart';
import 'onboarding_slider.dart';

class FirstRunScreen extends StatefulWidget {
  const FirstRunScreen({super.key});

  @override
  State<FirstRunScreen> createState() => _FirstRunScreenState();
}

class _FirstRunScreenState extends State<FirstRunScreen> {
  AppLanguage? _selectedLanguage;
  bool _languageSelected = false;

  void _onLanguageSelected(AppLanguage lang) async {
    setState(() {
      _selectedLanguage = lang;
      _languageSelected = true;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_run', false);

    await LanguageService.saveLanguage(lang);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const OnboardingSlider()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: _languageSelected
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5CE7)),
              ),
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    
                    Image.asset(
                      'assets/illustrations/language.png',
                      height: 250,
                      fit: BoxFit.contain,
                    ),
                    
                    const SizedBox(height: 48),
                    
                    const Text(
                      'Select Language',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1F36),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    const Text(
                      'Choose your preferred language',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF8F92A1),
                        height: 1.5,
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: _languageCard(
                            AppLanguage.hu,
                            'Magyar',
                            '🇭🇺',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _languageCard(
                            AppLanguage.en,
                            'English',
                            '🇬🇧',
                          ),
                        ),
                      ],
                    ),
                    
                    const Spacer(flex: 3),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _languageCard(AppLanguage lang, String label, String flag) {
    final isSelected = _selectedLanguage == lang;
    
    return GestureDetector(
      onTap: () => _onLanguageSelected(lang),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6C5CE7) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF6C5CE7) : const Color(0xFFE8E8E8),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF6C5CE7).withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF1A1F36),
              ),
            ),
          ],
        ),
      ),
    );
  }
}