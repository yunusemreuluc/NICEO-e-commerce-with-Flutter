const express = require('express');
const { getPool } = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Kullanıcının yorumlarını getir
router.get('/my-reviews', authenticateToken, async (req, res) => {
  try {
    const pool = getPool();

    const [reviews] = await pool.execute(
      `SELECT r.*, 
              p.name as product_name, 
              p.image_url as product_image,
              p.price as product_price,
              p.old_price as product_old_price,
              p.rating as product_rating,
              p.review_count as product_review_count,
              p.description as product_description
       FROM reviews r
       JOIN products p ON r.product_id = p.id
       WHERE r.user_id = ?
       ORDER BY r.created_at DESC`,
      [req.user.userId]
    );

    res.json({ reviews });
  } catch (error) {
    console.error('Get my reviews error:', error);
    res.status(500).json({ error: 'Yorumlarınız alınamadı' });
  }
});

// Ürün yorumlarını getir
router.get('/product/:product_id', async (req, res) => {
  try {
    const { product_id } = req.params;
    const pool = getPool();

    const [reviews] = await pool.execute(
      `SELECT r.*, u.name, u.surname 
       FROM reviews r
       JOIN users u ON r.user_id = u.id
       WHERE r.product_id = ?
       ORDER BY r.created_at DESC`,
      [product_id]
    );

    res.json({ reviews });
  } catch (error) {
    console.error('Get reviews error:', error);
    res.status(500).json({ error: 'Yorumlar alınamadı' });
  }
});

// Yorum ekle
router.post('/', authenticateToken, async (req, res) => {
  try {
    const { product_id, rating, comment } = req.body;
    const pool = getPool();

    // Yorum ekle
    await pool.execute(
      'INSERT INTO reviews (user_id, product_id, rating, comment) VALUES (?, ?, ?, ?)',
      [req.user.userId, product_id, rating, comment]
    );

    // Ürünün ortalama puanını güncelle
    const [avgResult] = await pool.execute(
      'SELECT AVG(rating) as avg_rating, COUNT(*) as review_count FROM reviews WHERE product_id = ?',
      [product_id]
    );

    await pool.execute(
      'UPDATE products SET rating = ?, review_count = ? WHERE id = ?',
      [avgResult[0].avg_rating, avgResult[0].review_count, product_id]
    );

    res.json({ message: 'Yorum eklendi' });
  } catch (error) {
    console.error('Add review error:', error);
    res.status(500).json({ error: 'Yorum eklenemedi' });
  }
});

// Yorum sil
router.delete('/:review_id', authenticateToken, async (req, res) => {
  try {
    const { review_id } = req.params;
    const pool = getPool();

    // Önce yorumun sahibi olup olmadığını kontrol et
    const [reviewCheck] = await pool.execute(
      'SELECT product_id FROM reviews WHERE id = ? AND user_id = ?',
      [review_id, req.user.userId]
    );

    if (reviewCheck.length === 0) {
      return res.status(404).json({ error: 'Yorum bulunamadı veya yetkiniz yok' });
    }

    const product_id = reviewCheck[0].product_id;

    // Yorumu sil
    await pool.execute(
      'DELETE FROM reviews WHERE id = ? AND user_id = ?',
      [review_id, req.user.userId]
    );

    // Ürünün ortalama puanını güncelle
    const [avgResult] = await pool.execute(
      'SELECT AVG(rating) as avg_rating, COUNT(*) as review_count FROM reviews WHERE product_id = ?',
      [product_id]
    );

    const newRating = avgResult[0].review_count > 0 ? avgResult[0].avg_rating : 0;
    await pool.execute(
      'UPDATE products SET rating = ?, review_count = ? WHERE id = ?',
      [newRating, avgResult[0].review_count, product_id]
    );

    res.json({ message: 'Yorum silindi' });
  } catch (error) {
    console.error('Delete review error:', error);
    res.status(500).json({ error: 'Yorum silinemedi' });
  }
});

// Yorum güncelle
router.put('/:review_id', authenticateToken, async (req, res) => {
  try {
    const { review_id } = req.params;
    const { rating, comment } = req.body;
    const pool = getPool();

    // Önce yorumun sahibi olup olmadığını kontrol et
    const [reviewCheck] = await pool.execute(
      'SELECT product_id FROM reviews WHERE id = ? AND user_id = ?',
      [review_id, req.user.userId]
    );

    if (reviewCheck.length === 0) {
      return res.status(404).json({ error: 'Yorum bulunamadı veya yetkiniz yok' });
    }

    const product_id = reviewCheck[0].product_id;

    // Yorumu güncelle
    await pool.execute(
      'UPDATE reviews SET rating = ?, comment = ? WHERE id = ? AND user_id = ?',
      [rating, comment, review_id, req.user.userId]
    );

    // Ürünün ortalama puanını güncelle
    const [avgResult] = await pool.execute(
      'SELECT AVG(rating) as avg_rating, COUNT(*) as review_count FROM reviews WHERE product_id = ?',
      [product_id]
    );

    await pool.execute(
      'UPDATE products SET rating = ?, review_count = ? WHERE id = ?',
      [avgResult[0].avg_rating, avgResult[0].review_count, product_id]
    );

    res.json({ message: 'Yorum güncellendi' });
  } catch (error) {
    console.error('Update review error:', error);
    res.status(500).json({ error: 'Yorum güncellenemedi' });
  }
});

module.exports = router;