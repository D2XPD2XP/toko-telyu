import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  final Connectivity _connectivity = Connectivity();

  Stream<bool> get connectionStatus async* {
    final initial = await _connectivity.checkConnectivity();
    yield !_isOffline(initial);

    yield* _connectivity.onConnectivityChanged.map(
      (result) => !_isOffline(result),
    );
  }

  Future<bool> checkConnection() async {
    final result = await _connectivity.checkConnectivity();
    return !_isOffline(result);
  }

  bool _isOffline(List<ConnectivityResult> results) {
    return results.contains(ConnectivityResult.none);
  }
}


