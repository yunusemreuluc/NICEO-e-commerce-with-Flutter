// lib/pages/signup_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../services/auth_service.dart';
import 'main_layout.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController surnameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  final TextEditingController pass2Ctrl = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool accepted = false;
  bool hide = true;
  bool loading = false;
  bool googleLoading = false;
  bool appleLoading = false;

  @override
  void initState() {
    super.initState();
    // Eğer AuthService'de saklı e-posta varsa ön-doldurmak için
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
    nameCtrl.dispose();
    surnameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    passCtrl.dispose();
    pass2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _handleRegister(AuthService auth) async {
    if (!_formKey.currentState!.validate()) return;
    if (!accepted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sözleşmeyi kabul edin')));
      return;
    }
    if (loading) return;
    setState(() => loading = true);
    try {
      final newUser = User(
        name: nameCtrl.text.trim(),
        surname: surnameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        phone: phoneCtrl.text.replaceAll(' ', '').trim(), // Remove spaces from formatted phone
        password: passCtrl.text.trim(),
      );

      final bool ok = await auth.register(newUser);
      if (!mounted) return;
      if (ok) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainLayout()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kayıt başarısız veya e-posta zaten kayıtlı.'),
          ),
        );
      }
    } catch (e, st) {
      debugPrint('Signup error: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kayıt sırasında hata oluştu')),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _handleGoogleSignUp(AuthService auth) async {
    if (googleLoading) return;
    setState(() => googleLoading = true);
    try {
      // Geçici/demo: doğrudan mock giriş yapar. Gerçek OAuth için loginWithGoogle() kullan.
      final bool ok = await auth.loginWithGoogleMock();
      if (!mounted) return;
      if (ok) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainLayout()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google ile kayıt başarısız.')),
        );
      }
    } catch (e, st) {
      debugPrint('Google signup error: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google kayıt sırasında hata')),
        );
      }
    } finally {
      if (mounted) setState(() => googleLoading = false);
    }
  }

  Future<void> _handleAppleSignUp(AuthService auth) async {
    if (appleLoading) return;
    setState(() => appleLoading = true);
    try {
      final bool ok = await auth.loginWithApple();
      if (!mounted) return;
      if (ok) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainLayout()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Apple ile kayıt başarısız.')),
        );
      }
    } catch (e, st) {
      debugPrint('Apple signup error: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Apple kayıt sırasında hata')),
        );
      }
    } finally {
      if (mounted) setState(() => appleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthService auth = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 24),
                const Text(
                  'Hesap Oluştur',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 420),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(blurRadius: 18, color: Colors.black12),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: TextFormField(
                                controller: nameCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Ad',
                                ),
                                validator: (String? v) {
                                  if (v == null || v.isEmpty)
                                    return 'Ad gerekli';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: surnameCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Soyad',
                                ),
                                validator: (String? v) {
                                  if (v == null || v.isEmpty)
                                    return 'Soyad gerekli';
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        TextFormField(
                          controller: emailCtrl,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.email),
                            labelText: 'E-posta Adresi',
                            hintText: 'ornek@email.com',
                          ),
                          validator: (String? v) {
                            if (v == null || v.isEmpty)
                              return 'E-posta gerekli';
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v))
                              return 'Geçerli e-posta girin';
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),

                        TextFormField(
                          controller: phoneCtrl,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(11),
                            TextInputFormatter.withFunction((oldValue, newValue) {
                              String text = newValue.text;
                              if (text.length >= 1 && !text.startsWith('0')) {
                                text = '0$text';
                              }
                              if (text.length >= 4) {
                                text = '${text.substring(0, 4)} ${text.substring(4)}';
                              }
                              if (text.length >= 8) {
                                text = '${text.substring(0, 8)} ${text.substring(8)}';
                              }
                              if (text.length >= 11) {
                                text = '${text.substring(0, 11)} ${text.substring(11)}';
                              }
                              return TextEditingValue(
                                text: text,
                                selection: TextSelection.collapsed(offset: text.length),
                              );
                            }),
                          ],
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.phone),
                            labelText: 'Telefon Numarası',
                            hintText: '0555 555 55 55',
                          ),
                          validator: (String? v) {
                            if (v == null || v.isEmpty)
                              return 'Telefon numarası gerekli';
                            String cleanPhone = v.replaceAll(' ', '');
                            if (cleanPhone.length != 11)
                              return 'Telefon numarası 11 haneli olmalı';
                            if (!cleanPhone.startsWith('0'))
                              return 'Telefon numarası 0 ile başlamalı';
                            return null;
                          },
                        ),

                        const SizedBox(height: 10),
                        TextFormField(
                          controller: passCtrl,
                          obscureText: hide,
                          decoration: InputDecoration(
                            labelText: 'Şifre (en az 6 karakter)',
                            suffixIcon: IconButton(
                              icon: Icon(
                                hide ? Icons.visibility_off : Icons.visibility,
                              ),
                              onPressed: () => setState(() => hide = !hide),
                            ),
                          ),
                          validator: (String? v) {
                            if (v == null || v.isEmpty) return 'Şifre gerekli';
                            if (v.length < 6)
                              return 'Şifre en az 6 karakter olmalı';
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: pass2Ctrl,
                          obscureText: hide,
                          decoration: const InputDecoration(
                            labelText: 'Şifre Tekrarı',
                          ),
                          validator: (String? v) {
                            if (v == null || v.isEmpty)
                              return 'Tekrar şifre gerekli';
                            if (v != passCtrl.text) return 'Şifreler uyuşmuyor';
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),

                        Row(
                          children: <Widget>[
                            Checkbox(
                              value: accepted,
                              onChanged: (bool? v) =>
                                  setState(() => accepted = v ?? false),
                            ),
                            const Expanded(
                              child: Text(
                                'Kullanım Şartları ve Gizlilik Politikasını okudum ve kabul ediyorum.',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        ElevatedButton(
                          onPressed: loading
                              ? null
                              : () => _handleRegister(auth),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Hesap Oluştur'),
                        ),

                        const SizedBox(height: 10),
                        const Text('veya'),
                        const SizedBox(height: 8),

                        OutlinedButton.icon(
                          onPressed: googleLoading
                              ? null
                              : () => _handleGoogleSignUp(auth),
                          icon: googleLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.g_mobiledata),
                          label: const Text('Google ile Kayıt Ol'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                          ),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: appleLoading
                              ? null
                              : () => _handleAppleSignUp(auth),
                          icon: appleLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.apple),
                          label: const Text('Apple ile Kayıt Ol'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                          ),
                        ),

                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Text('Zaten hesabın var mı? '),
                            GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: const Text(
                                'Giriş Yap',
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
    );
  }
}
