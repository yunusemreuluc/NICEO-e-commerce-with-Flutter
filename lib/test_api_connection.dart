import 'package:flutter/material.dart';
import 'services/api_service.dart';

class TestApiConnection extends StatefulWidget {
  const TestApiConnection({super.key});

  @override
  State<TestApiConnection> createState() => _TestApiConnectionState();
}

class _TestApiConnectionState extends State<TestApiConnection> {
  String _result = 'Test edilmedi';
  bool _testing = false;

  Future<void> _testConnection() async {
    setState(() {
      _testing = true;
      _result = 'Test ediliyor...';
    });

    try {
      final isConnected = await ApiService.checkConnection();
      setState(() {
        _result = isConnected 
          ? '✅ API bağlantısı başarılı!\nURL: http://10.0.2.2:4003/api'
          : '❌ API bağlantısı başarısız!\nURL: http://10.0.2.2:4003/api';
        _testing = false;
      });
    } catch (e) {
      setState(() {
        _result = '❌ Hata: $e';
        _testing = false;
      });
    }
  }

  Future<void> _testRegister() async {
    setState(() {
      _testing = true;
      _result = 'Kayıt testi yapılıyor...';
    });

    try {
      final result = await ApiService.register(
        name: 'Test',
        surname: 'Flutter',
        email: 'test.flutter@example.com',
        phone: '05551234567',
        password: 'test123',
      );

      setState(() {
        _result = result['success'] 
          ? '✅ Kayıt başarılı!\n${result['data']['message']}'
          : '❌ Kayıt başarısız!\n${result['error']}';
        _testing = false;
      });
    } catch (e) {
      setState(() {
        _result = '❌ Hata: $e';
        _testing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Bağlantı Testi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'API Bağlantı Durumu:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _result,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _testing ? null : _testConnection,
              child: _testing 
                ? const CircularProgressIndicator()
                : const Text('Bağlantı Testi'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _testing ? null : _testRegister,
              child: _testing 
                ? const CircularProgressIndicator()
                : const Text('Kayıt Testi'),
            ),
          ],
        ),
      ),
    );
  }
}