const { initDatabase, getPool } = require('./config/database');

async function updateOrderItemsTable() {
  try {
    await initDatabase(); // Önce veritabanını başlat
    const pool = getPool();
    
    console.log('📦 order_items tablosu güncelleniyor...');
    
    // name kolonu ekle
    try {
      await pool.execute(`
        ALTER TABLE order_items 
        ADD COLUMN name VARCHAR(255) DEFAULT NULL
      `);
      console.log('✅ name kolonu eklendi');
    } catch (e) {
      if (e.code === 'ER_DUP_FIELDNAME') {
        console.log('ℹ️ name kolonu zaten mevcut');
      } else {
        throw e;
      }
    }
    
    // image_url kolonu ekle
    try {
      await pool.execute(`
        ALTER TABLE order_items 
        ADD COLUMN image_url TEXT DEFAULT NULL
      `);
      console.log('✅ image_url kolonu eklendi');
    } catch (e) {
      if (e.code === 'ER_DUP_FIELDNAME') {
        console.log('ℹ️ image_url kolonu zaten mevcut');
      } else {
        throw e;
      }
    }
    
    console.log('🎉 Tablo güncelleme tamamlandı!');
    process.exit(0);
    
  } catch (error) {
    console.error('❌ Hata:', error);
    process.exit(1);
  }
}

updateOrderItemsTable();