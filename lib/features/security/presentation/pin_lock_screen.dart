import 'package:flutter/material.dart';
import '../services/pin_service.dart';
import '../services/biometric_service.dart';

class PinLockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;
  final bool canUseBiometric;

  const PinLockScreen({
    super.key,
    required this.onUnlocked,
    this.canUseBiometric = false,
  });

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  final PinService _pinService = PinService();
  final BiometricService _biometricService = BiometricService();
  String _enteredPin = '';
  int _failedAttempts = 0;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    if (widget.canUseBiometric) {
      _tryBiometric();
    }
  }

  Future<void> _tryBiometric() async {
    final authenticated = await _biometricService.authenticate(
      reason: 'Unlock MAID',
    );
    if (authenticated) {
      widget.onUnlocked();
    }
  }

  void _onNumberPressed(String number) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += number;
        _isError = false;
      });

      if (_enteredPin.length == 4) {
        _verifyPin();
      }
    }
  }

  Future<void> _verifyPin() async {
    final isCorrect = await _pinService.verifyPin(_enteredPin);
    
    if (isCorrect) {
      widget.onUnlocked();
    } else {
      setState(() {
        _isError = true;
        _failedAttempts++;
        _enteredPin = '';
      });

      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _isError = false;
      });
    }
  }

  void _onBackspacePressed() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _isError = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Icon/Logo
            Icon(
              Icons.lock_outline,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 32),

            // Title
            Text(
              'Enter PIN',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),

            // Failed attempts message
            if (_failedAttempts > 0)
              Text(
                'Failed attempts: $_failedAttempts',
                style: TextStyle(
                  color: Colors.red.shade400,
                  fontSize: 14,
                ),
              ),
            const SizedBox(height: 32),

            // PIN Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final isFilled = index < _enteredPin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFilled
                        ? (_isError ? Colors.red : Theme.of(context).primaryColor)
                        : Colors.transparent,
                    border: Border.all(
                      color: _isError
                          ? Colors.red
                          : Theme.of(context).primaryColor.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 48),

            // Number Pad
            _buildNumberPad(),

            // Biometric Button
            if (widget.canUseBiometric) ...[
              const SizedBox(height: 24),
              IconButton(
                icon: const Icon(Icons.fingerprint, size: 40),
                onPressed: _tryBiometric,
                color: Theme.of(context).primaryColor,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          _buildNumberRow(['1', '2', '3']),
          _buildNumberRow(['4', '5', '6']),
          _buildNumberRow(['7', '8', '9']),
          _buildNumberRow(['', '0', '<']),
        ],
      ),
    );
  }

  Widget _buildNumberRow(List<String> numbers) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: numbers.map((number) {
          if (number.isEmpty) {
            return const SizedBox(width: 70, height: 70);
          }
          
          if (number == '<') {
            return _buildNumberButton(
              icon: Icons.backspace_outlined,
              onPressed: _onBackspacePressed,
            );
          }

          return _buildNumberButton(
            text: number,
            onPressed: () => _onNumberPressed(number),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNumberButton({
    String? text,
    IconData? icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(35),
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Center(
            child: text != null
                ? Text(
                    text,
                    style: Theme.of(context).textTheme.headlineMedium,
                  )
                : Icon(icon, size: 24),
          ),
        ),
      ),
    );
  }
}
