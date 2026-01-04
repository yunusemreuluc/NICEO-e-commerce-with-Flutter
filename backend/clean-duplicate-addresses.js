const { getPool, initDatabase } = require('./config/database');

async function cleanDuplicateAddresses() {
  try {
    console.log('🧹 Duplicate adres temizleme başlıyor...\n');

    // Database bağlantısını başlat
    await initDatabase();
    const pool = getPool();
    
    // Tüm adresleri getir
    const [addresses] = await pool.execute(
      'SELECT * FROM addresses WHERE user_id = 1 ORDER BY created_at DESC'
    );
    
    console.log('📍 Toplam adres sayısı:', addresses.length);
    
    // Duplicate adresleri bul (aynı title ve full_address)
    const seen = new Set();
    const toDelete = [];
    
    for (const address of addresses) {
      const key = `${address.title}-${address.full_address}`;
      if (seen.has(key)) {
        toDelete.push(address.id);
        console.log(`❌ Duplicate bulundu: ${address.title} (ID: ${address.id})`);
      } else {
        seen.add(key);
        console.log(`✅ Korunacak: ${address.title} (ID: ${address.id})`);
      }
    }
    
    // Duplicate adresleri sil
    if (toDelete.length > 0) {
      console.log(`\n🗑️ ${toDelete.length} duplicate adres siliniyor...`);
      
      for (const id of toDelete) {
        await pool.execute('DELETE FROM addresses WHERE id = ?', [id]);
        console.log(`✅ Adres silindi: ID ${id}`);
      }
    } else {
      console.log('\n✨ Duplicate adres bulunamadı!');
    }
    
    // Güncellenmiş adresleri göster
    const [finalAddresses] = await pool.execute(
      'SELECT * FROM addresses WHERE user_id = 1 ORDER BY is_default DESC, created_at DESC'
    );
    
    console.log('\n📋 Temizlenmiş adresler:');
    finalAddresses.forEach((addr, index) => {
      console.log(`${index + 1}. ${addr.title} ${addr.is_default ? '(Varsayılan)' : ''}`);
      console.log(`   ${addr.full_address}`);
      console.log(`   ${addr.district}, ${addr.city}`);
    });
    
    console.log('\n🎉 Adres temizleme tamamlandı!');
    
  } catch (error) {
    console.error('❌ Temizleme hatası:', error);
  }
}

cleanDuplicateAddresses();