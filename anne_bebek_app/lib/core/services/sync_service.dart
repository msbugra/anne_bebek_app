import 'dart:async';
import 'network_service.dart';
import 'database_service.dart';

class SyncService {
  final NetworkService _networkService;
  StreamSubscription? _networkSubscription;
  bool _isSyncing = false;

  SyncService({
    required NetworkService networkService,
    required DatabaseService databaseService,
  }) : _networkService = networkService {
    _networkSubscription = _networkService.stream.listen((status) {
      if (status == NetworkStatus.online) {
        _startSync();
      }
    });
  }

  Future<void> addToQueue(String type, Map<String, dynamic> data) async {
    // Çevrimdışı işlemleri veritabanındaki kuyruğa ekleme mantığı
    // print('Adding to sync queue: $type');
  }

  Future<void> _startSync() async {
    if (_isSyncing || !await _networkService.isConnected) return;

    _isSyncing = true;
    // print('Starting sync...');

    // Kuyruktan verileri alıp sunucuya gönderme mantığı
    // Her işlem sonrası kuyruktan silme

    await Future.delayed(
      const Duration(seconds: 2),
    ); // Simulating network requests

    // print('Sync finished.');
    _isSyncing = false;
  }

  void dispose() {
    _networkSubscription?.cancel();
  }
}
