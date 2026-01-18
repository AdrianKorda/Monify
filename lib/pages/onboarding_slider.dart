import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:koltsegkoveto/pages/login.dart';
import '../core/localization/app_strings.dart';

class OnboardingSlider extends StatefulWidget {
  const OnboardingSlider({super.key});

  @override
  State<OnboardingSlider> createState() => _OnboardingSliderState();
}

class _OnboardingSliderState extends State<OnboardingSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_Slide> _slides = [
    _Slide(
      title: AppStrings.title1,
      description: AppStrings.descript1,
      imagePath: 'assets/illustrations/slide1.svg',
    ),
    _Slide(
      title: AppStrings.title2,
      description: AppStrings.descript2,
      imagePath: 'assets/illustrations/slide2.svg',
    ),
    _Slide(
      title: AppStrings.title3,
      description: AppStrings.descript3,
      imagePath: 'assets/illustrations/slide3.svg',
    ),
    _Slide(
      title: AppStrings.title4,
      description: AppStrings.descript4,
      imagePath: 'assets/illustrations/slide4.svg',
    ),
    _Slide(
      title: AppStrings.title5,
      description: AppStrings.descript5,
      imagePath: 'assets/illustrations/slide5.svg',
    ),
  ];

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _goToLogin();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  void _skip() {
    _goToLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _skip,
                    child: Text(
                      AppStrings.skip,
                      style: TextStyle(
                        color: Color(0xFF8F92A1),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 350,
                          child: SvgPicture.asset(
                            slide.imagePath,
                            fit: BoxFit.contain,
                          ),
                        ),
                        
                        const SizedBox(height: 48),
                        
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1F36),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        Text(
                          slide.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF8F92A1),
                            height: 1.5,
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? const Color(0xFF6C5CE7)
                              : const Color(0xFFD1D1D6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button
                      if (_currentPage > 0)
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFE8E8E8),
                              width: 2,
                            ),
                          ),
                          child: IconButton(
                            onPressed: _previousPage,
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Color(0xFF1A1F36),
                            ),
                            iconSize: 24,
                          ),
                        )
                      else
                        const SizedBox(width: 48),
                      
                      Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF6C5CE7),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x406C5CE7),
                              blurRadius: 16,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: _nextPage,
                          icon: Icon(
                            _currentPage == _slides.length - 1
                                ? Icons.check
                                : Icons.arrow_forward,
                            color: Colors.white,
                          ),
                          iconSize: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Slide {
  final String title;
  final String description;
  final String imagePath;

  _Slide({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}