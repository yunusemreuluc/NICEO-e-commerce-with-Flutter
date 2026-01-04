const express = require('express');
const { getPool } = require('../config/database');

const router = express.Router();

// Tüm ürünleri getir
router.get('/', async (req, res) => {
  try {
    const { category_id, search, limit = 50, offset = 0 } = req.query;
    const pool = getPool();
    
    let query = `
      SELECT p.*, c.name as category_name 
      FROM products p 
      LEFT JOIN categories c ON p.category_id = c.id 
      WHERE p.is_active = TRUE
    `;
    let params = [];

    if (category_id) {
      query += ' AND p.category_id = ?';
      params.push(category_id);
    }

    if (search) {
      query += ' AND (p.name LIKE ? OR p.description LIKE ? OR p.brand LIKE ?)';
      const searchTerm = `%${search}%`;
      params.push(searchTerm, searchTerm, searchTerm);
    }

    query += ' ORDER BY p.created_at DESC LIMIT ? OFFSET ?';
    params.push(limit.toString(), offset.toString());

    const [products] = await pool.execute(query, params);
    res.json({ products });
  } catch (error) {
    console.error('Get products error:', error);
    res.status(500).json({ error: 'Ürünler alınamadı' });
  }
});

// Ürün detayı getir
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const pool = getPool();

    const [products] = await pool.execute(
      `SELECT p.*, c.name as category_name 
       FROM products p 
       LEFT JOIN categories c ON p.category_id = c.id 
       WHERE p.id = ? AND p.is_active = TRUE`,
      [id]
    );

    if (products.length === 0) {
      return res.status(404).json({ error: 'Ürün bulunamadı' });
    }

    res.json({ product: products[0] });
  } catch (error) {
    console.error('Get product error:', error);
    res.status(500).json({ error: 'Ürün alınamadı' });
  }
});

// Ürün ekle
router.post('/', async (req, res) => {
  try {
    const { name, description, price, old_price, brand, category_id, image_url, stock_quantity } = req.body;
    const pool = getPool();

    const [result] = await pool.execute(
      `INSERT INTO products (name, description, price, old_price, brand, category_id, image_url, stock_quantity) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [name, description, price, old_price, brand, category_id, image_url, stock_quantity]
    );

    res.status(201).json({
      message: 'Ürün eklendi',
      product: { id: result.insertId, ...req.body }
    });
  } catch (error) {
    console.error('Add product error:', error);
    res.status(500).json({ error: 'Ürün eklenemedi' });
  }
});

module.exports = router;