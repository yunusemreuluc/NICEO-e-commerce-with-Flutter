const { getPool, initDatabase } = require('./config/database');

async function checkAllReviews() {
  try {
    console.log('🔍 Tüm yorumları kontrol ediyorum...\n');

    await initDatabase();
    const pool = getPool();
    
    // Tüm yorumları getir
    const [allReviews] = await pool.execute(`
      SELECT r.*, u.name as user_name, u.email as user_email, p.name as product_name
      FROM reviews r
      JOIN users u ON r.user_id = u.id
      JOIN products p ON r.product_id = p.id
      ORDER BY r.created_at DESC
      LIMIT 20
    `);
    
    console.log('💬 Son 20 yorum:');
    console.log('');
    
    if (allReviews.length > 0) {
      allReviews.forEach((review, index) => {
        console.log(`${index + 1}. ${review.user_name} (${review.user_email})`);
        console.log(`   📦 Ürün: ${review.product_name}`);
        console.log(`   ⭐ Puan: ${review.rating} yıldız`);
        console.log(`   💬 Yorum: "${review.comment}"`);
        console.log(`   📅 Tarih: ${new Date(review.created_at).toLocaleString('tr-TR')}`);
        console.log('');
      });
      
      // Kullanıcı bazında yorum sayıları
      console.log('📊 Kullanıcı bazında yorum sayıları:');
      const userReviewCounts = {};
      allReviews.forEach(review => {
        const key = `${review.user_name} (${review.user_email})`;
        userReviewCounts[key] = (userReviewCounts[key] || 0) + 1;
      });
      
      Object.entries(userReviewCounts).forEach(([user, count]) => {
        console.log(`   ${user}: ${count} yorum`);
      });
    } else {
      console.log('📝 Hiç yorum bulunamadı');
    }
    
    console.log('\n🎉 Kontrol tamamlandı!');
    
  } catch (error) {
    console.error('❌ Kontrol hatası:', error);
  }
}

checkAllReviews();