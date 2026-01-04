const { getPool } = require('./config/database');

async function showAllUsers() {
  try {
    const pool = getPool();
    
    console.log('👥 Veritabanındaki Tüm Kullanıcılar:\n');

    // Kullanıcıları getir
    const [users] = await pool.execute(
      'SELECT id, name, surname, email, phone, created_at FROM users ORDER BY id'
    );

    users.forEach((user, index) => {
      console.log(`${index + 1}. Kullanıcı:`);
      console.log(`   ID: ${user.id}`);
      console.log(`   Ad Soyad: ${user.name} ${user.surname}`);
      console.log(`   Email: ${user.email}`);
      console.log(`   Telefon: ${user.phone}`);
      console.log(`   Kayıt Tarihi: ${new Date(user.created_at).toLocaleString('tr-TR')}`);
      console.log('');
    });

    console.log(`📊 Toplam ${users.length} kullanıcı kayıtlı\n`);

    // Favoriler istatistikleri
    const [favStats] = await pool.execute(`
      SELECT u.name, u.surname, COUNT(f.id) as fav_count
      FROM users u
      LEFT JOIN favorites f ON u.id = f.user_id
      GROUP BY u.id
      ORDER BY fav_count DESC
    `);

    console.log('❤️ Favori İstatistikleri:');
    favStats.forEach(stat => {
      console.log(`   ${stat.name} ${stat.surname}: ${stat.fav_count} favori`);
    });

    // Sepet istatistikleri
    const [cartStats] = await pool.execute(`
      SELECT u.name, u.surname, COUNT(c.id) as cart_count
      FROM users u
      LEFT JOIN cart c ON u.id = c.user_id
      GROUP BY u.id
      ORDER BY cart_count DESC
    `);

    console.log('\n🛒 Sepet İstatistikleri:');
    cartStats.forEach(stat => {
      console.log(`   ${stat.name} ${stat.surname}: ${stat.cart_count} ürün`);
    });

    process.exit(0);
  } catch (error) {
    console.error('❌ Hata:', error);
    process.exit(1);
  }
}

// Veritabanını başlat ve kullanıcıları göster
const { initDatabase } = require('./config/database');
initDatabase().then(() => {
  showAllUsers();
});