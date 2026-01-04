const express = require('express');
const { getPool } = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Kullanıcının kuponlarını getir
router.get('/', authenticateToken, async (req, res) => {
  try {
    const pool = getPool();
    const [coupons] = await pool.execute(
      `SELECT * FROM user_coupons uc
       JOIN coupons c ON uc.coupon_id = c.id
       WHERE uc.user_id = ? AND uc.is_used = 0 AND c.expires_at > NOW()
       ORDER BY c.expires_at ASC`,
      [req.user.userId]
    );

    res.json({ coupons });
  } catch (error) {
    console.error('Get coupons error:', error);
    res.status(500).json({ error: 'Kuponlar alınamadı' });
  }
});

// Kullanıcıya kupon ver (admin işlemi)
router.post('/assign', authenticateToken, async (req, res) => {
  try {
    const { coupon_code } = req.body;
    const pool = getPool();

    // Kupon kodunu kontrol et
    const [coupons] = await pool.execute(
      'SELECT * FROM coupons WHERE code = ? AND expires_at > NOW()',
      [coupon_code]
    );

    if (coupons.length === 0) {
      return res.status(404).json({ error: 'Geçersiz veya süresi dolmuş kupon' });
    }

    const coupon = coupons[0];

    // Kullanıcının bu kuponu zaten var mı kontrol et
    const [existing] = await pool.execute(
      'SELECT * FROM user_coupons WHERE user_id = ? AND coupon_id = ?',
      [req.user.userId, coupon.id]
    );

    if (existing.length > 0) {
      return res.status(400).json({ error: 'Bu kupon zaten hesabınızda mevcut' });
    }

    // Kullanıcıya kuponu ver
    await pool.execute(
      'INSERT INTO user_coupons (user_id, coupon_id) VALUES (?, ?)',
      [req.user.userId, coupon.id]
    );

    res.json({
      message: 'Kupon hesabınıza eklendi',
      coupon: {
        code: coupon.code,
        title: coupon.title,
        discount_amount: coupon.discount_amount,
        discount_type: coupon.discount_type
      }
    });
  } catch (error) {
    console.error('Assign coupon error:', error);
    res.status(500).json({ error: 'Kupon eklenemedi' });
  }
});

module.exports = router;