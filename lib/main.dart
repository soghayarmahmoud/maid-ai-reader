import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'di/service_locator.dart';
import 'features/security/presentation/pin_lock_screen.dart';
import 'features/security/services/pin_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize dependencies
  await initializeDependencies();

  runApp(const MyAppWithSecurity());
}

class MyAppWithSecurity extends StatefulWidget {
  final String? initialFilePath;

  const MyAppWithSecurity({super.key, this.initialFilePath});

  @override
  State<MyAppWithSecurity> createState() => _MyAppWithSecurityState();
}

class _MyAppWithSecurityState extends State<MyAppWithSecurity>
    with WidgetsBindingObserver {
  final PinService _pinService = PinService();
  bool _isLocked = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLockStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _lockApp();
    }
  }

  Future<void> _checkLockStatus() async {
    final pinEnabled = await _pinService.isPinEnabled();
    setState(() {
      _isLocked = pinEnabled;
      _isInitialized = true;
    });
  }

  Future<void> _lockApp() async {
    final pinEnabled = await _pinService.isPinEnabled();
    if (pinEnabled) {
      setState(() {
        _isLocked = true;
      });
    }
  }

  void _unlock() {
    setState(() {
      _isLocked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_isLocked) {
      return MaterialApp(
        home: PinLockScreen(
          onUnlocked: _unlock,
          canUseBiometric: true,
        ),
      );
    }

    return MyApp(initialFilePath: widget.initialFilePath);
  }
}
