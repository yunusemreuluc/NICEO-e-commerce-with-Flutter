const axios = require('axios');

const baseURL = 'http://localhost:4003/api';

async function testAddReviews() {
  try {
    console.log('🧪 Değerlendirme Ekleme Testi başlıyor...\n');

    // Test kullanıcısı ile giriş yap
    const login = await axios.post(`${baseURL}/auth/login`, {
      email: 'test@niceo.com',
      password: '123456'
    });
    console.log('✅ Giriş başarılı:', login.data.user.name);
    
    const token = login.data.token;
    
    // Ürünleri getir
    const products = await axios.get(`${baseURL}/products`);
    console.log('📦 Toplam ürün sayısı:', products.data.products.length);
    
    if (products.data.products.length === 0) {
      console.log('❌ Ürün bulunamadı, önce ürün ekleyin');
      return;
    }

    // İlk 3 ürün için yorum ekle
    const reviewsToAdd = [
      {
        product_id: products.data.products[0].id,
        rating: 5,
        comment: 'Harika bir ürün! Kalitesi çok iyi, herkese tavsiye ederim. Hızlı kargo ve güvenli paketleme.'
      },
      {
        product_id: products.data.products[1].id,
        rating: 4,
        comment: 'Güzel ürün, beklentilerimi karşıladı. Fiyat performans açısından başarılı.'
      },
      {
        product_id: products.data.products[2].id,
        rating: 5,
        comment: 'Mükemmel! Tam aradığım gibiydi. Kalite çok yüksek, kesinlikle tekrar alırım.'
      }
    ];

    for (let i = 0; i < Math.min(reviewsToAdd.length, products.data.products.length); i++) {
      const reviewData = reviewsToAdd[i];
      const product = products.data.products[i];
      
      console.log(`\n⭐ ${product.name} için yorum ekleniyor...`);
      
      try {
        const review = await axios.post(`${baseURL}/reviews`, reviewData, {
          headers: { Authorization: `Bearer ${token}` }
        });
        console.log(`✅ ${reviewData.rating} yıldız yorum eklendi`);
      } catch (error) {
        if (error.response?.status === 500 && error.response?.data?.error?.includes('Duplicate entry')) {
          console.log(`⚠️ Bu ürün için zaten yorum var`);
        } else {
          console.log(`❌ Yorum eklenemedi:`, error.response?.data?.error || error.message);
        }
      }
    }

    // Kullanıcının yorumlarını listele
    console.log('\n📋 Yorumlarınız listeleniyor...');
    const myReviews = await axios.get(`${baseURL}/reviews/my-reviews`, {
      headers: { Authorization: `Bearer ${token}` }
    });
    
    console.log('✅ Toplam yorum sayısı:', myReviews.data.reviews.length);
    
    myReviews.data.reviews.forEach((review, index) => {
      console.log(`${index + 1}. ${review.product_name} - ${review.rating} yıldız`);
      console.log(`   "${review.comment}"`);
      console.log(`   ${new Date(review.created_at).toLocaleDateString('tr-TR')}`);
    });

    console.log('\n🎉 Değerlendirme testleri başarılı!');

  } catch (error) {
    console.error('❌ Test hatası:', error.response?.data || error.message);
  }
}

testAddReviews();