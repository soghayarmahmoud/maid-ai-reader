import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Service for managing PIN security
class PinService {
  static const _storage = FlutterSecureStorage();
  static const String _pinKey = 'user_pin';
  static const String _pinEnabledKey = 'pin_enabled';

  /// Check if PIN is enabled
  Future<bool> isPinEnabled() async {
    final enabled = await _storage.read(key: _pinEnabledKey);
    return enabled == 'true';
  }

  /// Enable PIN protection
  Future<void> enablePin() async {
    await _storage.write(key: _pinEnabledKey, value: 'true');
  }

  /// Disable PIN protection
  Future<void> disablePin() async {
    await _storage.write(key: _pinEnabledKey, value: 'false');
    await _storage.delete(key: _pinKey);
  }

  /// Set new PIN
  Future<void> setPin(String pin) async {
    // Hash the PIN for security
    final hashedPin = _hashPin(pin);
    await _storage.write(key: _pinKey, value: hashedPin);
    await enablePin();
  }

  /// Verify PIN
  Future<bool> verifyPin(String pin) async {
    final storedHash = await _storage.read(key: _pinKey);
    if (storedHash == null) return false;
    
    final hashedPin = _hashPin(pin);
    return hashedPin == storedHash;
  }

  /// Check if PIN is set
  Future<bool> isPinSet() async {
    final pin = await _storage.read(key: _pinKey);
    return pin != null && pin.isNotEmpty;
  }

  /// Hash PIN for secure storage
  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Clear all PIN data
  Future<void> clearAll() async {
    await _storage.delete(key: _pinKey);
    await _storage.delete(key: _pinEnabledKey);
  }
}
