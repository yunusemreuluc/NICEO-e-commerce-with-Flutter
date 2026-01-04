const axios = require('axios');

const baseURL = 'http://localhost:4003/api';

async function checkOrders() {
  try {
    console.log('🧪 Siparişler kontrol ediliyor...\n');

    // Test kullanıcısı ile giriş yap
    const login = await axios.post(`${baseURL}/auth/login`, {
      email: 'test@niceo.com',
      password: '123456'
    });
    console.log('✅ Giriş başarılı:', login.data.user.name);
    
    const token = login.data.token;
    
    // Siparişleri getir
    console.log('\n📋 Siparişler getiriliyor...');
    const orders = await axios.get(`${baseURL}/orders`, {
      headers: { Authorization: `Bearer ${token}` }
    });
    
    console.log('✅ API Response Status:', orders.status);
    console.log('✅ Toplam sipariş sayısı:', orders.data.orders.length);
    
    if (orders.data.orders.length > 0) {
      console.log('\n📝 Siparişleriniz:');
      orders.data.orders.forEach((order, index) => {
        console.log(`${index + 1}. ${order.order_code} - ₺${order.total_amount} - ${order.status}`);
        console.log(`   Tarih: ${new Date(order.created_at).toLocaleDateString('tr-TR')}`);
        console.log(`   Ürün sayısı: ${order.item_count || 0}`);
        if (order.items && order.items.length > 0) {
          order.items.forEach(item => {
            console.log(`   - ${item.name} x${item.quantity} (₺${item.price})`);
          });
        }
        console.log('');
      });
    } else {
      console.log('📝 Henüz sipariş yok');
    }

    console.log('🎉 Test başarılı!');

  } catch (error) {
    console.error('❌ Test hatası:', error.response?.data || error.message);
    console.error('📊 Status:', error.response?.status);
    console.error('🔗 URL:', error.config?.url);
  }
}

checkOrders();