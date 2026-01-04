const { getPool } = require('./config/database');

async function addSampleData() {
  try {
    const pool = getPool();
    
    console.log('📦 Örnek veriler ekleniyor...');

    // Kategoriler
    const categories = [
      ['Elektronik', 'Telefon, bilgisayar ve elektronik ürünler', 'https://via.placeholder.com/300x200?text=Elektronik'],
      ['Giyim', 'Erkek, kadın ve çocuk giyim', 'https://via.placeholder.com/300x200?text=Giyim'],
      ['Ev & Yaşam', 'Ev dekorasyonu ve yaşam ürünleri', 'https://via.placeholder.com/300x200?text=Ev+Yasam'],
      ['Spor', 'Spor giyim ve ekipmanları', 'https://via.placeholder.com/300x200?text=Spor'],
      ['Kozmetik', 'Güzellik ve kişisel bakım', 'https://via.placeholder.com/300x200?text=Kozmetik']
    ];

    for (const [name, description, image_url] of categories) {
      await pool.execute(
        'INSERT IGNORE INTO categories (name, description, image_url) VALUES (?, ?, ?)',
        [name, description, image_url]
      );
    }
    console.log('✅ Kategoriler eklendi');

    // Ürünler
    const products = [
      // Elektronik (category_id: 1)
      ['iPhone 15 Pro', 'Apple iPhone 15 Pro 128GB', 45999.00, 49999.00, 'Apple', 1, 'https://via.placeholder.com/300x300?text=iPhone+15', 50, 4.8, 124],
      ['Samsung Galaxy S24', 'Samsung Galaxy S24 256GB', 38999.00, 42999.00, 'Samsung', 1, 'https://via.placeholder.com/300x300?text=Galaxy+S24', 30, 4.6, 89],
      ['MacBook Air M3', 'Apple MacBook Air 13" M3 Chip', 54999.00, 59999.00, 'Apple', 1, 'https://via.placeholder.com/300x300?text=MacBook+Air', 20, 4.9, 67],
      ['AirPods Pro', 'Apple AirPods Pro 2. Nesil', 8999.00, 9999.00, 'Apple', 1, 'https://via.placeholder.com/300x300?text=AirPods+Pro', 100, 4.7, 203],

      // Giyim (category_id: 2)
      ['Nike Air Max', 'Nike Air Max 270 Spor Ayakkabı', 2499.00, 2999.00, 'Nike', 2, 'https://via.placeholder.com/300x300?text=Nike+Air+Max', 75, 4.5, 156],
      ['Levi\'s 501', 'Levi\'s 501 Original Fit Jean', 899.00, 1199.00, 'Levi\'s', 2, 'https://via.placeholder.com/300x300?text=Levis+501', 60, 4.4, 98],
      ['Adidas Hoodie', 'Adidas Essentials Kapüşonlu Sweatshirt', 1299.00, 1599.00, 'Adidas', 2, 'https://via.placeholder.com/300x300?text=Adidas+Hoodie', 40, 4.3, 76],

      // Ev & Yaşam (category_id: 3)
      ['Dyson V15', 'Dyson V15 Detect Kablosuz Süpürge', 12999.00, 14999.00, 'Dyson', 3, 'https://via.placeholder.com/300x300?text=Dyson+V15', 25, 4.8, 45],
      ['Philips Hue', 'Philips Hue Akıllı Ampul Seti', 1899.00, 2299.00, 'Philips', 3, 'https://via.placeholder.com/300x300?text=Philips+Hue', 80, 4.6, 134],

      // Spor (category_id: 4)
      ['Yoga Matı', 'Premium Yoga ve Pilates Matı', 299.00, 399.00, 'FitLife', 4, 'https://via.placeholder.com/300x300?text=Yoga+Mat', 120, 4.2, 89],
      ['Protein Tozu', 'Whey Protein Isolate 1kg', 599.00, 699.00, 'Optimum', 4, 'https://via.placeholder.com/300x300?text=Protein', 200, 4.7, 267],

      // Kozmetik (category_id: 5)
      ['Nivea Krem', 'Nivea Soft Nemlendirici Krem', 89.00, 119.00, 'Nivea', 5, 'https://via.placeholder.com/300x300?text=Nivea+Krem', 300, 4.1, 445],
      ['L\'Oreal Şampuan', 'L\'Oreal Paris Elvive Şampuan', 149.00, 199.00, 'L\'Oreal', 5, 'https://via.placeholder.com/300x300?text=Loreal+Sampuan', 150, 4.3, 178]
    ];

    for (const product of products) {
      await pool.execute(
        `INSERT IGNORE INTO products (name, description, price, old_price, brand, category_id, image_url, stock_quantity, rating, review_count) 
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        product
      );
    }
    console.log('✅ Ürünler eklendi');

    console.log('🎉 Tüm örnek veriler başarıyla eklendi!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Hata:', error);
    process.exit(1);
  }
}

// Veritabanını başlat ve veri ekle
const { initDatabase } = require('./config/database');
initDatabase().then(() => {
  addSampleData();
});