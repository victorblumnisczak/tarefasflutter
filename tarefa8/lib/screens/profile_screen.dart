import 'package:flutter/material.dart';
import '../models/auth_user.dart';
import '../services/auth_service.dart';
import '../session/session_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final Future<AuthUser>? _future;

  @override
  void initState() {
    super.initState();
    final token = SessionController.instance.token;
    if (token != null) {
      _future = AuthService().fetchProfile(token);
    } else {
      _future = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: _future == null
          ? const Center(
              child: Text('Sessão não encontrada. Faça login novamente.'),
            )
          : FutureBuilder<AuthUser>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Erro ao carregar perfil: ${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: Text('Perfil não disponível.'));
                }

                final user = snapshot.data!;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      CircleAvatar(
                        radius: 56,
                        backgroundImage: NetworkImage(user.image),
                        onBackgroundImageError: (_, __) {},
                      ),
                      const SizedBox(height: 20),
                      Text(
                        user.fullName,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      _InfoTile(
                        icon: Icons.person_outline,
                        label: 'Usuário',
                        value: user.username,
                      ),
                      _InfoTile(
                        icon: Icons.email_outlined,
                        label: 'E-mail',
                        value: user.email,
                      ),
                      _InfoTile(
                        icon: Icons.tag,
                        label: 'ID',
                        value: user.id.toString(),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
        subtitle: Text(value, style: theme.textTheme.bodyLarge),
      ),
    );
  }
}
