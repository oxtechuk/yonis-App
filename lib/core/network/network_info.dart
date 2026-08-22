import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

import '../logging/app_logger.dart';

/// Meaningful internet status of the device (probe-confirmed), not merely
/// the state of network interfaces.
enum NetworkStatus { online, offline }

/// Single application-level connectivity abstraction.
///
/// Features must never subscribe to raw connectivity_plus themselves — they
/// consume this interface instead (typically via a future use case or a
/// dedicated app-level Cubit when such UI is introduced).
///
/// Naming is deliberately unambiguous:
/// - [hasNetworkInterface]: Wi-Fi/mobile interface exists. Says NOTHING
///   about actual internet reachability.
/// - [hasInternetAccess]: active reachability probe performed; the answer
///   callers should use when "can we actually reach the internet?" matters.
abstract interface class NetworkInfo {
  /// Fast, passive check of the device's network interface state.
  ///
  /// `true` does NOT guarantee that the internet is reachable.
  Future<bool> get hasNetworkInterface;

  /// Active lightweight reachability probe. Answers whether the internet
  /// is actually reachable right now.
  Future<bool> get hasInternetAccess;

  /// Emits transitions between [NetworkStatus.online] and
  /// [NetworkStatus.offline] representing REAL internet availability:
  /// interface events are confirmed with a reachability probe before
  /// reporting online, so an associated-but-unusable network never
  /// produces a false "online".
  Stream<NetworkStatus> get onStatusChanged;
}

class ConnectivityNetworkInfo implements NetworkInfo {
  ConnectivityNetworkInfo({
    required Connectivity connectivity,
    required AppLogger logger,
    Uri? reachabilityUrl,
    this.probeTimeout = const Duration(seconds: 3),
  }) : _connectivity = connectivity,
       _logger = logger,
       _reachabilityUrl =
           reachabilityUrl ??
           Uri.parse('https://www.gstatic.com/generate_204') {
    _subscription = _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
    );
  }

  final Connectivity _connectivity;
  final AppLogger _logger;
  final Uri _reachabilityUrl;
  final Duration probeTimeout;

  final StreamController<NetworkStatus> _statusController =
      StreamController<NetworkStatus>.broadcast();

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Dio? _probeDio;
  int _probeGeneration = 0;

  @override
  Future<bool> get hasNetworkInterface async =>
      !(await _connectivity.checkConnectivity()).contains(
        ConnectivityResult.none,
      );

  @override
  Future<bool> get hasInternetAccess => _verifyReachability();

  @override
  Stream<NetworkStatus> get onStatusChanged => _statusController.stream;

  Future<bool> _verifyReachability() async {
    try {
      final dio = _probeDio ??= Dio(
        BaseOptions(
          connectTimeout: probeTimeout,
          receiveTimeout: probeTimeout,
          sendTimeout: probeTimeout,
        ),
      );
      final response = await dio.headUri<dynamic>(_reachabilityUrl);
      return response.statusCode != null && response.statusCode! < 500;
    } catch (_) {
      return false;
    }
  }

  Future<void> _onConnectivityChanged(List<ConnectivityResult> results) async {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      _probeGeneration++;
      _emit(NetworkStatus.offline);
      return;
    }

    final generation = ++_probeGeneration;
    final reachable = await _verifyReachability();
    if (generation != _probeGeneration) {
      return;
    }
    _emit(reachable ? NetworkStatus.online : NetworkStatus.offline);
  }

  void _emit(NetworkStatus status) {
    if (!_statusController.isClosed) {
      _logger.d('[Connectivity] status -> ${status.name}');
      _statusController.add(status);
    }
  }

  void dispose() {
    _subscription?.cancel();
    _statusController.close();
  }
}
