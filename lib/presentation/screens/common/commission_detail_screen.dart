import 'package:flutter/material.dart';
import '../../../domain/models/commission_model.dart';
import '../../../domain/models/app_content_model.dart';
import '../../../domain/models/user_model.dart';
import '../../../services/app_content_service.dart';
import '../../../services/auth_service.dart';

class CommissionDetailScreen extends StatefulWidget {
  final int index;
  final CommissionModel commission;

  const CommissionDetailScreen({
    Key? key,
    required this.index,
    required this.commission,
  }) : super(key: key);

  @override
  State<CommissionDetailScreen> createState() => _CommissionDetailScreenState();
}

class _CommissionDetailScreenState extends State<CommissionDetailScreen> {
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

  void _editField(String title, String currentText, bool isMission) {
    final controller = TextEditingController(text: currentText);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar $title'),
        content: TextField(
          controller: controller,
          maxLines: 8,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          ElevatedButton(
            onPressed: () async {
              final updated = CommissionModel(
                id: widget.commission.id,
                name: widget.commission.name,
                mission: isMission ? controller.text : widget.commission.mission,
                function: !isMission ? controller.text : widget.commission.function,
                imageUrl: widget.commission.imageUrl,
              );
              await _contentService.updateCommission(widget.index, updated);
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
        // Obtenemos la versión más reciente de la comisión desde el stream
        CommissionModel currentComm = widget.commission;
        if (snapshot.hasData && snapshot.data!.commissions.length > widget.index) {
          currentComm = snapshot.data!.commissions[widget.index];
        }

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(currentComm.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentComm.name,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 50,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD32F2F),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 40),

                // Misión Section
                _buildInfoSection(
                  context,
                  title: 'MISIÓN',
                  content: currentComm.mission,
                  icon: Icons.flag_rounded,
                  onEdit: () => _editField('Misión', currentComm.mission, true),
                ),
                const SizedBox(height: 40),

                // Función Section
                _buildInfoSection(
                  context,
                  title: 'FUNCIÓN',
                  content: currentComm.function,
                  icon: Icons.settings_suggest_rounded,
                  onEdit: () => _editField('Función', currentComm.function, false),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildInfoSection(BuildContext context, {
    required String title, 
    required String content, 
    required IconData icon,
    required VoidCallback onEdit,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFFD32F2F), size: 20),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: Color(0xFFD32F2F),
              ),
            ),
            const Spacer(),
            if (_isAdmin)
              IconButton(
                icon: const Icon(Icons.edit, size: 20, color: Colors.blueAccent),
                onPressed: onEdit,
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 18,
            height: 1.6,
            color: isDark ? Colors.white70 : Colors.black54,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
