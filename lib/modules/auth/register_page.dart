import 'package:flutter/material.dart';
import 'package:arenanow/modules/auth/auth_service.dart';
import 'package:arenanow/widgets/custom_textfield.dart';

class RegisterPage extends StatelessWidget {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Conta')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomTextField(controller: _emailController, labelText: 'Email'),
            const SizedBox(height: 10),
            CustomTextField(
                controller: _passwordController,
                labelText: 'Senha',
                obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  final user = await _authService.register(
                    _emailController.text,
                    _passwordController.text,
                  );
                  if (user != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Conta criada com sucesso!')),
                    );
                    Navigator.pop(context);
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao criar conta: $e')),
                  );
                }
              },
              child: const Text('Registrar'),
            ),
          ],
        ),
      ),
    );
  }
}
