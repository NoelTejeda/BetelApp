import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/bible_service.dart';
import '../common/bible_reader_screen.dart';

class GuestHomeScreen extends StatelessWidget {
  const GuestHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Buenas noches, Invitado',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            
            // Versículo del Día (Card grande con imagen de fondo)
            const RepaintBoundary(
              child: VerseOfTheDayCard(),
            ),
            
            const SizedBox(height: 24),
            
            // Otras opciones
            const ActionCard(
              title: 'Escritura guiada',
              subtitle: 'Empieza tu día con la Biblia',
              duration: '2-5 minutos',
              icon: Icons.water_drop_outlined,
            ),
            const SizedBox(height: 16),
            const ActionCard(
              title: 'Oración Guiada',
              subtitle: 'Separa tiempo para lo más importante.',
              duration: '4-6 minutos',
              icon: Icons.sign_language_outlined,
            ),
            const SizedBox(height: 16),
            const ActionCard(
              title: 'Trivia Bíblica',
              subtitle: 'Pon a prueba tus conocimientos.',
              duration: 'Jugar ahora',
              icon: Icons.videogame_asset_outlined,
            ),
          ],
        ),
      ),
    );
  }
}

class VerseOfTheDayCard extends StatefulWidget {
  const VerseOfTheDayCard({super.key});

  @override
  State<VerseOfTheDayCard> createState() => _VerseOfTheDayCardState();
}

class _VerseOfTheDayCardState extends State<VerseOfTheDayCard> {
  final BibleService _bibleService = BibleService();
  String _verseText = "Cargando mensaje de esperanza...";
  String _verseRef = "Buscando...";
  String _verseId = "JHN.3.16";
  String _shareUrl = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDailyVerse();
  }

  Future<void> _loadDailyVerse() async {
    // 1. Intentamos cargar de SharedPreferences inmediatamente para evitar el spinner si ya existe
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final savedDate = prefs.getString('vod_date');

    if (savedDate == today && mounted) {
      setState(() {
        _verseText = prefs.getString('vod_text') ?? _verseText;
        _verseRef = prefs.getString('vod_reference') ?? _verseRef;
        _verseId = prefs.getString('vod_id') ?? _verseId;
        _shareUrl = prefs.getString('vod_share_url') ?? "";
        _isLoading = false; // Saltamos el cargando
      });
    }

    // 2. De todas formas ejecutamos el servicio para asegurar que todo esté al día
    try {
      final verseData = await _bibleService.getVerseOfTheDay();
      if (mounted) {
        setState(() {
          _verseText = verseData['text']!;
          _verseRef = verseData['reference']!;
          _verseId = verseData['id']!;
          _shareUrl = verseData['share_url']!;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  final List<String> _backgroundImages = [
    'https://images.unsplash.com/photo-1507400492013-162706c8c05e?q=80&w=800', // Estrellas
    'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?q=80&w=800', // Paisaje
    'https://images.unsplash.com/photo-1438109491414-7198515b166b?q=80&w=800', // Cielo
    'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?q=80&w=800', // Montañas
    'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?q=80&w=800', // Bosque
    'https://images.unsplash.com/photo-1501854140801-50d01698950b?q=80&w=800', // Valle
    'https://images.unsplash.com/photo-1472214103451-9374bd1c798e?q=80&w=800', // Atardecer
  ];

  String _getDailyImage() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return _backgroundImages[dayOfYear % _backgroundImages.length];
  }

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: _getDailyImage(),
      imageBuilder: (context, imageProvider) => Container(
        height: 400,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ]
        ),
        child: InkWell(
          onTap: () => _navigateToVerse(context),
          borderRadius: BorderRadius.circular(20),
          child: _buildCardContent(),
        ),
      ),
      placeholder: (context, url) => Container(
        height: 400,
        decoration: BoxDecoration(
          color: const Color(0xFF1A237E),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(child: CircularProgressIndicator(color: Colors.white)),
      ),
      errorWidget: (context, url, error) => Container(
        height: 400,
        decoration: BoxDecoration(
          color: const Color(0xFF1A237E),
          borderRadius: BorderRadius.circular(20),
        ),
        child: _buildCardContent(),
      ),
    );
  }

  Widget _buildCardContent() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.transparent,
                Colors.black.withOpacity(0.8),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Versículo del Día',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                _verseRef,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : Text(
                    _verseText,
                    style: const TextStyle(color: Colors.white, fontSize: 22, height: 1.3),
                  ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ActionButton(
                    icon: Icons.share_outlined, 
                    label: 'Compartir',
                    onTap: () {
                      final message = '*Versículo del Día - Iglesia Betel*\n\n"$_verseText"\n\n— $_verseRef' + 
                                     (_shareUrl.isNotEmpty ? '\n\nLee más aquí: $_shareUrl' : '');
                      Share.share(message);
                    },
                  ),
                    _ActionButton(
                      icon: Icons.auto_stories_outlined, 
                      label: 'Ir al versículo',
                      onTap: () => _navigateToVerse(context),
                    ),
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  void _navigateToVerse(BuildContext context) {
    // Intentamos extraer el Chapter ID del Verse ID (USFM format: BOOK.CH.VS)
    // Ejemplo: JHN.3.16 -> JHN.3
    final parts = _verseId.split('.');
    String chapterId = _verseId;
    
    if (parts.length >= 2) {
      chapterId = '${parts[0]}.${parts[1]}';
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BibleReaderScreen(
          initialChapterId: chapterId,
          initialVerseId: _verseId,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class InteractionIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const InteractionIcon({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}

class ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String duration;
  final IconData icon;

  const ActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ]
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(subtitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.play_arrow, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(duration, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.church, color: Colors.blueAccent, size: 30),
          )
        ],
      ),
    );
  }
}
