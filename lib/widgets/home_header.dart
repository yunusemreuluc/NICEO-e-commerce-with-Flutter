import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:niceo/services/notification_service.dart';
import 'package:niceo/pages/profile/notifications_page.dart';
import 'package:niceo/services/app_settings_service.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    // Bildirim sayısı
    final unread = context.watch<NotificationService>().unreadCount;

    // Dil (yalnızca dil değişince rebuild)
    final isTr = context.select<AppSettingsService, bool>(
      (s) => s.locale.languageCode == 'tr',
    );

    // Tema renkleri
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor =
        theme.appBarTheme.backgroundColor ?? theme.cardColor; // header zemini
    final borderColor = theme.dividerColor;
    final softBg =
        theme.inputDecorationTheme.fillColor ??
        (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FA));
    final muted = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6C757D);
    final primaryText = isDark ? Colors.white : Colors.black;

    return SafeArea(
      bottom: false,
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          boxShadow: isDark
              ? const []
              : const [
                  BoxShadow(
                    color: Color(0xFFF0F0F0),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 12,
                left: 20,
                right: 20,
                bottom: 8,
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 0, 0, 0),
                          Color.fromARGB(255, 42, 38, 39),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: isDark
                          ? const []
                          : [
                              BoxShadow(
                                color: const Color.fromARGB(
                                  255,
                                  0,
                                  0,
                                  0,
                                ).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: const CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.transparent,
                      child: Text(
                        "N",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "NICEO",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: primaryText,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Spacer(),

                  // 🔔 Bildirimler — provider’dan sayı + sayfaya yönlendirme
                  _BadgeIcon(
                    icon: Icons.notifications_none_rounded,
                    count: unread,
                    color: const Color(0xFFFF6B81),
                    softBg: softBg,
                    borderColor: borderColor,
                    iconColor: primaryText,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationsPage(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(width: 16),
                  _BadgeIcon(
                    icon: Icons.message_outlined,
                    count: 5,
                    color: Colors.black87,
                    softBg: softBg,
                    borderColor: borderColor,
                    iconColor: primaryText,
                  ),
                  const SizedBox(width: 16),
                  _BadgeIcon(
                    icon: Icons.shopping_bag_outlined,
                    count: 2,
                    color: const Color(0xFF6B5B95),
                    softBg: softBg,
                    borderColor: borderColor,
                    iconColor: primaryText,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: softBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 1),
                  boxShadow: isDark
                      ? const []
                      : [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: isTr
                        ? "Ne arıyorsun?"
                        : "What are you looking for?",
                    prefixIcon: Icon(Icons.search, color: muted, size: 22),
                    hintStyle: TextStyle(color: muted, fontSize: 16),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeIcon extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color color;
  final Color softBg;
  final Color borderColor;
  final Color iconColor;
  final VoidCallback? onTap;

  const _BadgeIcon({
    required this.icon,
    required this.count,
    required this.color,
    required this.softBg,
    required this.borderColor,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: softBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Icon(icon, size: 24, color: iconColor),
          ),
        ),
        if (count > 0)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                "$count",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
