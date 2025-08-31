import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

enum NetworkStatus { online, offline }

class NetworkService {
  final Connectivity _connectivity = Connectivity();
  late StreamController<NetworkStatus> _controller;

  NetworkService() {
    _controller = StreamController<NetworkStatus>.broadcast();
    _initialize();
  }

  Stream<NetworkStatus> get stream => _controller.stream;

  Future<void> _initialize() async {
    final result = await _connectivity.checkConnectivity();
    _emitStatus(result);
    _connectivity.onConnectivityChanged.listen((result) {
      _emitStatus(result);
    });
  }

  void _emitStatus(List<ConnectivityResult> results) {
    final isConnected = results.any(
      (result) => result != ConnectivityResult.none,
    );
    _controller.add(isConnected ? NetworkStatus.online : NetworkStatus.offline);
  }

  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return results.any((result) => result != ConnectivityResult.none);
  }

  void dispose() {
    _controller.close();
  }
}
