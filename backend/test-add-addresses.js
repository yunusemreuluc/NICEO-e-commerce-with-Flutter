const axios = require('axios');

const baseURL = 'http://localhost:4003/api';

async function testAddAddresses() {
  try {
    console.log('🧪 Adres Ekleme Testi başlıyor...\n');

    // Test kullanıcısı ile giriş yap
    const login = await axios.post(`${baseURL}/auth/login`, {
      email: 'test@niceo.com',
      password: '123456'
    });
    console.log('✅ Giriş başarılı:', login.data.user.name);
    
    const token = login.data.token;
    
    // 1. Ev adresi ekle (varsayılan)
    console.log('\n📍 Ev adresi ekleniyor...');
    const address1 = await axios.post(`${baseURL}/addresses`, {
      title: 'Ev Adresim',
      full_address: 'Atatürk Mahallesi, Cumhuriyet Caddesi No: 123/5 Daire: 8',
      city: 'İstanbul',
      district: 'Kadıköy',
      is_default: true
    }, {
      headers: { Authorization: `Bearer ${token}` }
    });
    console.log('✅ Ev adresi eklendi:', address1.data.address.title);

    // 2. İş adresi ekle
    console.log('\n🏢 İş adresi ekleniyor...');
    const address2 = await axios.post(`${baseURL}/addresses`, {
      title: 'İş Yerim',
      full_address: 'Maslak Mahallesi, Büyükdere Caddesi No: 45 Kat: 12 Ofis: 1205',
      city: 'İstanbul',
      district: 'Şişli',
      is_default: false
    }, {
      headers: { Authorization: `Bearer ${token}` }
    });
    console.log('✅ İş adresi eklendi:', address2.data.address.title);

    // 3. Anne evi adresi ekle
    console.log('\n🏠 Anne evi adresi ekleniyor...');
    const address3 = await axios.post(`${baseURL}/addresses`, {
      title: 'Anne Evi',
      full_address: 'Çamlık Sokak No: 7 Daire: 3 Beşiktaş Merkez',
      city: 'İstanbul',
      district: 'Beşiktaş',
      is_default: false
    }, {
      headers: { Authorization: `Bearer ${token}` }
    });
    console.log('✅ Anne evi adresi eklendi:', address3.data.address.title);

    // Adresleri listele
    console.log('\n📋 Adresler listeleniyor...');
    const addresses = await axios.get(`${baseURL}/addresses`, {
      headers: { Authorization: `Bearer ${token}` }
    });
    console.log('✅ Toplam adres sayısı:', addresses.data.addresses.length);
    
    addresses.data.addresses.forEach((addr, index) => {
      console.log(`${index + 1}. ${addr.title} ${addr.is_default ? '(Varsayılan)' : ''}`);
      console.log(`   ${addr.full_address}`);
      console.log(`   ${addr.district}, ${addr.city}`);
    });

    // İş adresini varsayılan yap
    console.log('\n🔄 İş adresini varsayılan yapıyor...');
    await axios.put(`${baseURL}/addresses/${address2.data.address.id}/default`, {}, {
      headers: { Authorization: `Bearer ${token}` }
    });
    console.log('✅ İş adresi varsayılan yapıldı');

    // Güncellenmiş adresleri listele
    console.log('\n📋 Güncellenmiş adresler...');
    const updatedAddresses = await axios.get(`${baseURL}/addresses`, {
      headers: { Authorization: `Bearer ${token}` }
    });
    
    updatedAddresses.data.addresses.forEach((addr, index) => {
      console.log(`${index + 1}. ${addr.title} ${addr.is_default ? '(Varsayılan)' : ''}`);
    });

    console.log('\n🎉 Adres ekleme testleri başarılı!');

  } catch (error) {
    console.error('❌ Test hatası:', error.response?.data || error.message);
  }
}

testAddAddresses();