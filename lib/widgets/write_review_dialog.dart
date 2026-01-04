import 'package:flutter/material.dart';

class WriteReviewResult {
  final int stars;
  final String title;
  final String body;
  WriteReviewResult({
    required this.stars,
    required this.title,
    required this.body,
  });
}

class WriteReviewDialog extends StatefulWidget {
  final int? initialStars;
  final String? initialTitle;
  final String? initialBody;

  const WriteReviewDialog({
    super.key,
    this.initialStars,
    this.initialTitle,
    this.initialBody,
  });

  @override
  State<WriteReviewDialog> createState() => _WriteReviewDialogState();
}

class _WriteReviewDialogState extends State<WriteReviewDialog> {
  late int _stars;
  final _title = TextEditingController();
  final _body = TextEditingController();

  @override
  void initState() {
    super.initState();
    _stars = widget.initialStars ?? 5;
    _title.text = widget.initialTitle ?? '';
    _body.text = widget.initialBody ?? '';
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Değerlendirme Yaz',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Stars
                Row(
                  children: List.generate(
                    5,
                    (i) => IconButton(
                      iconSize: 28,
                      splashRadius: 20,
                      onPressed: () => setState(() => _stars = i + 1),
                      icon: Icon(
                        i < _stars
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: const Color(0xFFFFB800),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Title
                TextField(
                  controller: _title,
                  decoration: InputDecoration(
                    labelText: 'Başlık',
                    hintText: 'Deneyiminizi özetleyin',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Body
                TextField(
                  controller: _body,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Yorumunuz',
                    hintText: 'Ürün hakkında detaylı yorumunuzu yazın…',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('İptal'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (_title.text.trim().isEmpty ||
                              _body.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Başlık ve yorum zorunludur.'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }
                          Navigator.pop(
                            context,
                            WriteReviewResult(
                              stars: _stars,
                              title: _title.text.trim(),
                              body: _body.text.trim(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                        ),
                        label: const Text('Gönder'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
