import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  bool _loading = false;
  bool _mostrarSenha = false;

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _senhaController.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(cred.user!.uid)
          .set({
        'nome': _nomeController.text.trim(),
        'email': _emailController.text.trim(),
        'role': 'usuario',
        'criadoEm': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta criada com sucesso!')),
      );

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoginPage()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar conta: ${e.toString()}')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  InputDecoration _decoracaoCampo(String texto, IconData icone) {
    return InputDecoration(
      hintText: texto,
      prefixIcon: Icon(icone, color: const Color(0xFFF2598C)),
      filled: true,
      fillColor: Colors.black26,
      hintStyle: const TextStyle(color: Colors.white70),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1A2F),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                Image.asset('assets/images/logoArenaNow.png', width: 400),
                const SizedBox(height: 40),
                const Text(
                  'Criar Conta',
                  style: TextStyle(
                      fontSize: 26,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nomeController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _decoracaoCampo('Nome', Icons.person),
                        validator: (v) =>
                            v!.isEmpty ? 'Informe seu nome' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        style: const TextStyle(color: Colors.white),
                        decoration:
                            _decoracaoCampo('E-mail', Icons.email_outlined),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Informe o e-mail';
                          if (!v.contains('@')) return 'E-mail inválido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _senhaController,
                        obscureText: !_mostrarSenha,
                        style: const TextStyle(color: Colors.white),
                        decoration:
                            _decoracaoCampo('Senha', Icons.lock_outline),
                        validator: (v) => v == null || v.length < 6
                            ? 'Mínimo 6 caracteres'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmarSenhaController,
                        obscureText: !_mostrarSenha,
                        style: const TextStyle(color: Colors.white),
                        decoration:
                            _decoracaoCampo('Confirmar senha', Icons.lock),
                        validator: (v) {
                          if (v != _senhaController.text)
                            return 'As senhas não coincidem';
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),
                      _loading
                          ? const CircularProgressIndicator()
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _registrar,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF2598C),
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('Cadastrar'),
                              ),
                            ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Já tem uma conta?',
                            style: TextStyle(color: Colors.white70),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const LoginPage()));
                            },
                            child: const Text(
                              'Entrar',
                              style: TextStyle(
                                color: Color(0xFFF2598C),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
