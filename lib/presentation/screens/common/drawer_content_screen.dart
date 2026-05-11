import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

import 'commission_detail_screen.dart';

class DrawerContentScreen extends StatelessWidget {
  final String title;
  final String content;

  const DrawerContentScreen({
    Key? key,
    required this.title,
    required this.content,
  }) : super(key: key);

  Future<void> _openMap() async {
    // Coordenadas exactas: 10.518818, -66.921168
    final Uri url = Uri.parse('https://maps.app.goo.gl/iEoEPwUtJ1q3d5SY8');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('No se pudo abrir el mapa $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero-like Title Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFD32F2F).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFD32F2F),
                  letterSpacing: 2.0,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Content Body
            Text(
              content,
              style: TextStyle(
                fontSize: 18,
                height: 1.7,
                color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                letterSpacing: 0.2,
                fontWeight: FontWeight.w400,
              ),
            ),

            // Sección Especial para el Mapa (Solo en Ubícanos)
            if (title == 'Ubícanos') _buildMapSection(context),

            // Sección Especial para Comisiones
            if (title == 'Comisiones') _buildCommissionsList(context),
            
            const SizedBox(height: 40),
            
            // Decorative Footer element
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFF57C00).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommissionsList(BuildContext context) {
    final List<Map<String, String>> commissions = [
      {'name': 'Comisión Social', 'mission': 'Llevar ayuda y esperanza a los más necesitados de nuestra comunidad.', 'function': 'Organizar jornadas de alimentación, salud y apoyo emocional.', 'image': 'comision_social.png'},
      {'name': 'Betel "Jovenes de convicción"', 'mission': 'Formar una generación de jóvenes firmes en la fe y con valores cristianos.', 'function': 'Reuniones semanales, congresos y actividades de integración.', 'image': 'jovenes_conviccion.png'},
      {'name': 'Familias Firmes', 'mission': 'Fortalecer el núcleo familiar bajo los principios bíblicos.', 'function': 'Talleres matrimoniales y consejería familiar.', 'image': 'familias_firmes.png'},
      {'name': 'Oración e Intersección', 'mission': 'Mantener un altar de oración constante por la iglesia y la nación.', 'function': 'Cadenas de oración y vigilias mensuales.', 'image': 'oracion.png'},
      {'name': 'Madres que Oran', 'mission': 'Unir a las madres en oración por el futuro de sus hijos.', 'function': 'Reuniones de oración y apoyo entre madres.', 'image': 'madres_que_oran.png'},
      {'name': 'Ministerio Infantil', 'mission': 'Sembrar la semilla de la palabra de Dios en los más pequeños.', 'function': 'Escuela dominical y eventos infantiles.', 'image': 'ministerio_infantil.png'},
      {'name': 'Equipo Elite Evangelismo', 'mission': 'Cumplir la gran comisión llevando el mensaje a cada rincón.', 'function': 'Salidas de evangelización y seguimiento a nuevos creyentes.', 'image': 'evangelismo.png'},
      {'name': 'Destacamento Betel', 'mission': 'Formar carácter y disciplina en niños y adolescentes.', 'function': 'Actividades al aire libre y formación de valores.', 'image': 'destacamento.png'},
      {'name': 'Águilas Doradas', 'mission': 'Honrar y servir a nuestros adultos mayores.', 'function': 'Actividades de recreación y cuidado espiritual.', 'image': 'aguilas_doradas.png'},
      {'name': 'Servidores de Protocolo', 'mission': 'Brindar una bienvenida cálida y organizada a cada asistente.', 'function': 'Ujieres, recepción y logística de servicios.', 'image': 'protocolo.png'},
      {'name': 'Grupo Musical', 'mission': 'Guiar a la congregación a la presencia de Dios a través de la música.', 'function': 'Ensayos, dirección de alabanza y adoración.', 'image': 'grupo_musical.png'},
      {'name': 'AudioVisual', 'mission': 'Servir como canal técnico para que el mensaje llegue con claridad.', 'function': 'Sonido, luces, proyección y transmisión en vivo.', 'image': 'audiovisual.png'},
      {'name': 'Eventos Especiales', 'mission': 'Planificar y ejecutar celebraciones que glorifiquen a Dios.', 'function': 'Aniversarios, conferencias y conciertos.', 'image': 'eventos.png'},
      {'name': 'Educación Cristiana', 'mission': 'Capacitar a los creyentes en el conocimiento profundo de las escrituras.', 'function': 'Instituto bíblico y cursos de discipulado.', 'image': 'educacion.png'},
      {'name': 'Redes Sociales', 'mission': 'Expandir el mensaje de la iglesia en el mundo digital.', 'function': 'Gestión de contenidos en Instagram, Facebook y YouTube.', 'image': 'redes_sociales.png'},
    ];

    return Column(
      children: [
        const SizedBox(height: 30),
        ...commissions.map((commission) => _buildCommissionCard(context, commission)).toList(),
      ],
    );
  }

  Widget _buildCommissionCard(BuildContext context, Map<String, String> commission) {
    final String imageName = commission['image'] ?? 'commission_bg.png';
    final String imagePath = 'assets/images/commissions/$imageName';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 110,
      width: double.infinity,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CommissionDetailScreen(
                name: commission['name']!,
                mission: commission['mission']!,
                function: commission['function']!,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image with Fallback
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Si no encuentra la imagen específica, usa la genérica
                  return Image.asset(
                    'assets/images/commission_bg.png',
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            // Dark Overlay for readability
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.black.withOpacity(0.2),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            // Centered Text
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  commission['name']!.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 2)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSection(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(color: Colors.black.withOpacity(0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen del mapa real
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Image.asset(
                  'assets/images/map_real.png',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              
              // Información de la Iglesia
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Iglesia Betel',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        const Text(
                          '10.518818, -66.921168',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Botón abajo de la imagen
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _openMap,
                        icon: const Icon(Icons.directions_rounded, color: Colors.white),
                        label: const Text(
                          'VER EN GOOGLE MAPS',
                          style: TextStyle(
                            fontWeight: FontWeight.bold, 
                            letterSpacing: 1.2,
                            fontSize: 15,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD32F2F),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Presiona el botón para abrir la navegación.',
          style: TextStyle(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}
