const express = require('express');
const { getPool } = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Sepeti getir
router.get('/', authenticateToken, async (req, res) => {
  try {
    const pool = getPool();
    const [cartItems] = await pool.execute(
      `SELECT c.*, p.name, p.price, p.brand, p.image_url, p.stock_quantity
       FROM cart c
       JOIN products p ON c.product_id = p.id
       WHERE c.user_id = ? AND p.is_active = TRUE
       ORDER BY c.created_at DESC`,
      [req.user.userId]
    );

    res.json({ cart: cartItems });
  } catch (error) {
    console.error('Get cart error:', error);
    res.status(500).json({ error: 'Sepet alınamadı' });
  }
});

// Sepete ekle
router.post('/', authenticateToken, async (req, res) => {
  try {
    const { product_id, quantity = 1 } = req.body;
    const pool = getPool();

    await pool.execute(
      `INSERT INTO cart (user_id, product_id, quantity) 
       VALUES (?, ?, ?) 
       ON DUPLICATE KEY UPDATE quantity = quantity + VALUES(quantity)`,
      [req.user.userId, product_id, quantity]
    );

    res.json({ message: 'Sepete eklendi' });
  } catch (error) {
    console.error('Add to cart error:', error);
    res.status(500).json({ error: 'Sepete eklenemedi' });
  }
});

// Sepet güncelle
router.put('/:product_id', authenticateToken, async (req, res) => {
  try {
    const { product_id } = req.params;
    const { quantity } = req.body;
    const pool = getPool();

    if (quantity <= 0) {
      await pool.execute(
        'DELETE FROM cart WHERE user_id = ? AND product_id = ?',
        [req.user.userId, product_id]
      );
    } else {
      await pool.execute(
        'UPDATE cart SET quantity = ? WHERE user_id = ? AND product_id = ?',
        [quantity, req.user.userId, product_id]
      );
    }

    res.json({ message: 'Sepet güncellendi' });
  } catch (error) {
    console.error('Update cart error:', error);
    res.status(500).json({ error: 'Sepet güncellenemedi' });
  }
});

// Sepetten çıkar
router.delete('/:product_id', authenticateToken, async (req, res) => {
  try {
    const { product_id } = req.params;
    const pool = getPool();

    await pool.execute(
      'DELETE FROM cart WHERE user_id = ? AND product_id = ?',
      [req.user.userId, product_id]
    );

    res.json({ message: 'Sepetten çıkarıldı' });
  } catch (error) {
    console.error('Remove from cart error:', error);
    res.status(500).json({ error: 'Sepetten çıkarılamadı' });
  }
});

module.exports = router;