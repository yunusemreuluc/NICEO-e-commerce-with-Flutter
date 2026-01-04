-- NICEO E-commerce Sample Data
-- Bu dosyayı MySQL'de çalıştırarak örnek veriler ekleyebilirsiniz

USE `niceo-ecommerce`;

-- Kategoriler
INSERT INTO categories (name, description, image_url) VALUES
('Elektronik', 'Telefon, bilgisayar ve elektronik ürünler', 'https://via.placeholder.com/300x200?text=Elektronik'),
('Giyim', 'Erkek, kadın ve çocuk giyim', 'https://via.placeholder.com/300x200?text=Giyim'),
('Ev & Yaşam', 'Ev dekorasyonu ve yaşam ürünleri', 'https://via.placeholder.com/300x200?text=Ev+Yasam'),
('Spor', 'Spor giyim ve ekipmanları', 'https://via.placeholder.com/300x200?text=Spor'),
('Kozmetik', 'Güzellik ve kişisel bakım', 'https://via.placeholder.com/300x200?text=Kozmetik');

-- Ürünler
INSERT INTO products (name, description, price, old_price, brand, category_id, image_url, stock_quantity, rating, review_count) VALUES
-- Elektronik
('iPhone 15 Pro', 'Apple iPhone 15 Pro 128GB', 45999.00, 49999.00, 'Apple', 1, 'https://via.placeholder.com/300x300?text=iPhone+15', 50, 4.8, 124),
('Samsung Galaxy S24', 'Samsung Galaxy S24 256GB', 38999.00, 42999.00, 'Samsung', 1, 'https://via.placeholder.com/300x300?text=Galaxy+S24', 30, 4.6, 89),
('MacBook Air M3', 'Apple MacBook Air 13" M3 Chip', 54999.00, 59999.00, 'Apple', 1, 'https://via.placeholder.com/300x300?text=MacBook+Air', 20, 4.9, 67),
('AirPods Pro', 'Apple AirPods Pro 2. Nesil', 8999.00, 9999.00, 'Apple', 1, 'https://via.placeholder.com/300x300?text=AirPods+Pro', 100, 4.7, 203),

-- Giyim
('Nike Air Max', 'Nike Air Max 270 Spor Ayakkabı', 2499.00, 2999.00, 'Nike', 2, 'https://via.placeholder.com/300x300?text=Nike+Air+Max', 75, 4.5, 156),
('Levi\'s 501', 'Levi\'s 501 Original Fit Jean', 899.00, 1199.00, 'Levi\'s', 2, 'https://via.placeholder.com/300x300?text=Levis+501', 60, 4.4, 98),
('Adidas Hoodie', 'Adidas Essentials Kapüşonlu Sweatshirt', 1299.00, 1599.00, 'Adidas', 2, 'https://via.placeholder.com/300x300?text=Adidas+Hoodie', 40, 4.3, 76),

-- Ev & Yaşam
('Dyson V15', 'Dyson V15 Detect Kablosuz Süpürge', 12999.00, 14999.00, 'Dyson', 3, 'https://via.placeholder.com/300x300?text=Dyson+V15', 25, 4.8, 45),
('Philips Hue', 'Philips Hue Akıllı Ampul Seti', 1899.00, 2299.00, 'Philips', 3, 'https://via.placeholder.com/300x300?text=Philips+Hue', 80, 4.6, 134),

-- Spor
('Yoga Matı', 'Premium Yoga ve Pilates Matı', 299.00, 399.00, 'FitLife', 4, 'https://via.placeholder.com/300x300?text=Yoga+Mat', 120, 4.2, 89),
('Protein Tozu', 'Whey Protein Isolate 1kg', 599.00, 699.00, 'Optimum', 4, 'https://via.placeholder.com/300x300?text=Protein', 200, 4.7, 267),

-- Kozmetik
('Nivea Krem', 'Nivea Soft Nemlendirici Krem', 89.00, 119.00, 'Nivea', 5, 'https://via.placeholder.com/300x300?text=Nivea+Krem', 300, 4.1, 445),
('L\'Oreal Şampuan', 'L\'Oreal Paris Elvive Şampuan', 149.00, 199.00, 'L\'Oreal', 5, 'https://via.placeholder.com/300x300?text=Loreal+Sampuan', 150, 4.3, 178);

-- Test kullanıcısı (şifre: 123456)
INSERT INTO users (name, surname, email, phone, password) VALUES
('Test', 'Kullanıcı', 'test@niceo.com', '05551234567', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi');

-- Örnek favoriler (test kullanıcısı için)
INSERT INTO favorites (user_id, product_id) VALUES
(1, 1), (1, 3), (1, 5), (1, 8);

-- Örnek sepet (test kullanıcısı için)
INSERT INTO cart (user_id, product_id, quantity) VALUES
(1, 1, 1), (1, 4, 2), (1, 10, 1);

-- Örnek yorumlar
INSERT INTO reviews (user_id, product_id, rating, comment) VALUES
(1, 1, 5, 'Harika bir telefon, çok memnunum!'),
(1, 3, 5, 'MacBook Air gerçekten çok hızlı ve sessiz.'),
(1, 8, 4, 'Dyson süpürge çok güçlü ama biraz gürültülü.');