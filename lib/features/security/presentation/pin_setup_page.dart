// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../services/pin_service.dart';

class PinSetupPage extends StatefulWidget {
  const PinSetupPage({super.key});

  @override
  State<PinSetupPage> createState() => _PinSetupPageState();
}

class _PinSetupPageState extends State<PinSetupPage> {
  final PinService _pinService = PinService();
  String _enteredPin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  bool _isError = false;

  void _onNumberPressed(String number) {
    if (!_isConfirming) {
      if (_enteredPin.length < 4) {
        setState(() {
          _enteredPin += number;
          _isError = false;
        });

        if (_enteredPin.length == 4) {
          setState(() {
            _isConfirming = true;
          });
        }
      }
    } else {
      if (_confirmPin.length < 4) {
        setState(() {
          _confirmPin += number;
          _isError = false;
        });

        if (_confirmPin.length == 4) {
          _verifyAndSavePin();
        }
      }
    }
  }

  Future<void> _verifyAndSavePin() async {
    if (_enteredPin == _confirmPin) {
      await _pinService.setPin(_enteredPin);
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PIN set successfully!')),
        );
      }
    } else {
      setState(() {
        _isError = true;
        _confirmPin = '';
      });

      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _isError = false;
      });
    }
  }

  void _onBackspacePressed() {
    if (!_isConfirming) {
      if (_enteredPin.isNotEmpty) {
        setState(() {
          _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
          _isError = false;
        });
      }
    } else {
      if (_confirmPin.isNotEmpty) {
        setState(() {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
          _isError = false;
        });
      } else {
        setState(() {
          _isConfirming = false;
          _enteredPin = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPin = _isConfirming ? _confirmPin : _enteredPin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup PIN'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Icon(
              _isConfirming ? Icons.lock_reset : Icons.lock_outline,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 32),

            // Title
            Text(
              _isConfirming ? 'Confirm PIN' : 'Enter New PIN',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),

            // Error message
            if (_isError)
              const Text(
                'PINs do not match. Try again.',
                style: TextStyle(color: Colors.red, fontSize: 14),
              )
            else
              const Text(
                'Enter a 4-digit PIN',
                style: TextStyle(fontSize: 14),
              ),
            const SizedBox(height: 32),

            // PIN Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final isFilled = index < currentPin.length;
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
