const { getPool, initDatabase } = require('./config/database');

async function cleanDuplicateCards() {
  try {
    console.log('🧹 Duplicate kart temizleme başlıyor...\n');

    await initDatabase();
    const pool = getPool();
    
    // Tüm kartları getir
    const [cards] = await pool.execute(
      'SELECT * FROM payment_methods WHERE user_id = 1 ORDER BY created_at DESC'
    );
    
    console.log('💳 Toplam kart sayısı:', cards.length);
    
    // Duplicate kartları bul (aynı card_last4 ve card_type)
    const seen = new Set();
    const toDelete = [];
    
    for (const card of cards) {
      const key = `${card.card_type}-${card.card_last4}`;
      if (seen.has(key)) {
        toDelete.push(card.id);
        console.log(`❌ Duplicate bulundu: ${card.card_type.toUpperCase()} **** ${card.card_last4} (ID: ${card.id})`);
      } else {
        seen.add(key);
        console.log(`✅ Korunacak: ${card.card_type.toUpperCase()} **** ${card.card_last4} (ID: ${card.id}) ${card.is_default ? '(Varsayılan)' : ''}`);
      }
    }
    
    // Duplicate kartları sil
    if (toDelete.length > 0) {
      console.log(`\n🗑️ ${toDelete.length} duplicate kart siliniyor...`);
      
      for (const id of toDelete) {
        await pool.execute('DELETE FROM payment_methods WHERE id = ?', [id]);
        console.log(`✅ Kart silindi: ID ${id}`);
      }
    } else {
      console.log('\n✨ Duplicate kart bulunamadı!');
    }
    
    // Güncellenmiş kartları göster
    const [finalCards] = await pool.execute(
      'SELECT * FROM payment_methods WHERE user_id = 1 ORDER BY is_default DESC, created_at DESC'
    );
    
    console.log('\n📋 Temizlenmiş kartlar:');
    finalCards.forEach((card, index) => {
      console.log(`${index + 1}. ${card.card_type.toUpperCase()} **** ${card.card_last4} ${card.is_default ? '(Varsayılan)' : ''}`);
      console.log(`   ${card.card_name}`);
    });
    
    console.log('\n🎉 Kart temizleme tamamlandı!');
    
  } catch (error) {
    console.error('❌ Temizleme hatası:', error);
  }
}

cleanDuplicateCards();