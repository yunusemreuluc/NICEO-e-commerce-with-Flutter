const axios = require('axios');

const baseURL = 'http://localhost:4003/api';

async function testMyReviews() {
  try {
    console.log('🧪 Değerlendirmelerim Testi başlıyor...\n');

    // Test kullanıcısı ile giriş yap
    const login = await axios.post(`${baseURL}/auth/login`, {
      email: 'test@niceo.com',
      password: '123456'
    });
    console.log('✅ Giriş başarılı:', login.data.user.name);
    console.log('🔑 Token:', login.data.token.substring(0, 20) + '...');
    
    const token = login.data.token;
    
    // Kullanıcının yorumlarını getir
    console.log('\n📋 Yorumlarım getiriliyor...');
    const myReviews = await axios.get(`${baseURL}/reviews/my-reviews`, {
      headers: { Authorization: `Bearer ${token}` }
    });
    
    console.log('✅ API Response Status:', myReviews.status);
    console.log('✅ Toplam yorum sayısı:', myReviews.data.reviews.length);
    
    if (myReviews.data.reviews.length > 0) {
      console.log('\n📝 Yorumlarınız:');
      myReviews.data.reviews.forEach((review, index) => {
        console.log(`${index + 1}. ${review.product_name} - ${review.rating} yıldız`);
        console.log(`   "${review.comment}"`);
        console.log(`   Tarih: ${new Date(review.created_at).toLocaleDateString('tr-TR')}`);
        console.log(`   Ürün resmi: ${review.product_image || 'Yok'}`);
        console.log('');
      });
    } else {
      console.log('📝 Henüz yorum yapılmamış');
    }

    console.log('🎉 Test başarılı!');

  } catch (error) {
    console.error('❌ Test hatası:', error.response?.data || error.message);
    console.error('📊 Status:', error.response?.status);
    console.error('🔗 URL:', error.config?.url);
  }
}

testMyReviews();