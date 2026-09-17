import 'package:flutter/material.dart';
import '../../core/services/connectivity_service.dart';

/// Wraps the app shell and shows a persistent offline banner whenever
/// connectivity drops, per the paper's requirement to clearly detect
/// and surface network availability rather than fail silently.
class ConnectivityBanner extends StatefulWidget {
  final Widget child;
  const ConnectivityBanner({super.key, required this.child});

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner> {
  final _connectivityService = ConnectivityService();
  bool _online = true;

  @override
  void initState() {
    super.initState();
    _check();
    _connectivityService.onStatusChange.listen((online) {
      if (mounted) setState(() => _online = online);
    });
  }

  Future<void> _check() async {
    final online = await _connectivityService.isOnline();
    if (mounted) setState(() => _online = online);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (!_online)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              width: double.infinity,
              color: Colors.red.shade600,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: const SafeArea(
                bottom: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'You are offline. Previously loaded data may be shown; '
                        'changes require an internet connection.',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
