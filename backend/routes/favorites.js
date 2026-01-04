const express = require('express');
const { getPool } = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Kullanıcının favorilerini getir
router.get('/', authenticateToken, async (req, res) => {
  try {
    const pool = getPool();
    const [favorites] = await pool.execute(
      `SELECT f.*, p.name, p.price, p.old_price, p.brand, p.image_url, p.rating, p.review_count
       FROM favorites f
       JOIN products p ON f.product_id = p.id
       WHERE f.user_id = ? AND p.is_active = TRUE
       ORDER BY f.created_at DESC`,
      [req.user.userId]
    );

    res.json({ favorites });
  } catch (error) {
    console.error('Get favorites error:', error);
    res.status(500).json({ error: 'Favoriler alınamadı' });
  }
});

// Favorilere ekle
router.post('/', authenticateToken, async (req, res) => {
  try {
    const { product_id } = req.body;
    const pool = getPool();

    await pool.execute(
      'INSERT IGNORE INTO favorites (user_id, product_id) VALUES (?, ?)',
      [req.user.userId, product_id]
    );

    res.json({ message: 'Favorilere eklendi' });
  } catch (error) {
    console.error('Add favorite error:', error);
    res.status(500).json({ error: 'Favorilere eklenemedi' });
  }
});

// Favorilerden çıkar
router.delete('/:product_id', authenticateToken, async (req, res) => {
  try {
    const { product_id } = req.params;
    const pool = getPool();

    await pool.execute(
      'DELETE FROM favorites WHERE user_id = ? AND product_id = ?',
      [req.user.userId, product_id]
    );

    res.json({ message: 'Favorilerden çıkarıldı' });
  } catch (error) {
    console.error('Remove favorite error:', error);
    res.status(500).json({ error: 'Favorilerden çıkarılamadı' });
  }
});

module.exports = router;