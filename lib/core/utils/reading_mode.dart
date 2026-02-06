import 'package:flutter/material.dart';

/// Reading Mode Manager
class ReadingMode {
  static final ReadingMode _instance = ReadingMode._internal();
  factory ReadingMode() => _instance;
  ReadingMode._internal();

  bool _isDistractionFree = false;
  bool _isNightMode = false;
  double _nightModeWarmth = 0.5;
  double _brightness = 1.0;
  ReadingModeType _currentMode = ReadingModeType.normal;

  bool get isDistractionFree => _isDistractionFree;
  bool get isNightMode => _isNightMode;
  double get nightModeWarmth => _nightModeWarmth;
  double get brightness => _brightness;
  ReadingModeType get currentMode => _currentMode;

  void setDistractionFree(bool value) {
    _isDistractionFree = value;
    _notifyListeners();
  }

  void setNightMode(bool value) {
    _isNightMode = value;
    _notifyListeners();
  }

  void setNightModeWarmth(double value) {
    _nightModeWarmth = value.clamp(0.0, 1.0);
    _notifyListeners();
  }

  void setBrightness(double value) {
    _brightness = value.clamp(0.0, 1.0);
    _notifyListeners();
  }

  void setMode(ReadingModeType mode) {
    _currentMode = mode;
    switch (mode) {
      case ReadingModeType.normal:
        _isDistractionFree = false;
        _isNightMode = false;
        break;
      case ReadingModeType.focus:
        _isDistractionFree = true;
        _isNightMode = false;
        break;
      case ReadingModeType.night:
        _isNightMode = true;
        _isDistractionFree = false;
        break;
      case ReadingModeType.nightFocus:
        _isNightMode = true;
        _isDistractionFree = true;
        break;
    }
    _notifyListeners();
  }

  final List<VoidCallback> _listeners = [];

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }
}

enum ReadingModeType {
  normal,
  focus, // Distraction-free
  night, // Night mode with warmth
  nightFocus, // Both combined
}

/// Reading Mode Control Panel
class ReadingModePanel extends StatefulWidget {
  const ReadingModePanel({super.key});

  @override
  State<ReadingModePanel> createState() => _ReadingModePanelState();
}

class _ReadingModePanelState extends State<ReadingModePanel> {
  final _readingMode = ReadingMode();

  @override
  void initState() {
    super.initState();
    _readingMode.addListener(_onModeChanged);
  }

  @override
  void dispose() {
    _readingMode.removeListener(_onModeChanged);
    super.dispose();
  }

  void _onModeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reading Mode',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),

          // Mode Selection
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: ReadingModeType.values.map((mode) {
              final isSelected = _readingMode.currentMode == mode;
              return ChoiceChip(
                label: Text(_getModeLabel(mode)),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    _readingMode.setMode(mode);
                  }
                },
                avatar: Icon(
                  _getModeIcon(mode),
                  size: 18,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Night Mode Warmth
          if (_readingMode.isNightMode) ...[
            Row(
              children: [
                const Icon(Icons.thermostat, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Warmth'),
                          Text(
                            '${(_readingMode.nightModeWarmth * 100).round()}%',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      Slider(
                        value: _readingMode.nightModeWarmth,
                        onChanged: (value) {
                          _readingMode.setNightModeWarmth(value);
                        },
                        activeColor: Color.lerp(
                          Colors.blue,
                          Colors.orange,
                          _readingMode.nightModeWarmth,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Brightness
          Row(
            children: [
              const Icon(Icons.brightness_6, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Brightness'),
                        Text(
                          '${(_readingMode.brightness * 100).round()}%',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    Slider(
                      value: _readingMode.brightness,
                      onChanged: (value) {
                        _readingMode.setBrightness(value);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getModeDescription(_readingMode.currentMode),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getModeLabel(ReadingModeType mode) {
    switch (mode) {
      case ReadingModeType.normal:
        return 'Normal';
      case ReadingModeType.focus:
        return 'Focus';
      case ReadingModeType.night:
        return 'Night';
      case ReadingModeType.nightFocus:
        return 'Night Focus';
    }
  }

  IconData _getModeIcon(ReadingModeType mode) {
    switch (mode) {
      case ReadingModeType.normal:
        return Icons.wb_sunny;
      case ReadingModeType.focus:
        return Icons.center_focus_strong;
      case ReadingModeType.night:
        return Icons.nightlight_round;
      case ReadingModeType.nightFocus:
        return Icons.bedtime;
    }
  }

  String _getModeDescription(ReadingModeType mode) {
    switch (mode) {
      case ReadingModeType.normal:
        return 'Standard reading mode with all interface elements visible.';
      case ReadingModeType.focus:
        return 'Hides distractions for immersive reading experience.';
      case ReadingModeType.night:
        return 'Reduces eye strain with warm colors and reduced brightness.';
      case ReadingModeType.nightFocus:
        return 'Combines night mode warmth with distraction-free interface.';
    }
  }
}
