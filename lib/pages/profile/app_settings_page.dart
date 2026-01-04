import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:niceo/services/app_settings_service.dart';

class AppSettingsPage extends StatelessWidget {
  const AppSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsService>();
    final isTr = settings.locale.languageCode == 'tr';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0B1220)
          : const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: Text(
          isTr ? "Uygulama Ayarları" : "App Settings",
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        elevation: 0.5,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          // === GÖRÜNÜM (sadece tema seçimi) ===
          _CardSection(
            icon: Icons.palette_outlined,
            title: isTr ? "Görünüm" : "Appearance",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionLabel(isTr ? "Tema Seçimi" : "Theme"),
                const SizedBox(height: 6),
                _ThemeRadio(
                  title: isTr ? "Açık Tema" : "Light",
                  icon: Icons.wb_sunny_outlined,
                  value: ThemeMode.light,
                  groupValue: settings.themeMode,
                  onChanged: (v) =>
                      context.read<AppSettingsService>().setThemeMode(v!),
                ),
                _ThemeRadio(
                  title: isTr ? "Koyu Tema" : "Dark",
                  icon: Icons.nightlight_outlined,
                  value: ThemeMode.dark,
                  groupValue: settings.themeMode,
                  onChanged: (v) =>
                      context.read<AppSettingsService>().setThemeMode(v!),
                ),
                _ThemeRadio(
                  title: isTr ? "Sistem Teması" : "System",
                  icon: Icons.devices_other_outlined,
                  value: ThemeMode.system,
                  groupValue: settings.themeMode,
                  onChanged: (v) =>
                      context.read<AppSettingsService>().setThemeMode(v!),
                ),
              ],
            ),
          ),

          // === DİL & BÖLGE ===
          _CardSection(
            icon: Icons.language_outlined,
            title: isTr ? "Dil ve Bölge" : "Language & Region",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionLabel(isTr ? "Dil" : "Language"),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: settings.locale.languageCode,
                  items: [
                    DropdownMenuItem(
                      value: 'tr',
                      child: Text(isTr ? 'Türkçe' : 'Turkish'),
                    ),
                    DropdownMenuItem(
                      value: 'en',
                      child: Text(isTr ? 'İngilizce' : 'English'),
                    ),
                  ],
                  onChanged: (code) {
                    if (code == null) return;
                    context.read<AppSettingsService>().setLocale(Locale(code));
                  },
                  decoration: _ddDecoration(isDark),
                ),
                const SizedBox(height: 12),
                _SectionLabel(isTr ? "Para Birimi" : "Currency"),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: settings.currency,
                  items: const [
                    DropdownMenuItem(
                      value: 'TRY',
                      child: Text('Türk Lirası (₺)'),
                    ),
                    DropdownMenuItem(
                      value: 'USD',
                      child: Text('US Dollar (\$)'),
                    ),
                    DropdownMenuItem(value: 'EUR', child: Text('Euro (€)')),
                  ],
                  onChanged: (c) => context
                      .read<AppSettingsService>()
                      .setCurrency(c ?? 'TRY'),
                  decoration: _ddDecoration(isDark),
                ),
              ],
            ),
          ),

          // === DAVRANIŞ ===
          _CardSection(
            icon: Icons.tune,
            title: isTr ? "Uygulama Davranışı" : "App Behavior",
            child: Column(
              children: [
                _ToggleRow(
                  title: isTr ? "Titreşim" : "Vibration",
                  value: settings.haptics,
                  onChanged: (v) =>
                      context.read<AppSettingsService>().setHaptics(v),
                ),
                _ToggleRow(
                  title: isTr ? "Ses Efektleri" : "Sound Effects",
                  value: settings.sfx,
                  onChanged: (v) =>
                      context.read<AppSettingsService>().setSfx(v),
                ),
                _ToggleRow(
                  title: isTr ? "Otomatik Güncelleme" : "Auto Update",
                  value: settings.autoUpdate,
                  onChanged: (v) =>
                      context.read<AppSettingsService>().setAutoUpdate(v),
                ),
              ],
            ),
          ),

          // === FOOTER ===
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            child: const Padding(
              padding: EdgeInsets.all(14),
              child: Column(
                children: [
                  Text(
                    "NICEO v2.1.0",
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Made with ❤️ in Turkey",
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _ddDecoration(bool isDark) {
    return InputDecoration(
      filled: true,
      fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF22314B) : const Color(0xFFE9ECEF),
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF22314B) : const Color(0xFFE9ECEF),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
      ),
    );
  }
}

/* --- Küçük Bileşenler --- */

class _CardSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  const _CardSection({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isDark ? const Color(0xFF0F172A) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        color: isDark ? Colors.white70 : Colors.black54,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _ThemeRadio extends StatelessWidget {
  final String title;
  final IconData icon;
  final ThemeMode value;
  final ThemeMode groupValue;
  final ValueChanged<ThemeMode?> onChanged;

  const _ThemeRadio({
    required this.title,
    required this.icon,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return RadioListTile<ThemeMode>(
      dense: true,
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      title: Row(
        children: [
          Icon(icon, size: 18, color: isDark ? Colors.white : Colors.black87),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleRow({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
      ),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }
}
