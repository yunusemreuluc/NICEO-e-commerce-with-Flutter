const express = require('express');
const { getPool } = require('../config/database');

const router = express.Router();

// Tüm kategorileri getir
router.get('/', async (req, res) => {
  try {
    const pool = getPool();
    const [categories] = await pool.execute('SELECT * FROM categories ORDER BY name');
    res.json({ categories });
  } catch (error) {
    console.error('Get categories error:', error);
    res.status(500).json({ error: 'Kategoriler alınamadı' });
  }
});

// Kategori ekle
router.post('/', async (req, res) => {
  try {
    const { name, description, image_url } = req.body;
    const pool = getPool();

    const [result] = await pool.execute(
      'INSERT INTO categories (name, description, image_url) VALUES (?, ?, ?)',
      [name, description, image_url]
    );

    res.status(201).json({
      message: 'Kategori eklendi',
      category: { id: result.insertId, name, description, image_url }
    });
  } catch (error) {
    console.error('Add category error:', error);
    res.status(500).json({ error: 'Kategori eklenemedi' });
  }
});

module.exports = router;