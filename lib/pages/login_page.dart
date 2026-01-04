// lib/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'signup_page.dart';
import 'main_layout.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool hide = true;
  bool loading = false;
  bool googleLoading = false;
  bool appleLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthService>(context, listen: false);
      final saved = auth.savedEmail;
      if (saved != null && saved.isNotEmpty) {
        emailCtrl.text = saved;
      }
    });
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleEmailLogin(AuthService auth) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);
    try {
      final email = emailCtrl.text.trim();
      final ok = await auth.loginWithEmail(email, passCtrl.text.trim());
      if (!mounted) return;
      if (ok) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainLayout()),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Giriş başarısız.')));
      }
    } catch (e, st) {
      debugPrint('Email login error: $e\n$st');
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Giriş sırasında hata')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // <<< DEĞİŞTİ: mock login çağırılıyor
  Future<void> _handleGoogleLogin(AuthService auth) async {
    if (googleLoading) return;
    setState(() => googleLoading = true);
    try {
      // burada demo/mock method çağrılıyor — gerçek OAuth yerine anında giriş sağlar
      final ok = await auth.loginWithGoogleMock();
      if (!mounted) return;
      if (ok) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainLayout()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google ile giriş başarısız.')),
        );
      }
    } catch (e, st) {
      debugPrint('Google login error: $e\n$st');
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google giriş sırasında hata')),
        );
    } finally {
      if (mounted) setState(() => googleLoading = false);
    }
  }

  Future<void> _handleAppleLogin(AuthService auth) async {
    if (appleLoading) return;
    setState(() => appleLoading = true);
    try {
      final ok = await auth.loginWithApple();
      if (!mounted) return;
      if (ok) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainLayout()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Apple ile giriş başarısız.')),
        );
      }
    } catch (e, st) {
      debugPrint('Apple login error: $e\n$st');
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Apple giriş sırasında hata')),
        );
    } finally {
      if (mounted) setState(() => appleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7A5CFF), Color(0xFF6EE7B7)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 10),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'NICEO',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Alışverişin yeni adresi',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 18),

                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 420),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 18),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const Text(
                            'Tekrar Hoş Geldin!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Hesabına giriş yap ve alışverişe devam et',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 14),

                          TextFormField(
                            controller: emailCtrl,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.email),
                              labelText: 'E-posta Adresi',
                              hintText: 'ornekk@email.com',
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return 'E-posta gerekli';
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v))
                                return 'Geçerli e-posta girin';
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          TextFormField(
                            controller: passCtrl,
                            obscureText: hide,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock),
                              labelText: 'Şifre',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  hide
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () => setState(() => hide = !hide),
                              ),
                            ),
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Şifre gerekli'
                                : null,
                          ),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                /* forgot */
                              },
                              child: const Text('Şifremi Unuttum'),
                            ),
                          ),

                          const SizedBox(height: 8),

                          GestureDetector(
                            onTap: () => _handleEmailLogin(auth),
                            child: Container(
                              height: 48,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF6D5BFF),
                                    Color(0xFF8A3CF5),
                                  ],
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    blurRadius: 8,
                                    color: Colors.black12,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: loading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text(
                                        'Giriş Yap',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),
                          Row(
                            children: const [
                              Expanded(child: Divider()),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Text('veya'),
                              ),
                              Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: 12),

                          OutlinedButton.icon(
                            onPressed: googleLoading
                                ? null
                                : () => _handleGoogleLogin(auth),
                            icon: googleLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.g_mobiledata),
                            label: const Text('Google ile Devam Et'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                            ),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: appleLoading
                                ? null
                                : () => _handleAppleLogin(auth),
                            icon: appleLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.apple),
                            label: const Text('Apple ile Devam Et'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                            ),
                          ),

                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Hesabın yok mu? '),
                              GestureDetector(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const SignUpPage(),
                                  ),
                                ),
                                child: const Text(
                                  'Hemen Kayıt Ol',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
