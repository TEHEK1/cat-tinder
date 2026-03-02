import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../data/datasources/app_preferences.dart';
import '../../domain/entities/cat.dart';
import '../../domain/repositories/cat_repository.dart';
import '../utils/error_handler.dart';
import '../widgets/cat_card.dart';
import 'cat_detail_screen.dart';

class SwipeScreen extends StatefulWidget {
  const SwipeScreen({super.key});

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  final CatRepository _catRepository = sl<CatRepository>();
  final AppPreferences _prefs = sl<AppPreferences>();
  Cat? _currentCat;
  bool _isLoading = false;
  int _likeCount = 0;
  double _dragPosition = 0;

  @override
  void initState() {
    super.initState();
    _likeCount = _prefs.likeCount;
    _loadRandomCat();
  }

  Future<void> _loadRandomCat() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cat = await _catRepository.getRandomCat();
      setState(() {
        _currentCat = cat;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ErrorHandler.showErrorDialog(context, e.toString());
      }
    }
  }

  void _onLike() {
    setState(() {
      _likeCount++;
    });
    _prefs.setLikeCount(_likeCount);
    _loadRandomCat();
    ScaffoldMessenger.of(context).clearSnackBars();
    ErrorHandler.showSnackBar(context, '❤️ Лайк!');
  }

  void _onDislike() {
    _loadRandomCat();
    ScaffoldMessenger.of(context).clearSnackBars();
    ErrorHandler.showSnackBar(context, '👎 Дизлайк');
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragPosition += details.delta.dx;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_dragPosition > 100) {
      _onLike();
    } else if (_dragPosition < -100) {
      _onDislike();
    }

    setState(() {
      _dragPosition = 0;
    });
  }

  void _openCatDetail() {
    final cat = _currentCat;
    if (cat != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CatDetailScreen(cat: cat),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.orange.shade100, Colors.pink.shade100],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '🐱 Кототиндер',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade400,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.favorite, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            '$_likeCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: _isLoading
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Загружаем котика...'),
                          ],
                        ),
                      )
                    : _currentCat == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 60,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text('Не удалось загрузить котика'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadRandomCat,
                              child: const Text('Попробовать снова'),
                            ),
                          ],
                        ),
                      )
                    : GestureDetector(
                        onHorizontalDragUpdate: _onHorizontalDragUpdate,
                        onHorizontalDragEnd: _onHorizontalDragEnd,
                        child: Transform.translate(
                          offset: Offset(_dragPosition, 0),
                          child: Transform.rotate(
                            angle: _dragPosition * 0.001,
                            child: CatCard(
                              cat: _currentCat ?? Cat(id: '', url: '', breeds: []),
                              onTap: _openCatDetail,
                            ),
                          ),
                        ),
                      ),
              ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FloatingActionButton(
                      heroTag: 'dislike',
                      onPressed: _currentCat != null ? _onDislike : null,
                      backgroundColor: Colors.red.shade400,
                      child: const Icon(Icons.close, size: 32),
                    ),

                    FloatingActionButton.large(
                      heroTag: 'like',
                      onPressed: _currentCat != null ? _onLike : null,
                      backgroundColor: Colors.green.shade400,
                      child: const Icon(Icons.favorite, size: 40),
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
