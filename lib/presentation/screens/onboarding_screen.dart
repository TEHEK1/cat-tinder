import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/analytics/analytics_service.dart';
import '../../data/datasources/app_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _bounceController;
  late AnimationController _scaleController;
  int _currentPage = 0;
  double _pageOffset = 0;

  static const _steps = [
    _OnboardingStep(
      emoji: '😻',
      title: 'Свайпай котиков!',
      description:
          'Смахивайте карточки влево или вправо.\nЛайкайте понравившихся и пропускайте остальных!',
      color: Colors.orange,
    ),
    _OnboardingStep(
      emoji: '🔍',
      title: 'Узнавай всё о породах',
      description:
          'Нажмите на карточку котика, чтобы увидеть\nподробную информацию о породе и характере.',
      color: Colors.purple,
    ),
    _OnboardingStep(
      emoji: '📚',
      title: 'Каталог пород',
      description:
          'Переключайтесь между вкладками для просмотра\nполного списка пород кошек со всего мира.',
      color: Colors.blue,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _pageController.addListener(() {
      setState(() {
        _pageOffset = _pageController.page ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _scaleController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    await sl<AppPreferences>().setOnboardingCompleted();
    sl<AnalyticsService>().logOnboardingComplete();
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentPage];

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [step.color.shade100, step.color.shade50],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8, top: 8),
                  child: TextButton(
                    onPressed: _completeOnboarding,
                    child: Text(
                      'Пропустить',
                      style: TextStyle(
                        color: step.color.shade700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _steps.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                    _scaleController.reset();
                    _scaleController.forward();
                  },
                  itemBuilder: (context, index) {
                    final pageStep = _steps[index];
                    final diff = _pageOffset - index;
                    final absDiff = diff.abs();
                    final catScale = (1.0 - absDiff * 0.3).clamp(0.5, 1.0);
                    final rotation = diff * 0.15;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _bounceController,
                            builder: (context, child) {
                              final bounce =
                                  sin(_bounceController.value * pi) * 15;
                              return Transform.translate(
                                offset: Offset(0, -bounce),
                                child: Transform(
                                  alignment: Alignment.center,
                                  transform: (Matrix4.diagonal3Values(catScale, catScale, 1.0)
                                    ..rotateZ(rotation)),
                                  child: child,
                                ),
                              );
                            },
                            child: Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                color: pageStep.color.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: pageStep.color.withValues(alpha: 0.3),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  pageStep.emoji,
                                  style: const TextStyle(fontSize: 72),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 48),
                          ScaleTransition(
                            scale: CurvedAnimation(
                              parent: _scaleController,
                              curve: Curves.elasticOut,
                            ),
                            child: Text(
                              pageStep.title,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: pageStep.color.shade900,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 16),
                          FadeTransition(
                            opacity: CurvedAnimation(
                              parent: _scaleController,
                              curve: Curves.easeIn,
                            ),
                            child: Text(
                              pageStep.description,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade700,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_steps.length, (index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: index == _currentPage ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: index == _currentPage
                                ? step.color.shade400
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: step.color.shade400,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          _currentPage == _steps.length - 1
                              ? 'Начать!'
                              : 'Далее',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingStep {
  final String emoji;
  final String title;
  final String description;
  final MaterialColor color;

  const _OnboardingStep({
    required this.emoji,
    required this.title,
    required this.description,
    required this.color,
  });
}
