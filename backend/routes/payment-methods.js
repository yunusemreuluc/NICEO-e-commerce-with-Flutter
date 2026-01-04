const express = require('express');
const { getPool } = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Kullanıcının ödeme yöntemlerini getir
router.get('/', authenticateToken, async (req, res) => {
  try {
    const pool = getPool();
    const [paymentMethods] = await pool.execute(
      'SELECT id, card_name, card_last4, card_type, is_default, created_at FROM payment_methods WHERE user_id = ? ORDER BY is_default DESC, created_at DESC',
      [req.user.userId]
    );

    res.json({ payment_methods: paymentMethods });
  } catch (error) {
    console.error('Get payment methods error:', error);
    res.status(500).json({ error: 'Ödeme yöntemleri alınamadı' });
  }
});

// Yeni ödeme yöntemi ekle
router.post('/', authenticateToken, async (req, res) => {
  try {
    const { card_name, card_number, card_type, is_default } = req.body;
    const pool = getPool();

    // Kart numarasının son 4 hanesini al
    const card_last4 = card_number.slice(-4);

    // Eğer varsayılan kart ise, diğerlerini varsayılan olmaktan çıkar
    if (is_default) {
      await pool.execute(
        'UPDATE payment_methods SET is_default = 0 WHERE user_id = ?',
        [req.user.userId]
      );
    }

    const [result] = await pool.execute(
      'INSERT INTO payment_methods (user_id, card_name, card_last4, card_type, is_default) VALUES (?, ?, ?, ?, ?)',
      [req.user.userId, card_name, card_last4, card_type, is_default ? 1 : 0]
    );

    res.status(201).json({
      message: 'Ödeme yöntemi eklendi',
      payment_method: {
        id: result.insertId,
        card_name,
        card_last4,
        card_type,
        is_default
      }
    });
  } catch (error) {
    console.error('Add payment method error:', error);
    res.status(500).json({ error: 'Ödeme yöntemi eklenemedi' });
  }
});

module.exports = router;