const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
require('dotenv').config();

const { initDatabase } = require('./config/database');

// Routes
const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/users');
const categoryRoutes = require('./routes/categories');
const productRoutes = require('./routes/products');
const favoriteRoutes = require('./routes/favorites');
const cartRoutes = require('./routes/cart');
const reviewRoutes = require('./routes/reviews');
const orderRoutes = require('./routes/orders');

console.log('📦 Temel route\'lar yüklendi');

const addressRoutes = require('./routes/addresses');
const paymentMethodRoutes = require('./routes/payment-methods');
const couponRoutes = require('./routes/coupons');

console.log('📦 Yeni route\'lar yüklendi');

const app = express();
const PORT = process.env.PORT || 4001;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/categories', categoryRoutes);
app.use('/api/products', productRoutes);
app.use('/api/favorites', favoriteRoutes);
app.use('/api/cart', cartRoutes);
app.use('/api/reviews', reviewRoutes);
app.use('/api/orders', orderRoutes);

console.log('📍 Adres route\'u ekleniyor...');
app.use('/api/addresses', addressRoutes);
console.log('💳 Ödeme route\'u ekleniyor...');
app.use('/api/payment-methods', paymentMethodRoutes);
console.log('🎫 Kupon route\'u ekleniyor...');
app.use('/api/coupons', couponRoutes);

// Test route
app.get('/api/test-addresses', (req, res) => {
  res.json({ message: 'Test addresses endpoint çalışıyor' });
});

console.log('✅ Tüm route\'lar eklendi');

// Health check
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    message: 'NICEO Backend API çalışıyor',
    timestamp: new Date().toISOString()
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({ error: 'Endpoint bulunamadı' });
});

// Error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Sunucu hatası' });
});

// Start server
async function startServer() {
  try {
    await initDatabase();
    app.listen(PORT, '0.0.0.0', () => {
      console.log(`🚀 NICEO Backend API ${PORT} portunda çalışıyor`);
      console.log(`📍 Health check: http://localhost:${PORT}/api/health`);
      console.log(`🌐 Network: http://10.245.149.212:${PORT}/api/health`);
    });
  } catch (error) {
    console.error('❌ Sunucu başlatılamadı:', error);
    process.exit(1);
  }
}

startServer();