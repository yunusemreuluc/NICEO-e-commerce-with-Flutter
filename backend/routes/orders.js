const express = require('express');
const { getPool } = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Kullanıcının siparişlerini getir
router.get('/', authenticateToken, async (req, res) => {
  try {
    const pool = getPool();
    const [orders] = await pool.execute(
      `SELECT o.*, 
       COUNT(oi.id) as item_count,
       SUM(oi.quantity * oi.price) as total_amount
       FROM orders o
       LEFT JOIN order_items oi ON o.id = oi.order_id
       WHERE o.user_id = ?
       GROUP BY o.id
       ORDER BY o.created_at DESC`,
      [req.user.userId]
    );

    // Her sipariş için ürün detaylarını al
    for (let order of orders) {
      const [items] = await pool.execute(
        `SELECT oi.*, p.name, p.image_url
         FROM order_items oi
         JOIN products p ON oi.product_id = p.id
         WHERE oi.order_id = ?`,
        [order.id]
      );
      order.items = items;
    }

    res.json({ orders });
  } catch (error) {
    console.error('Get orders error:', error);
    res.status(500).json({ error: 'Siparişler alınamadı' });
  }
});

// Sipariş detayı getir
router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const pool = getPool();

    const [orders] = await pool.execute(
      'SELECT * FROM orders WHERE id = ? AND user_id = ?',
      [id, req.user.userId]
    );

    if (orders.length === 0) {
      return res.status(404).json({ error: 'Sipariş bulunamadı' });
    }

    const order = orders[0];

    // Sipariş ürünlerini al
    const [items] = await pool.execute(
      `SELECT oi.*, p.name, p.image_url
       FROM order_items oi
       JOIN products p ON oi.product_id = p.id
       WHERE oi.order_id = ?`,
      [id]
    );

    order.items = items;

    res.json({ order });
  } catch (error) {
    console.error('Get order error:', error);
    res.status(500).json({ error: 'Sipariş alınamadı' });
  }
});

// Yeni sipariş oluştur (sepetten)
router.post('/', authenticateToken, async (req, res) => {
  try {
    const { shipping_address, payment_method, cart_items } = req.body;
    const pool = getPool();

    let cartItems = [];
    let totalAmount = 0;

    if (cart_items && cart_items.length > 0) {
      // Frontend'den gelen sepet ürünlerini kullan
      cartItems = cart_items;
      totalAmount = cart_items.reduce((sum, item) => {
        return sum + (parseFloat(item.price) * item.quantity);
      }, 0);
    } else {
      // Kullanıcının veritabanındaki sepetini al (eski yöntem)
      const [dbCartItems] = await pool.execute(
        `SELECT c.*, p.name, p.price, p.image_url
         FROM cart c
         JOIN products p ON c.product_id = p.id
         WHERE c.user_id = ?`,
        [req.user.userId]
      );

      if (dbCartItems.length === 0) {
        return res.status(400).json({ error: 'Sepet boş' });
      }

      cartItems = dbCartItems;
      totalAmount = dbCartItems.reduce((sum, item) => {
        return sum + (parseFloat(item.price) * item.quantity);
      }, 0);
    }

    // Sipariş oluştur
    const orderCode = `ORD-${Date.now()}`;
    const [orderResult] = await pool.execute(
      `INSERT INTO orders (user_id, order_code, status, total_amount, shipping_address, payment_method) 
       VALUES (?, ?, 'preparing', ?, ?, ?)`,
      [req.user.userId, orderCode, totalAmount, shipping_address, payment_method]
    );

    const orderId = orderResult.insertId;

    // Sipariş ürünlerini ekle
    for (const item of cartItems) {
      // Product ID'yi sayısal hale getir
      let productId = 1; // Varsayılan
      if (item.product_id) {
        productId = parseInt(item.product_id) || 1;
      } else if (item.id) {
        // String ID'den sayısal kısmı çıkar (örn: "ftr_4" -> 4)
        const match = item.id.toString().match(/\d+/);
        productId = match ? parseInt(match[0]) : 1;
      }

      await pool.execute(
        `INSERT INTO order_items (order_id, product_id, quantity, price, name, image_url) 
         VALUES (?, ?, ?, ?, ?, ?)`,
        [
          orderId, 
          productId, 
          item.quantity, 
          item.price,
          item.name,
          item.image_url || item.image || ''
        ]
      );
    }

    // Veritabanındaki sepeti temizle (varsa)
    await pool.execute(
      'DELETE FROM cart WHERE user_id = ?',
      [req.user.userId]
    );

    res.status(201).json({
      message: 'Sipariş oluşturuldu',
      order: {
        id: orderId,
        order_code: orderCode,
        total_amount: totalAmount,
        status: 'preparing'
      }
    });
  } catch (error) {
    console.error('Create order error:', error);
    res.status(500).json({ error: 'Sipariş oluşturulamadı' });
  }
});

module.exports = router;