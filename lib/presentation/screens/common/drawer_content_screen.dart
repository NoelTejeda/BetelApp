import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'commission_detail_screen.dart';
import '../../../services/app_content_service.dart';
import '../../../services/auth_service.dart';
import '../../../domain/models/app_content_model.dart';
import '../../../domain/models/commission_model.dart';
import '../../../domain/models/user_model.dart';

class DrawerContentScreen extends StatefulWidget {
  final String title;
  final String content;

  const DrawerContentScreen({
    Key? key,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  State<DrawerContentScreen> createState() => _DrawerContentScreenState();
}

class _DrawerContentScreenState extends State<DrawerContentScreen> {
  final AppContentService _contentService = AppContentService();
  final AuthService _authService = AuthService();
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdmin();
  }

  Future<void> _checkAdmin() async {
    final user = await _authService.getCurrentUser();
    if (mounted) {
      setState(() {
        _isAdmin = user?.role == UserRole.admin;
      });
    }
  }

  Future<void> _openMap() async {
    final Uri url = Uri.parse('https://maps.app.goo.gl/iEoEPwUtJ1q3d5SY8');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('No se pudo abrir el mapa $url');
    }
  }

  void _editMainParagraph(String currentText) {
    final controller = TextEditingController(text: currentText);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Párrafo'),
        content: TextField(
          controller: controller,
          maxLines: 10,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          ElevatedButton(
            onPressed: () async {
              final content = await _contentService.getContent();
              AppContentModel updated;
              if (widget.title == 'Conócenos') {
                updated = AppContentModel(
                  carouselImages: content.carouselImages,
                  aboutUs: controller.text,
                  location: content.location,
                  commissions: content.commissions,
                );
              } else if (widget.title == 'Ubícanos') {
                updated = AppContentModel(
                  carouselImages: content.carouselImages,
                  aboutUs: content.aboutUs,
                  location: controller.text,
                  commissions: content.commissions,
                );
              } else {
                // Para comisiones, actualizamos el texto de introducción
                // (Guardamos esto en un campo extra o similar si lo deseas, 
                // por ahora usamos el campo 'location' de ejemplo o lo dejamos así)
                Navigator.pop(context);
                return;
              }
              await _contentService.updateContent(updated);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('GUARDAR'),
          ),
        ],
      ),
    );
  }

  void _editCommission(int index, CommissionModel commission) {
    final nameController = TextEditingController(text: commission.name);
    final missionController = TextEditingController(text: commission.mission);
    final functionController = TextEditingController(text: commission.function);
    final urlController = TextEditingController(text: commission.imageUrl);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar: ${commission.name}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nombre')),
              TextField(controller: missionController, decoration: const InputDecoration(labelText: 'Misión'), maxLines: 3),
              TextField(controller: functionController, decoration: const InputDecoration(labelText: 'Función'), maxLines: 3),
              TextField(controller: urlController, decoration: const InputDecoration(labelText: 'URL Imagen (Opcional)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          ElevatedButton(
            onPressed: () async {
              final updated = CommissionModel(
                id: commission.id,
                name: nameController.text,
                mission: missionController.text,
                function: functionController.text,
                imageUrl: urlController.text,
              );
              await _contentService.updateCommission(index, updated);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('GUARDAR'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return StreamBuilder<AppContentModel>(
      stream: _contentService.getContentStream(),
      builder: (context, snapshot) {
        final contentData = snapshot.data;
        String currentContent = widget.content;
        
        // Solo sobrescribimos si el dato de Firebase NO está vacío
        if (contentData != null) {
          if (widget.title == 'Conócenos' && (contentData.aboutUs.isNotEmpty)) {
            currentContent = contentData.aboutUs;
          }
          if (widget.title == 'Ubícanos' && (contentData.location.isNotEmpty)) {
            currentContent = contentData.location;
          }
        }

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD32F2F).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.title.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFD32F2F),
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                Stack(
                  children: [
                    Text(
                      currentContent,
                      style: TextStyle(
                        fontSize: 18,
                        height: 1.7,
                        color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                        letterSpacing: 0.2,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    if (_isAdmin)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blueAccent),
                          onPressed: () => _editMainParagraph(currentContent),
                        ),
                      ),
                  ],
                ),

                if (widget.title == 'Ubícanos') _buildMapSection(context),
                if (widget.title == 'Comisiones') _buildCommissionsList(context, contentData?.commissions ?? []),
                
                const SizedBox(height: 40),
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
    );
  }

  Widget _buildCommissionsList(BuildContext context, List<CommissionModel> firebaseCommissions) {
    // 1. Empezamos con la lista completa de 15 comisiones originales
    final List<CommissionModel> staticList = _getStaticCommissions();
    final List<CommissionModel> displayList = List.from(staticList);

    // 2. Si hay datos en Firebase, reemplazamos solo los que han sido editados
    for (int i = 0; i < firebaseCommissions.length; i++) {
      if (i < displayList.length) {
        displayList[i] = firebaseCommissions[i];
      } else {
        // Si el admin agregó comisiones nuevas más allá de las 15 originales
        displayList.add(firebaseCommissions[i]);
      }
    }

    return Column(
      children: [
        const SizedBox(height: 30),
        ...displayList.asMap().entries.map((entry) {
          return _buildCommissionCard(context, entry.key, entry.value);
        }).toList(),
      ],
    );
  }

  Widget _buildCommissionCard(BuildContext context, int index, CommissionModel commission) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 110,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CommissionDetailScreen(
                    index: index,
                    commission: commission,
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: commission.imageUrl.startsWith('http') 
                    ? Image.network(commission.imageUrl, fit: BoxFit.cover)
                    : Image.asset(
                        'assets/images/commissions/${commission.imageUrl}',
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Image.asset('assets/images/commission_bg.png', fit: BoxFit.cover),
                      ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.6), Colors.black.withOpacity(0.2)],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      commission.name.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isAdmin)
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.edit, color: Colors.amberAccent, size: 28),
                onPressed: () => _editCommission(index, commission),
              ),
            ),
        ],
      ),
    );
  }

  List<CommissionModel> _getStaticCommissions() {
    return AppContentModel.defaultCommissions;
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
              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 25, offset: const Offset(0, 10)),
            ],
            border: Border.all(color: Colors.black.withOpacity(0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Image.asset('assets/images/map_real.png', width: double.infinity, height: 200, fit: BoxFit.cover),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Iglesia Betel', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        const Text('10.518818, -66.921168', style: TextStyle(color: Colors.grey, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _openMap,
                        icon: const Icon(Icons.directions_rounded, color: Colors.white),
                        label: const Text('VER EN GOOGLE MAPS', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD32F2F),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
