import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../domain/models/app_content_model.dart';
import '../../../services/app_content_service.dart';

class AppContentManagementScreen extends StatefulWidget {
  const AppContentManagementScreen({super.key});

  @override
  State<AppContentManagementScreen> createState() => _AppContentManagementScreenState();
}

class _AppContentManagementScreenState extends State<AppContentManagementScreen> {
  final AppContentService _contentService = AppContentService();
  final _aboutUsController = TextEditingController();
  final _locationController = TextEditingController();
  final _commissionsController = TextEditingController();
  final _urlController = TextEditingController();
  
  bool _isSaving = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _aboutUsController.dispose();
    _locationController.dispose();
    _commissionsController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  String _convertDriveUrl(String url) {
    if (url.contains('drive.google.com') || url.contains('docs.google.com')) {
      // Formato: /d/ID/...
      final docIdMatch = RegExp(r'\/d\/([a-zA-Z0-9-_]+)').firstMatch(url);
      if (docIdMatch != null) {
        return 'https://lh3.googleusercontent.com/d/${docIdMatch.group(1)}';
      }
      
      // Formato: ?id=ID
      final idParamMatch = RegExp(r'[?&]id=([a-zA-Z0-9-_]+)').firstMatch(url);
      if (idParamMatch != null) {
        return 'https://lh3.googleusercontent.com/d/${idParamMatch.group(1)}';
      }
    }
    return url;
  }

  Future<void> _addUrlImage() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    final directUrl = _convertDriveUrl(url);
    
    setState(() => _isSaving = true);
    try {
      await _contentService.addImageToCarousel(directUrl);
      _urlController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Imagen añadida por URL')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _pickAndUploadImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image == null) return;

    setState(() => _isSaving = true);
    try {
      final url = await _contentService.uploadCarouselImage(File(image.path));
      await _contentService.addImageToCarousel(url);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Imagen subida correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error al subir imagen: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _saveTextContent() async {
    setState(() => _isSaving = true);
    try {
      final currentContent = await _contentService.getContent();
      final updatedContent = AppContentModel(
        carouselImages: currentContent.carouselImages,
        aboutUs: _aboutUsController.text,
        location: _locationController.text,
        commissions: _commissionsController.text,
      );
      await _contentService.updateContent(updatedContent);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Contenido actualizado')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error al guardar: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Contenido'),
        actions: [
          if (_isSaving)
            const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: Colors.white)))
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveTextContent,
            )
        ],
      ),
      body: StreamBuilder<AppContentModel>(
        stream: _contentService.getContentStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final content = snapshot.data!;
          
          // Solo actualizamos controladores si están vacíos para no borrar lo que el usuario escribe
          if (_aboutUsController.text.isEmpty) _aboutUsController.text = content.aboutUs;
          if (_locationController.text.isEmpty) _locationController.text = content.location;
          if (_commissionsController.text.isEmpty) _commissionsController.text = content.commissions;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionTitle('Carrusel de Imágenes'),
              const SizedBox(height: 8),
              const Text(
                'Puedes subir fotos o pegar enlaces de Google Drive/Internet.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _urlController,
                      decoration: InputDecoration(
                        hintText: 'Pegar enlace de imagen o Drive...',
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(Icons.link),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _addUrlImage,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('AÑADIR'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: content.carouselImages.length + 1,
                  itemBuilder: (context, index) {
                    if (index == content.carouselImages.length) {
                      return _buildAddImageButton();
                    }
                    return _buildImageItem(content.carouselImages[index]);
                  },
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Secciones Informativas'),
              const SizedBox(height: 16),
              _buildTextField('Conócenos', _aboutUsController, maxLines: 5),
              const SizedBox(height: 16),
              _buildTextField('Ubícanos (Horarios, Dirección)', _locationController, maxLines: 5),
              const SizedBox(height: 16),
              _buildTextField('Comisiones', _commissionsController, maxLines: 5),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveTextContent,
                icon: const Icon(Icons.save),
                label: const Text('GUARDAR CAMBIOS'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
    );
  }

  Widget _buildImageItem(String url) {
    return Stack(
      children: [
        Container(
          width: 140,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[900],
            border: Border.all(color: Colors.white10),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              errorWidget: (context, url, error) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.broken_image, color: Colors.white24, size: 32),
                  const SizedBox(height: 4),
                  Text(
                    'Error de enlace',
                    style: TextStyle(color: Colors.white24, fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 16,
          child: GestureDetector(
            onTap: () => _contentService.removeImageFromCarousel(url),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete, color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddImageButton() {
    return InkWell(
      onTap: _pickAndUploadImage,
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[400]!),
        ),
        child: const Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
      ),
    );
  }
}
