// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Floating Action Menu with expandable options
class FloatingActionMenu extends StatefulWidget {
  final List<FloatingActionMenuItem> items;
  final IconData icon;
  final Color? backgroundColor;

  const FloatingActionMenu({
    super.key,
    required this.items,
    this.icon = Icons.add,
    this.backgroundColor,
  });

  @override
  State<FloatingActionMenu> createState() => _FloatingActionMenuState();
}

class _FloatingActionMenuState extends State<FloatingActionMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Menu Items
        ...List.generate(widget.items.length, (index) {
          final item = widget.items[index];
          final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: _controller,
              curve: Interval(
                index * 0.1,
                0.5 + (index * 0.1),
                curve: Curves.easeOut,
              ),
            ),
          );

          return ScaleTransition(
            scale: animation,
            child: FadeTransition(
              opacity: animation,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Label
                    if (item.label != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          item.label!,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    if (item.label != null) const SizedBox(width: 12),
                    // Button
                    FloatingActionButton.small(
                      heroTag: 'fab_${item.label}_$index',
                      onPressed: () {
                        _toggle();
                        item.onPressed();
                      },
                      backgroundColor: item.backgroundColor,
                      child: Icon(item.icon, size: 20),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),

        // Main FAB
        FloatingActionButton(
          heroTag: 'fab_main',
          onPressed: _toggle,
          backgroundColor: widget.backgroundColor ?? Theme.of(context).primaryColor,
          child: AnimatedRotation(
            turns: _isExpanded ? 0.125 : 0.0,
            duration: const Duration(milliseconds: 250),
            child: Icon(widget.icon),
          ),
        ),
      ],
    );
  }
}

class FloatingActionMenuItem {
  final String? label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;

  FloatingActionMenuItem({
    this.label,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
  });
}

/// Speed Dial FAB (Circular Layout)
class SpeedDialFAB extends StatefulWidget {
  final List<SpeedDialChild> children;
  final IconData icon;
  final IconData? activeIcon;

  const SpeedDialFAB({
    super.key,
    required this.children,
    this.icon = Icons.menu,
    this.activeIcon,
  });

  @override
  State<SpeedDialFAB> createState() => _SpeedDialFABState();
}

class _SpeedDialFABState extends State<SpeedDialFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      clipBehavior: Clip.none,
      children: [
        // Backdrop
        if (_isOpen)
          GestureDetector(
            onTap: _toggle,
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),

        // Children in circular layout
        ...List.generate(widget.children.length, (index) {
          final angle = (math.pi / 2) * (index / (widget.children.length - 1));
          const distance = 80.0;

          final x = math.cos(angle + math.pi) * distance;
          final y = math.sin(angle + math.pi) * distance;

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final offset = Offset(
                x * _controller.value,
                y * _controller.value,
              );

              return Transform.translate(
                offset: offset,
                child: ScaleTransition(
                  scale: _controller,
                  child: FadeTransition(
                    opacity: _controller,
                    child: child,
                  ),
                ),
              );
            },
            child: FloatingActionButton.small(
              heroTag: 'speed_dial_$index',
              onPressed: () {
                _toggle();
                widget.children[index].onPressed();
              },
              backgroundColor: widget.children[index].backgroundColor,
              child: Icon(widget.children[index].icon, size: 20),
            ),
          );
        }),

        // Main button
        FloatingActionButton(
          heroTag: 'speed_dial_main',
          onPressed: _toggle,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              _isOpen ? (widget.activeIcon ?? Icons.close) : widget.icon,
              key: ValueKey(_isOpen),
            ),
          ),
        ),
      ],
    );
  }
}

class SpeedDialChild {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;

  SpeedDialChild({
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
  });
}
