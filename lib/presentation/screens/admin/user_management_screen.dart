import 'package:flutter/material.dart';
import '../../../domain/models/user_model.dart';
import '../../../services/auth_service.dart';

import '../../widgets/custom_drawer.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _searchController = TextEditingController();
  
  UserRole _selectedRole = UserRole.alumno;
  bool _isLoading = false;
  List<UserModel> _allUsers = [];
  List<UserModel> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await AuthService().getAllUsers();
      setState(() {
        _allUsers = users;
        _filteredUsers = users;
      });
    } catch (e) {
      _showError('No se pudo cargar la lista: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterUsers(String query) {
    setState(() {
      _filteredUsers = _allUsers.where((user) => 
        user.name.toLowerCase().contains(query.toLowerCase()) || 
        user.email.toLowerCase().contains(query.toLowerCase())
      ).toList();
    });
  }

  Future<void> _toggleStatus(UserModel user) async {
    try {
      await AuthService().toggleUserStatus(user.id, user.isActive);
      _fetchUsers();
      _showSuccess(user.isActive ? 'Usuario bloqueado' : 'Usuario desbloqueado');
    } catch (e) {
      _showError('Error al cambiar estado: $e');
    }
  }

  Future<void> _createUser() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await AuthService().registerUserByAdmin(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        role: _selectedRole,
      );
      _showSuccess('✅ Usuario creado exitosamente');
      _formKey.currentState!.reset();
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _fetchUsers();
    } catch (e) {
      _showError('❌ Error al crear usuario: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: const CustomDrawer(),
        appBar: AppBar(
          title: const Text('Consola de Seguridad', style: TextStyle(fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.people_alt_rounded), text: 'GESTIÓN'),
              Tab(icon: Icon(Icons.person_add_alt_1_rounded), text: 'NUEVO'),
            ],
            indicatorColor: Color(0xFFF57C00),
            labelColor: Color(0xFFF57C00),
            unselectedLabelColor: Colors.grey,
          ),
        ),
        body: TabBarView(
          children: [
            _buildManagementTab(isDark),
            _buildRegistrationTab(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementTab(bool isDark) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            onChanged: _filterUsers,
            decoration: InputDecoration(
              hintText: 'Buscar por nombre o correo...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFFF57C00)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              filled: true,
              fillColor: isDark ? Colors.white10 : Colors.grey[100],
            ),
          ),
        ),
        Expanded(
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFF57C00)))
            : RefreshIndicator(
                onRefresh: _fetchUsers,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = _filteredUsers[index];
                    return _buildUserCard(user, isDark);
                  },
                ),
              ),
        ),
      ],
    );
  }

  Widget _buildUserCard(UserModel user, bool isDark) {
    Color roleColor;
    switch (user.role) {
      case UserRole.admin: roleColor = const Color(0xFFD32F2F); break;
      case UserRole.maestro: roleColor = const Color(0xFFF57C00); break;
      case UserRole.seguridad: roleColor = const Color(0xFFFFB300); break;
      default: roleColor = Colors.blueGrey;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? Colors.white10 : Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [roleColor, roleColor.withOpacity(0.6)]),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              user.name[0].toUpperCase(), 
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)
            ),
          ),
        ),
        title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: roleColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: roleColor.withOpacity(0.2)),
              ),
              child: Text(
                user.role.name.toUpperCase(),
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: roleColor, letterSpacing: 0.5),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                user.isActive ? Icons.verified_user_rounded : Icons.block_flipped,
                color: user.isActive ? Colors.green : Colors.red,
              ),
              onPressed: () => _toggleStatus(user),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.settings_suggest_rounded, color: Colors.grey),
              onPressed: () => _showEditDialog(user),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader('NUEVO ACCESO', 'Generar credenciales de comunidad'),
            const SizedBox(height: 32),
            _buildField(controller: _nameController, label: 'Nombre Completo', icon: Icons.person_outline),
            const SizedBox(height: 16),
            _buildField(controller: _emailController, label: 'Correo Electrónico', icon: Icons.alternate_email, type: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _buildField(controller: _passwordController, label: 'Contraseña Temporal', icon: Icons.lock_open_outlined, obscure: true),
            const SizedBox(height: 24),
            const Text('NIVEL DE ACCESO', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5, color: Colors.grey)),
            const SizedBox(height: 10),
            DropdownButtonFormField<UserRole>(
              value: _selectedRole,
              items: UserRole.values.map((role) {
                return DropdownMenuItem(value: role, child: Text(role.name.toUpperCase(), style: const TextStyle(fontSize: 14)));
              }).toList(),
              onChanged: (val) => setState(() => _selectedRole = val!),
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? Colors.white10 : Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 40),
            Container(
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFD32F2F), Color(0xFFF57C00), Color(0xFFFFB300)]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: const Color(0xFFD32F2F).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Registrar Usuario', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2.5, color: Color(0xFFF57C00))),
        const SizedBox(height: 6),
        Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildField({required TextEditingController controller, required String label, required IconData icon, bool obscure = false, TextInputType type = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFF57C00)),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        labelStyle: const TextStyle(fontSize: 14),
      ),
      validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
    );
  }

  void _showEditDialog(UserModel user) {
    final nameEdit = TextEditingController(text: user.name);
    UserRole roleEdit = user.role;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Ajustar Perfil'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameEdit, 
                decoration: const InputDecoration(labelText: 'Nombre Completo', prefixIcon: Icon(Icons.person_outline))
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft, 
                child: Text('Rol en la comunidad:', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold))
              ),
              const SizedBox(height: 8),
              DropdownButton<UserRole>(
                value: roleEdit,
                isExpanded: true,
                underline: Container(height: 2, color: const Color(0xFFF57C00)),
                items: UserRole.values.map((r) => DropdownMenuItem(value: r, child: Text(r.name.toUpperCase()))).toList(),
                onChanged: (v) => setDialogState(() => roleEdit = v!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              onPressed: () async {
                final updated = UserModel(id: user.id, name: nameEdit.text, email: user.email, role: roleEdit, isActive: user.isActive);
                await AuthService().updateUser(updated);
                Navigator.pop(context);
                _fetchUsers();
                _showSuccess('Perfil actualizado correctamente');
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF57C00), foregroundColor: Colors.white),
              child: const Text('GUARDAR CAMBIOS'),
            ),
          ],
        ),
      ),
    );
  }
}
