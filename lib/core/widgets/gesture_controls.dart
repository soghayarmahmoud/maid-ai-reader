// ignore_for_file: unused_field

import 'package:flutter/material.dart';

/// Gesture-Enabled PDF Viewer Wrapper
/// Adds pinch-to-zoom and swipe navigation
class GesturePDFWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback onNextPage;
  final VoidCallback onPreviousPage;
  final Function(double) onZoomChanged;
  final double initialZoom;

  const GesturePDFWrapper({
    super.key,
    required this.child,
    required this.onNextPage,
    required this.onPreviousPage,
    required this.onZoomChanged,
    this.initialZoom = 1.0,
  });

  @override
  State<GesturePDFWrapper> createState() => _GesturePDFWrapperState();
}

class _GesturePDFWrapperState extends State<GesturePDFWrapper> {
  double _currentZoom = 1.0;
  Offset _offset = Offset.zero;
  Offset _startFocalPoint = Offset.zero;

  @override
  void initState() {
    super.initState();
    _currentZoom = widget.initialZoom;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Horizontal swipe for page navigation
      onHorizontalDragEnd: (details) {
        if (_currentZoom <= 1.0) {
          // Only navigate when not zoomed
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! > 0) {
              // Swipe right - previous page
              widget.onPreviousPage();
            } else if (details.primaryVelocity! < 0) {
              // Swipe left - next page
              widget.onNextPage();
            }
          }
        }
      },

      // Double tap to zoom
      onDoubleTap: () {
        setState(() {
          if (_currentZoom == 1.0) {
            _currentZoom = 2.0;
          } else {
            _currentZoom = 1.0;
            _offset = Offset.zero;
          }
          widget.onZoomChanged(_currentZoom);
        });
      },

      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        onInteractionStart: (details) {
          _startFocalPoint = details.focalPoint;
        },
        onInteractionUpdate: (details) {
          setState(() {
            _currentZoom = details.scale;
            _offset = details.focalPoint - _startFocalPoint;
          });
        },
        onInteractionEnd: (details) {
          widget.onZoomChanged(_currentZoom);
        },
        child: widget.child,
      ),
    );
  }
}

/// Custom Gesture Detector for Advanced Controls
class AdvancedGestureDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback? onSwipeUp;
  final VoidCallback? onSwipeDown;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final Function(double)? onPinchZoom;

  const AdvancedGestureDetector({
    super.key,
    required this.child,
    this.onSwipeUp,
    this.onSwipeDown,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onDoubleTap,
    this.onLongPress,
    this.onPinchZoom,
  });

  @override
  State<AdvancedGestureDetector> createState() => _AdvancedGestureDetectorState();
}

class _AdvancedGestureDetectorState extends State<AdvancedGestureDetector> {
  static const double _swipeThreshold = 50.0;
  static const double _velocityThreshold = 300.0;

  final double _initialScale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Swipes
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null &&
            details.primaryVelocity!.abs() > _velocityThreshold) {
          if (details.primaryVelocity! > 0) {
            widget.onSwipeDown?.call();
          } else {
            widget.onSwipeUp?.call();
          }
        }
      },
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null &&
            details.primaryVelocity!.abs() > _velocityThreshold) {
          if (details.primaryVelocity! > 0) {
            widget.onSwipeRight?.call();
          } else {
            widget.onSwipeLeft?.call();
          }
        }
      },

      // Double tap
      onDoubleTap: widget.onDoubleTap,

      // Long press
      onLongPress: widget.onLongPress,

      child: widget.child,
    );
  }
}

/// Gesture Control Settings
class GestureSettings {
  bool swipeToNavigate = true;
  bool pinchToZoom = true;
  bool doubleTapToZoom = true;
  bool longPressForMenu = true;
  double swipeSensitivity = 1.0;
  
  // Singleton
  static final GestureSettings _instance = GestureSettings._internal();
  factory GestureSettings() => _instance;
  GestureSettings._internal();
}

/// Gesture Control Settings Page
class GestureControlSettings extends StatefulWidget {
  const GestureControlSettings({super.key});

  @override
  State<GestureControlSettings> createState() => _GestureControlSettingsState();
}

class _GestureControlSettingsState extends State<GestureControlSettings> {
  final _settings = GestureSettings();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gesture Controls'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Swipe to Navigate'),
                  subtitle: const Text('Swipe left/right to change pages'),
                  value: _settings.swipeToNavigate,
                  onChanged: (value) {
                    setState(() {
                      _settings.swipeToNavigate = value;
                    });
                  },
                  secondary: const Icon(Icons.swipe),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Pinch to Zoom'),
                  subtitle: const Text('Use two fingers to zoom in/out'),
                  value: _settings.pinchToZoom,
                  onChanged: (value) {
                    setState(() {
                      _settings.pinchToZoom = value;
                    });
                  },
                  secondary: const Icon(Icons.zoom_in),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Double Tap to Zoom'),
                  subtitle: const Text('Double tap to zoom in/out'),
                  value: _settings.doubleTapToZoom,
                  onChanged: (value) {
                    setState(() {
                      _settings.doubleTapToZoom = value;
                    });
                  },
                  secondary: const Icon(Icons.touch_app),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Long Press for Menu'),
                  subtitle: const Text('Long press to show context menu'),
                  value: _settings.longPressForMenu,
                  onChanged: (value) {
                    setState(() {
                      _settings.longPressForMenu = value;
                    });
                  },
                  secondary: const Icon(Icons.menu),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Swipe Sensitivity',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${(_settings.swipeSensitivity * 100).round()}%',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  Slider(
                    value: _settings.swipeSensitivity,
                    min: 0.5,
                    max: 2.0,
                    divisions: 15,
                    onChanged: (value) {
                      setState(() {
                        _settings.swipeSensitivity = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Gesture Guide
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 12),
                      const Text(
                        'Gesture Guide',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildGestureGuideItem(
                    Icons.swipe_right,
                    'Swipe Left/Right',
                    'Navigate between pages',
                  ),
                  _buildGestureGuideItem(
                    Icons.swipe_up,
                    'Swipe Up/Down',
                    'Scroll within page (when zoomed)',
                  ),
                  _buildGestureGuideItem(
                    Icons.zoom_in,
                    'Pinch',
                    'Zoom in and out of document',
                  ),
                  _buildGestureGuideItem(
                    Icons.touch_app,
                    'Double Tap',
                    'Quick zoom toggle',
                  ),
                  _buildGestureGuideItem(
                    Icons.ads_click,
                    'Long Press',
                    'Show context menu',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGestureGuideItem(IconData icon, String gesture, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gesture,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
