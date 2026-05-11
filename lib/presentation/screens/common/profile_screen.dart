import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  bool _isEditing = false;

  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  String? _localPhotoPath;
  String? _remotePhotoUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _bioController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _nameController.text = data['name'] ?? '';
          _bioController.text = data['bio'] ?? 'Sin biografía';
          _phoneController.text = data['phone'] ?? '';
          _addressController.text = data['address'] ?? '';
          _localPhotoPath = data['localPhotoPath'];
          _remotePhotoUrl = data['photoUrl'];
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'localPhotoPath': pickedFile.path,
        });
        setState(() => _localPhotoPath = pickedFile.path);
      }
    }
  }

  Future<void> _saveProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'name': _nameController.text,
        'bio': _bioController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
      });
      setState(() => _isEditing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blueAccent, Colors.deepPurpleAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                Positioned(
                  top: 100,
                  child: _buildProfileAvatar(),
                ),
              ],
            ),
            const SizedBox(height: 80),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  if (!_isEditing) ...[
                    Text(_nameController.text, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(_bioController.text, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[400], fontSize: 16)),
                  ] else ...[
                    TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nombre Completo')),
                    TextField(controller: _bioController, decoration: const InputDecoration(labelText: 'Biografía')),
                  ],
                  const SizedBox(height: 32),
                  _buildInfoCard(Icons.phone, 'Teléfono', _phoneController),
                  _buildInfoCard(Icons.location_on, 'Dirección', _addressController),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 55),
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: _isEditing ? _saveProfile : () => setState(() => _isEditing = true),
                    icon: Icon(_isEditing ? Icons.save : Icons.edit),
                    label: Text(_isEditing ? 'GUARDAR' : 'EDITAR PERFIL'),
                  ),
                  if (_isEditing)
                    TextButton(onPressed: () => setState(() => _isEditing = false), child: const Text('CANCELAR')),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => _auth.signOut().then((_) => Navigator.of(context).popUntil((route) => route.isFirst)),
                    child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.redAccent)),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    ImageProvider? imageProvider;
    if (_localPhotoPath != null) {
      imageProvider = FileImage(File(_localPhotoPath!));
    } else if (_remotePhotoUrl != null) {
      imageProvider = NetworkImage(_remotePhotoUrl!);
    }
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: CircleAvatar(
          radius: 70,
          backgroundColor: Colors.grey[800],
          backgroundImage: imageProvider,
          child: imageProvider == null ? const Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.white70) : null,
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, TextEditingController controller) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.blueAccent),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  if (!_isEditing)
                    Text(controller.text.isEmpty ? 'No especificado' : controller.text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
                  else
                    TextField(controller: controller, decoration: const InputDecoration(isDense: true, border: InputBorder.none), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
