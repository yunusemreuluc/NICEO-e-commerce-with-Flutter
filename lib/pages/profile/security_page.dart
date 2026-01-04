import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  // ----- Hesap Güvenliği
  bool twoFactor = false;

  // ----- Gizlilik Tercihleri
  bool profileVisibility = false; // Profili diğer kullanıcılar görebilir
  bool orderHistoryPrivate = true; // Sipariş geçmişini gizle
  bool activityTracking = false; // Kişiselleştirilmiş deneyim
  bool dataCollection = true; // Analitik ve iyileştirme
  bool marketingEmails = false; // Kampanya e-postaları

  // ----- Aktif oturumlar (mock)
  final List<_Session> sessions = [
    _Session(
      device: "iPhone 15 Pro",
      location: "İstanbul, TR",
      isCurrent: true,
      lastActive: "Şimdi aktif",
      platform: "ios",
    ),
    _Session(
      device: "Chrome • Windows",
      location: "Ankara, TR",
      isCurrent: false,
      lastActive: "19 dk önce",
      platform: "desktop",
    ),
  ];

  void _endOtherSessions() {
    setState(() {
      sessions.removeWhere((s) => !s.isCurrent);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Diğer tüm oturumlar sonlandırıldı."),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _endSession(int index) {
    final s = sessions[index];
    setState(() {
      sessions.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${s.device} oturumu sonlandırıldı."),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _openChangePassword() async {
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _ChangePasswordDialog(),
    );
    if (ok == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Şifreniz güncellendi."),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hesabımı Sil"),
        content: const Text(
          "Bu işlem geri alınamaz. Hesabını ve ilişkili verileri kalıcı olarak silmek istediğine emin misin?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Vazgeç"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE11D48),
            ),
            child: const Text("Evet, Sil"),
          ),
        ],
      ),
    );
    if (ok == true) {
      // TODO: Silme işlemi
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Hesabınız silinmek üzere işleme alındı."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text(
          "Gizlilik & Güvenlik",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Hesap güvenliği ve gizlilik ayarları",
                style: TextStyle(
                  color: Colors.black.withOpacity(.55),
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          // ----- Hesap Güvenliği
          _SectionCard(
            title: "Hesap Güvenliği",
            icon: Icons.verified_user_outlined,
            children: [
              // Şifremi Değiştir
              SizedBox(
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: _openChangePassword,
                  icon: const Icon(Icons.lock_outline, size: 18),
                  label: const Text("Şifremi Değiştir"),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    foregroundColor: Colors.black87,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // 2FA
              _SwitchTile(
                icon: Icons.phonelink_lock_outlined,
                label: "İki Faktörlü Doğrulama",
                subtitle: "Ek güvenlik katmanı",
                value: twoFactor,
                onChanged: (v) => setState(() => twoFactor = v),
              ),
            ],
          ),

          // ----- Aktif Oturumlar
          _SectionCard(
            title: "Aktif Oturumlar",
            icon: Icons.devices_other_outlined,
            trailing: TextButton(
              onPressed: sessions.where((s) => !s.isCurrent).isEmpty
                  ? null
                  : _endOtherSessions,
              child: const Text("Diğerlerini Sonlandır"),
            ),
            children: [
              ...List.generate(sessions.length, (i) {
                final s = sessions[i];
                return _SessionCard(
                  session: s,
                  onEnd: s.isCurrent ? null : () => _endSession(i),
                );
              }),
            ],
          ),

          // ----- Gizlilik Tercihleri
          _SectionCard(
            title: "Gizlilik Tercihleri",
            icon: Icons.privacy_tip_outlined,
            children: [
              _SwitchTile(
                icon: Icons.visibility_outlined,
                label: "Profil Görünürlüğü",
                subtitle: "Profilinizi diğer kullanıcılar görebilir",
                value: profileVisibility,
                onChanged: (v) => setState(() => profileVisibility = v),
              ),
              _SwitchTile(
                icon: Icons.lock_person_outlined,
                label: "Sipariş Geçmişi Gizliliği",
                subtitle: "Sipariş geçmişinizi gizli tutar",
                value: orderHistoryPrivate,
                onChanged: (v) => setState(() => orderHistoryPrivate = v),
              ),
              _SwitchTile(
                icon: Icons.track_changes_outlined,
                label: "Aktivite Takibi",
                subtitle: "Kişiselleştirilmiş deneyim için",
                value: activityTracking,
                onChanged: (v) => setState(() => activityTracking = v),
              ),
              _SwitchTile(
                icon: Icons.dataset_outlined,
                label: "Veri Toplama",
                subtitle: "Analitik ve iyileştirme amaçlı",
                value: dataCollection,
                onChanged: (v) => setState(() => dataCollection = v),
              ),
              _SwitchTile(
                icon: Icons.mark_email_unread_outlined,
                label: "Pazarlama E-postaları",
                subtitle: "Özel teklifler ve kampanyalar",
                value: marketingEmails,
                onChanged: (v) => setState(() => marketingEmails = v),
              ),
            ],
          ),

          // ----- Veri Yönetimi
          _SectionCard(
            title: "Veri Yönetimi",
            icon: Icons.storage_outlined,
            children: [
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: JSON export
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Verileriniz JSON olarak hazırlanıyor…",
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.download_outlined, size: 18),
                        label: const Text("Verilerimi İndir"),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Format: JSON")),
                        );
                      },
                      child: const Text("JSON Formatında"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: _confirmDeleteAccount,
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Color(0xFFE11D48),
                  ),
                  label: const Text(
                    "Hesabımı Sil",
                    style: TextStyle(color: Color(0xFFE11D48)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFCA5A5)),
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          // ----- Veri Koruma bilgi kutusu
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "🛡️  Veri Koruma",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 8),
                Text("• GDPR ve KVKK uyumlu veri işleme"),
                Text("• Verileriniz 256-bit SSL ile şifrelenir"),
                Text("• Kişisel veriler üçüncü taraflarla paylaşılmaz"),
                Text("• İstediğiniz zaman verilerinizi silebilirsiniz"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ====== Widgets / Modeller ======

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final Widget? trailing;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }
}

class _Session {
  final String device;
  final String location;
  final String lastActive;
  final bool isCurrent;
  final String platform; // ios / android / desktop

  _Session({
    required this.device,
    required this.location,
    required this.lastActive,
    required this.isCurrent,
    required this.platform,
  });
}

class _SessionCard extends StatelessWidget {
  final _Session session;
  final VoidCallback? onEnd;

  const _SessionCard({required this.session, this.onEnd});

  @override
  Widget build(BuildContext context) {
    IconData icon = Icons.devices_other_outlined;
    if (session.platform == "ios") icon = Icons.phone_iphone;
    if (session.platform == "android") icon = Icons.android_outlined;
    if (session.platform == "desktop") icon = Icons.desktop_windows_outlined;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black87),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        session.device,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (session.isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F7EC),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          "Bu Cihaz",
                          style: TextStyle(
                            color: Color(0xFF16A34A),
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  session.location,
                  style: const TextStyle(color: Colors.black54),
                ),
                Text(
                  session.lastActive,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (!session.isCurrent)
            OutlinedButton(
              onPressed: onEnd,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFCA5A5)),
              ),
              child: const Text(
                "Sonlandır",
                style: TextStyle(color: Color(0xFFE11D48)),
              ),
            ),
        ],
      ),
    );
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _oldCtl = TextEditingController();
  final _newCtl = TextEditingController();
  final _repeatCtl = TextEditingController();
  bool _seeOld = false, _seeNew = false, _seeRep = false;
  bool _submitting = false;

  @override
  void dispose() {
    _oldCtl.dispose();
    _newCtl.dispose();
    _repeatCtl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _submitting = true);
    
    try {
      final result = await ApiService.changePassword(
        currentPassword: _oldCtl.text.trim(),
        newPassword: _newCtl.text.trim(),
      );
      
      if (mounted) {
        setState(() => _submitting = false);
        
        if (result['success']) {
          Navigator.pop(context, true);
        } else {
          // Hata mesajını göster
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? 'Şifre değiştirilemedi'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String? _pwdRule(String? v, {bool isOldPassword = false}) {
    v = v?.trim() ?? "";
    if (v.isEmpty) return "Bu alan zorunlu";
    // Mevcut şifre için uzunluk kontrolü yapma, sadece yeni şifre için yap
    if (!isOldPassword && v.length < 8) return "En az 8 karakter olmalı";
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Şifremi Değiştir",
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const SizedBox(height: 12),

              // Eski şifre
              TextFormField(
                controller: _oldCtl,
                obscureText: !_seeOld,
                validator: (v) => _pwdRule(v, isOldPassword: true), // Mevcut şifre için uzunluk kontrolü yok
                decoration: InputDecoration(
                  labelText: "Mevcut Şifre",
                  suffixIcon: IconButton(
                    icon: Icon(
                      _seeOld ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _seeOld = !_seeOld),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Yeni şifre
              TextFormField(
                controller: _newCtl,
                obscureText: !_seeNew,
                validator: (v) => _pwdRule(v, isOldPassword: false), // Yeni şifre için 8 karakter kuralı
                decoration: InputDecoration(
                  labelText: "Yeni Şifre",
                  suffixIcon: IconButton(
                    icon: Icon(
                      _seeNew ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _seeNew = !_seeNew),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Yeni şifre (tekrar)
              TextFormField(
                controller: _repeatCtl,
                obscureText: !_seeRep,
                validator: (v) {
                  final err = _pwdRule(v, isOldPassword: false); // Yeni şifre kuralları
                  if (err != null) return err;
                  if (v!.trim() != _newCtl.text.trim()) {
                    return "Şifreler eşleşmiyor";
                  }
                  if (_oldCtl.text.trim() == _newCtl.text.trim()) {
                    return "Yeni şifre eski şifreyle aynı olamaz";
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: "Yeni Şifre (Tekrar)",
                  suffixIcon: IconButton(
                    icon: Icon(
                      _seeRep ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _seeRep = !_seeRep),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _submitting
                          ? null
                          : () => Navigator.pop(context, false),
                      child: const Text("Vazgeç"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF111827),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text("Şifreyi Güncelle"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
