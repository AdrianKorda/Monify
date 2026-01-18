import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Oldalak
import 'pages/home_overview.dart';
import 'pages/koltseg_hozzaadas_page.dart';
import 'pages/koltseg_lista_page.dart';
import 'pages/elemzes_page.dart';
import 'pages/profil_page.dart';
import 'pages/login.dart';
import 'core/app_export.dart';
import 'core/currency/currency_service.dart';
import 'core/localization/language_service.dart';
import 'core/localization/app_strings.dart';
import 'core/localization/language.dart';
import 'pages/FirstRunScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await CurrencyService.loadCurrency();
  await CurrencyService.fetchRates();

  await LanguageService.loadLanguage();

  await Supabase.initialize(
    url: 'placeholder.supabase.co',
    anonKey:
        'anonkey goes here',
  );

  final prefs = await SharedPreferences.getInstance();
  final isFirstRun = prefs.getBool('first_run') ?? true;

  runApp(MyApp(isFirstRun: isFirstRun));
}

class MyApp extends StatelessWidget {
  final bool isFirstRun;
  const MyApp({super.key, required this.isFirstRun});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: LanguageService.notifier,
      builder: (context, _, __) {
        return MaterialApp(
          title: AppStrings.appTitle,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(primarySwatch: Colors.blue),
          home: isFirstRun
              ? const FirstRunScreen()
              : const AuthGate(),
        );
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<bool> _shouldAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();

    final isFirstRun = prefs.getBool('first_run') ?? true;
    if (isFirstRun) {
      return false;
    }

    final rememberMe = prefs.getBool('remember_me') ?? false;
    final session = Supabase.instance.client.auth.currentSession;

    return rememberMe && session != null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _shouldAutoLogin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final canAutoLogin = snapshot.data ?? false;

        return canAutoLogin ? const MainPage() : LoginScreen();
      },
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeOverviewPage(onProfileTap: () => _onItemTapped(4)),
      KoltsegHozzaadasPage(),
      KoltsegListaPage(),
      ElemzesPage(),
      ProfilPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.blue_gray_50,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: ValueListenableBuilder<AppLanguage>(
        valueListenable: LanguageService.notifier,
        builder: (context, _, __) {
          return _buildCustomNavBar(context);
        },
      ),
    );
  }

  Widget _buildCustomNavBar(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: 110 + bottomInset,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CustomPaint(
                size: Size(MediaQuery.of(context).size.width, 75),
                painter: _NavBarPainter(),
              ),
            ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 75,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(Icons.home_outlined, AppStrings.home, 0),
                    _buildNavItem(
                      Icons.list_alt_outlined,
                      AppStrings.expenses,
                      2,
                    ),
                    const SizedBox(width: 65),
                    _buildNavItem(
                      Icons.show_chart_outlined,
                      AppStrings.analytics,
                      3,
                    ),
                    _buildNavItem(Icons.person_outline, AppStrings.profile, 4),
                  ],
                ),
              ),
            ),

            Positioned(
              bottom: 35,
              child: GestureDetector(
                onTap: () => _onItemTapped(1),
                child: Container(
                  height: 58,
                  width: 58,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(155, 93, 224, 1),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 28),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? appTheme.deep_purple_300 : Colors.grey,
            size: isSelected ? 30 : 26,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isSelected ? appTheme.deep_purple_300 : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavBarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    final centerWidth = size.width / 2;

    path.moveTo(0, 0);
    path.lineTo(centerWidth - 50, 0);

    path.quadraticBezierTo(centerWidth - 30, 0, centerWidth - 30, 15);
    path.arcToPoint(
      Offset(centerWidth + 30, 15),
      radius: const Radius.circular(30),
      clockwise: false,
    );
    path.quadraticBezierTo(centerWidth + 30, 0, centerWidth + 50, 0);

    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawShadow(path, Colors.black.withOpacity(0.15), 6, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
