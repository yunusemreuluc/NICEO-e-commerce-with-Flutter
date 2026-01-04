const { getPool, initDatabase } = require('./config/database');

async function checkUsers() {
  try {
    console.log('👥 Kullanıcıları kontrol ediyorum...\n');

    await initDatabase();
    const pool = getPool();
    
    // Tüm kullanıcıları getir
    const [users] = await pool.execute('SELECT id, name, surname, email, created_at FROM users ORDER BY created_at DESC');
    
    console.log('📊 Toplam kullanıcı sayısı:', users.length);
    console.log('');
    
    if (users.length > 0) {
      console.log('👤 Kayıtlı kullanıcılar:');
      users.forEach((user, index) => {
        console.log(`${index + 1}. ${user.name} ${user.surname || ''}`);
        console.log(`   📧 Email: ${user.email}`);
        console.log(`   📅 Kayıt: ${new Date(user.created_at).toLocaleDateString('tr-TR')}`);
        console.log('');
      });
    } else {
      console.log('👤 Hiç kullanıcı bulunamadı');
    }
    
    console.log('🎉 Kontrol tamamlandı!');
    
  } catch (error) {
    console.error('❌ Kontrol hatası:', error);
  }
}

checkUsers();