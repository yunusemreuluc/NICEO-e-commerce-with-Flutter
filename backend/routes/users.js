const express = require('express');
const bcrypt = require('bcrypt');
const { getPool } = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Kullanıcı profili getir
router.get('/profile', authenticateToken, async (req, res) => {
  try {
    const pool = getPool();
    const [users] = await pool.execute(
      'SELECT id, name, surname, email, phone, avatar, created_at FROM users WHERE id = ?',
      [req.user.userId]
    );

    if (users.length === 0) {
      return res.status(404).json({ error: 'Kullanıcı bulunamadı' });
    }

    res.json({ user: users[0] });
  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({ error: 'Profil bilgileri alınamadı' });
  }
});

// Kullanıcı profili güncelle
router.put('/profile', authenticateToken, async (req, res) => {
  try {
    const { name, surname, phone, avatar } = req.body;
    const pool = getPool();

    // Avatar varsa güncelle, yoksa sadece diğer alanları güncelle
    if (avatar !== undefined) {
      await pool.execute(
        'UPDATE users SET name = ?, surname = ?, phone = ?, avatar = ? WHERE id = ?',
        [name, surname, phone, avatar, req.user.userId]
      );
    } else {
      await pool.execute(
        'UPDATE users SET name = ?, surname = ?, phone = ? WHERE id = ?',
        [name, surname, phone, req.user.userId]
      );
    }

    res.json({ message: 'Profil başarıyla güncellendi' });
  } catch (error) {
    console.error('Update profile error:', error);
    res.status(500).json({ error: 'Profil güncellenemedi' });
  }
});

// Şifre değiştir
router.put('/change-password', authenticateToken, async (req, res) => {
  try {
    const { currentPassword, newPassword } = req.body;
    
    if (!currentPassword || !newPassword) {
      return res.status(400).json({ error: 'Mevcut şifre ve yeni şifre gerekli' });
    }

    if (newPassword.length < 8) {
      return res.status(400).json({ error: 'Yeni şifre en az 8 karakter olmalı' });
    }

    const pool = getPool();
    
    // Mevcut şifreyi kontrol et
    const [users] = await pool.execute(
      'SELECT password FROM users WHERE id = ?',
      [req.user.userId]
    );

    if (users.length === 0) {
      return res.status(404).json({ error: 'Kullanıcı bulunamadı' });
    }

    const user = users[0];
    const isCurrentPasswordValid = await bcrypt.compare(currentPassword, user.password);
    
    if (!isCurrentPasswordValid) {
      return res.status(400).json({ error: 'Mevcut şifre yanlış' });
    }

    // Yeni şifreyi hashle
    const saltRounds = 10;
    const hashedNewPassword = await bcrypt.hash(newPassword, saltRounds);

    // Şifreyi güncelle
    await pool.execute(
      'UPDATE users SET password = ? WHERE id = ?',
      [hashedNewPassword, req.user.userId]
    );

    res.json({ message: 'Şifre başarıyla güncellendi' });
  } catch (error) {
    console.error('Change password error:', error);
    res.status(500).json({ error: 'Şifre değiştirilemedi' });
  }
});

module.exports = router;