import 'package:flutter/material.dart';

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  int tab = 0; // 0: SSS, 1: Taleplerim, 2: İletişim
  final TextEditingController _searchCtl = TextEditingController();

  // --------- SSS (FAQ) veri
  final List<_FaqCategory> _faq = [
    _FaqCategory(
      title: "Sipariş ve Teslimat",
      items: [
        "Siparişimi nasıl takip edebilirim?",
        "Kargo ücreti ne kadar?",
        "Teslimat süresi ne kadar?",
      ],
    ),
    _FaqCategory(
      title: "Ödeme ve Faturalama",
      items: [
        "Hangi ödeme yöntemlerini kabul ediyorsunuz?",
        "Taksit seçenekleri nelerdir?",
        "Fatura nasıl alırım?",
      ],
    ),
    _FaqCategory(
      title: "İade ve Değişim",
      items: [
        "İade koşulları nelerdir?",
        "İade süreci nasıl işler?",
        "İade ücreti kim karşılar?",
      ],
    ),
  ];

  // --------- Ticket veri (mock)
  final List<_Ticket> _tickets = [
    _Ticket(
      id: "TIC-2024-001",
      title: "Sipariş iptali talebi",
      category: "Sipariş",
      priority: _Priority.normal,
      createdAt: DateTime(2024, 1, 25),
      status: _TicketStatus.open,
    ),
    _Ticket(
      id: "TIC-2024-002",
      title: "Ürün iade işlemi",
      category: "İade",
      priority: _Priority.high,
      createdAt: DateTime(2024, 1, 23),
      status: _TicketStatus.resolved,
    ),
  ];

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  // Yeni ticket oluştur
  Future<void> _openCreateTicket() async {
    final t = await showDialog<_Ticket>(
      context: context,
      builder: (_) => const _CreateTicketDialog(),
    );
    if (t != null) {
      setState(() {
        _tickets.insert(0, t);
        tab = 1; // Taleplerim sekmesine geç
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Destek talebiniz oluşturuldu."),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredFaq = _filteredFaq();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text(
          "Yardım Merkezi",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: _openCreateTicket,
              icon: const Icon(
                Icons.send_rounded,
                size: 16,
                color: Colors.white,
              ),
              label: const Text(
                "Ticket",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B0D17),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Size nasıl yardımcı olabiliriz?",
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
          // Sekmeler
          Row(
            children: [
              _TabPill(
                icon: Icons.help_outline_rounded,
                label: "SSS",
                selected: tab == 0,
                onTap: () => setState(() => tab = 0),
              ),
              const SizedBox(width: 8),
              _TabPill(
                icon: Icons.task_alt_outlined,
                label: "Taleplerim",
                selected: tab == 1,
                onTap: () => setState(() => tab = 1),
              ),
              const SizedBox(width: 8),
              _TabPill(
                icon: Icons.phone_in_talk_outlined,
                label: "İletişim",
                selected: tab == 2,
                onTap: () => setState(() => tab = 2),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // İçerik
          if (tab == 0) ...[
            // Arama
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: _searchCtl,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: "Sorunuzu arayın...",
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Color(0xFF6B7280)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...filteredFaq.map((c) => _FaqCard(category: c)),
          ] else if (tab == 1) ...[
            ..._tickets.map(
              (t) => _TicketCard(
                t: t,
                onReply: t.status == _TicketStatus.open
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Mesaj gönderme ekranı yakında."),
                          ),
                        );
                      }
                    : null,
              ),
            ),
          ] else ...[
            // İletişim
            _ContactCard(),
            const SizedBox(height: 10),
            _InfoBox(),
          ],
        ],
      ),
    );
  }

  List<_FaqCategory> _filteredFaq() {
    final q = _searchCtl.text.trim().toLowerCase();
    if (q.isEmpty) return _faq;
    return _faq
        .map((cat) {
          final items = cat.items
              .where((e) => e.toLowerCase().contains(q))
              .toList();
          if (items.isEmpty) return null;
          return _FaqCategory(title: cat.title, items: items);
        })
        .whereType<_FaqCategory>()
        .toList();
  }
}

// =================== Widgets ===================

class _TabPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabPill({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      selected: selected,
      onSelected: (_) => onTap(),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: selected ? Colors.white : Colors.black87),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selectedColor: const Color(0xFF111827),
      backgroundColor: const Color(0xFFF3F4F6),
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black87,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    );
  }
}

// ---- SSS

class _FaqCategory {
  final String title;
  final List<String> items;
  _FaqCategory({required this.title, required this.items});
}

class _FaqCard extends StatelessWidget {
  final _FaqCategory category;
  const _FaqCard({required this.category});

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
                const Icon(Icons.help_outline_rounded, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    category.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...category.items.map(
              (q) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(q),
                        content: const Text(
                          "Bu maddeye ait açıklama içerikleri burada gösterilecek. "
                          "İçerikleri CMS/remote kaynaktan doldurabilirsiniz.",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Kapat"),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(q)),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.black45,
                        ),
                      ],
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

// ---- Taleplerim (Tickets)

enum _TicketStatus { open, resolved }

enum _Priority { low, normal, high }

class _Ticket {
  final String id;
  final String title;
  final String category;
  final _Priority priority;
  final DateTime createdAt;
  final _TicketStatus status;

  _Ticket({
    required this.id,
    required this.title,
    required this.category,
    required this.priority,
    required this.createdAt,
    required this.status,
  });
}

class _TicketCard extends StatelessWidget {
  final _Ticket t;
  final VoidCallback? onReply;
  const _TicketCard({required this.t, this.onReply});

  @override
  Widget build(BuildContext context) {
    final date =
        "${t.createdAt.day.toString().padLeft(2, '0')}.${t.createdAt.month.toString().padLeft(2, '0')}.${t.createdAt.year}";
    final statusColor = t.status == _TicketStatus.open
        ? const Color(0xFF60A5FA)
        : const Color(0xFF10B981);
    final statusText = t.status == _TicketStatus.open ? "Açık" : "Çözüldü";

    Color badgeColor(_Priority p) {
      return switch (p) {
        _Priority.low => const Color(0xFF86EFAC),
        _Priority.normal => const Color(0xFFBFDBFE),
        _Priority.high => const Color(0xFFFECACA),
      };
    }

    String badgeText(_Priority p) {
      return switch (p) {
        _Priority.low => "Düşük Öncelik",
        _Priority.normal => "Normal Öncelik",
        _Priority.high => "Yüksek Öncelik",
      };
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst satır
            Row(
              children: [
                Expanded(
                  child: Text(
                    t.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text("#${t.id}", style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 10),
            // Etiketler
            Wrap(
              spacing: 8,
              runSpacing: -6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _chip(
                  text: t.category,
                  color: const Color(0xFFE5E7EB),
                  textColor: Colors.black87,
                ),
                _chip(
                  text: badgeText(t.priority),
                  color: badgeColor(t.priority),
                ),
                Text(date, style: const TextStyle(color: Colors.black45)),
              ],
            ),
            const SizedBox(height: 12),
            // Aksiyonlar
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Detay sayfası yakında.")),
                      );
                    },
                    child: const Text("Detayları Gör"),
                  ),
                ),
                const SizedBox(width: 10),
                if (onReply != null)
                  OutlinedButton(
                    onPressed: onReply,
                    child: const Text("Yanıtla"),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip({required String text, required Color color, Color? textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor ?? Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

// ---- İletişim

class _ContactCard extends StatelessWidget {
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
              children: const [
                Icon(Icons.support_agent, size: 18),
                SizedBox(width: 6),
                Text(
                  "7/24 Müşteri Hizmetleri",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _contactTile(
              icon: Icons.chat_bubble_outline,
              label: "Canlı Destek",
              trailing: _badge("Çevrimiçi", const Color(0xFF10B981)),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Canlı destek yakında.")),
                );
              },
            ),
            _contactTile(
              icon: Icons.phone_outlined,
              label: "0850 123 45 67",
              helper: "Hafta içi 09:00–18:00",
            ),
            _contactTile(
              icon: Icons.mail_outline,
              label: "destek@niceo.com",
              helper: "24 saat içinde yanıt",
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactTile({
    required IconData icon,
    required String label,
    String? helper,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon),
        title: Text(label),
        subtitle: helper == null ? null : Text(helper),
        trailing: trailing,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      ),
    );
  }

  static Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
            "ℹ️  Yanıt Süreleri",
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 8),
          Text("• Canlı Destek: Anında"),
          Text("• Telefon: Ortalama 2 dakika"),
          Text("• E-posta: 6–24 saat"),
          Text("• Destek Talebi: 24–48 saat"),
        ],
      ),
    );
  }
}

// ---- Ticket oluşturma diyaloğu

class _CreateTicketDialog extends StatefulWidget {
  const _CreateTicketDialog();

  @override
  State<_CreateTicketDialog> createState() => _CreateTicketDialogState();
}

class _CreateTicketDialogState extends State<_CreateTicketDialog> {
  final _formKey = GlobalKey<FormState>();
  final _subjectCtl = TextEditingController();
  final _descCtl = TextEditingController();
  String _category = "Sipariş ve Teslimat";
  bool _sending = false;

  @override
  void dispose() {
    _subjectCtl.dispose();
    _descCtl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);
    await Future.delayed(const Duration(milliseconds: 700)); // mock
    if (!mounted) return;
    final now = DateTime.now();
    final id = "TIC-${now.year}-${now.millisecond.toString().padLeft(3, '0')}";
    Navigator.pop(
      context,
      _Ticket(
        id: id,
        title: _subjectCtl.text.trim(),
        category: _shortCategory(_category),
        priority: _Priority.normal,
        createdAt: now,
        status: _TicketStatus.open,
      ),
    );
  }

  String _shortCategory(String full) {
    if (full.startsWith("Sipariş")) return "Sipariş";
    if (full.startsWith("Ödeme")) return "Ödeme";
    if (full.startsWith("İade")) return "İade";
    return "Destek";
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Destek Talebi Oluştur",
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _subjectCtl,
                decoration: InputDecoration(
                  labelText: "Konu",
                  hintText: "Sorununuzu özetleyin",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? "Bu alan zorunlu" : null,
              ),
              const SizedBox(height: 10),

              // Kategori dropdown
              DropdownButtonFormField<String>(
                value: _category,
                items: const [
                  DropdownMenuItem(
                    value: "Sipariş ve Teslimat",
                    child: Text("Sipariş ve Teslimat"),
                  ),
                  DropdownMenuItem(
                    value: "Ödeme ve Faturalama",
                    child: Text("Ödeme ve Faturalama"),
                  ),
                  DropdownMenuItem(
                    value: "İade ve Değişim",
                    child: Text("İade ve Değişim"),
                  ),
                ],
                onChanged: (v) => setState(() => _category = v ?? _category),
                decoration: InputDecoration(
                  labelText: "Kategori",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _descCtl,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: "Açıklama",
                  hintText: "Sorununuzu detaylı olarak açıklayın…",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? "Bu alan zorunlu" : null,
              ),
              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: _sending ? null : _submit,
                  icon: _sending
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                  label: const Text(
                    "Ticket Gönder",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B0D17),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
