const express = require('express');
const { getPool } = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Kullanıcının adreslerini getir
router.get('/', authenticateToken, async (req, res) => {
  try {
    const pool = getPool();
    const [addresses] = await pool.execute(
      'SELECT * FROM addresses WHERE user_id = ? ORDER BY is_default DESC, created_at DESC',
      [req.user.userId]
    );

    res.json({ addresses });
  } catch (error) {
    console.error('Get addresses error:', error);
    res.status(500).json({ error: 'Adresler alınamadı' });
  }
});

// Yeni adres ekle
router.post('/', authenticateToken, async (req, res) => {
  try {
    const { title, full_address, city, district, is_default } = req.body;
    const pool = getPool();

    // Eğer varsayılan adres ise, diğerlerini varsayılan olmaktan çıkar
    if (is_default) {
      await pool.execute(
        'UPDATE addresses SET is_default = 0 WHERE user_id = ?',
        [req.user.userId]
      );
    }

    const [result] = await pool.execute(
      'INSERT INTO addresses (user_id, title, full_address, city, district, is_default) VALUES (?, ?, ?, ?, ?, ?)',
      [req.user.userId, title, full_address, city, district, is_default ? 1 : 0]
    );

    res.status(201).json({
      message: 'Adres eklendi',
      address: {
        id: result.insertId,
        title,
        full_address,
        city,
        district,
        is_default
      }
    });
  } catch (error) {
    console.error('Add address error:', error);
    res.status(500).json({ error: 'Adres eklenemedi' });
  }
});

// Varsayılan adres yap
router.put('/:id/default', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const pool = getPool();

    // Önce tüm adresleri varsayılan olmaktan çıkar
    await pool.execute(
      'UPDATE addresses SET is_default = 0 WHERE user_id = ?',
      [req.user.userId]
    );

    // Seçilen adresi varsayılan yap
    const [result] = await pool.execute(
      'UPDATE addresses SET is_default = 1 WHERE id = ? AND user_id = ?',
      [id, req.user.userId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Adres bulunamadı' });
    }

    res.json({ message: 'Varsayılan adres güncellendi' });
  } catch (error) {
    console.error('Set default address error:', error);
    res.status(500).json({ error: 'Varsayılan adres yapılamadı' });
  }
});

module.exports = router;