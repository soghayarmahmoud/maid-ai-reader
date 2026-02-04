// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:maid_ai_reader/core/constants/app_theme.dart' hide AppTheme;
import 'package:maid_ai_reader/core/theme/app_theme.dart';
import 'package:maid_ai_reader/core/widgets/glass_widgets.dart';

/// Theme Customization Page
class ThemeCustomizationPage extends StatefulWidget {
  final VoidCallback onThemeChanged;

  const ThemeCustomizationPage({
    super.key,
    required this.onThemeChanged,
  });

  @override
  State<ThemeCustomizationPage> createState() => _ThemeCustomizationPageState();
}

class _ThemeCustomizationPageState extends State<ThemeCustomizationPage> {
  int _selectedPresetIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Customization'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme Presets
         const ModernSectionHeader(
            title: 'Color Themes',
            icon: Icons.palette,
          ),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: AppTheme.presets.length,
            itemBuilder: (context, index) {
              final preset = AppTheme.presets[index];
              final isSelected = _selectedPresetIndex == index;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPresetIndex = index;
                    AppTheme.applyPreset(preset);
                    widget.onThemeChanged();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${preset.name} theme applied!'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: GlassCard(
                  opacity: isSelected ? 0.2 : 0.1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Color circles
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildColorCircle(preset.primary),
                          const SizedBox(width: 8),
                          _buildColorCircle(preset.secondary),
                          const SizedBox(width: 8),
                          _buildColorCircle(preset.accent),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        preset.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      if (isSelected) ...[
                        const SizedBox(height: 4),
                        Icon(
                          Icons.check_circle,
                          color: preset.primary,
                          size: 20,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 32),

          // Custom Colors
       const ModernSectionHeader(
            title: 'Custom Colors',
            icon: Icons.color_lens,
          ),

          GlassCard(
            child: Column(
              children: [
                _buildColorPicker(
                  'Primary Color',
                  AppTheme.primaryColor,
                  (color) {
                    setState(() {
                      AppTheme.primaryColor = color;
                      widget.onThemeChanged();
                    });
                  },
                ),
                const Divider(height: 24),
                _buildColorPicker(
                  'Secondary Color',
                  AppTheme.secondaryColor,
                  (color) {
                    setState(() {
                      AppTheme.secondaryColor = color;
                      widget.onThemeChanged();
                    });
                  },
                ),
                const Divider(height: 24),
                _buildColorPicker(
                  'Accent Color',
                  AppTheme.accentColor,
                  (color) {
                    setState(() {
                      AppTheme.accentColor = color;
                      widget.onThemeChanged();
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Page Transitions
         const ModernSectionHeader(
            title: 'Page Transitions',
            icon: Icons.animation,
          ),

          GlassCard(
            child: Column(
              children: TransitionType.values.map((type) {
                return RadioListTile<TransitionType>(
                  title: Text(_getTransitionName(type)),
                  subtitle: Text(_getTransitionDescription(type)),
                  value: type,
                  groupValue: TransitionType.slide, // Default
                  onChanged: (value) {
                    // Save to preferences
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            '${_getTransitionName(type)} transition selected'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 32),

          // Preview
         const ModernSectionHeader(
            title: 'Preview',
            icon: Icons.visibility,
          ),

          GlassCard(
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Primary Button'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryColor,
                  ),
                  child: const Text('Secondary Button'),
                ),
                const SizedBox(height: 12),
                Chip(
                  label: const Text('Chip Preview'),
                  avatar:
                      Icon(Icons.check, color: AppTheme.primaryColor, size: 18),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: 0.7,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation(AppTheme.primaryColor),
                ),
              ],
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Theme saved!')),
          );
        },
        icon: const Icon(Icons.save),
        label: const Text('Save Theme'),
      ),
    );
  }

  Widget _buildColorCircle(Color color) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPicker(
      String label, Color color, ValueChanged<Color> onColorChanged) {
    return ListTile(
      title: Text(label),
      trailing: GestureDetector(
        onTap: () {
          // TODO: Open color picker dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Pick $label'),
              content: const Text(
                  'Color picker would go here.\nUse flutter_colorpicker package.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300, width: 2),
          ),
        ),
      ),
    );
  }

  String _getTransitionName(TransitionType type) {
    switch (type) {
      case TransitionType.fade:
        return 'Fade';
      case TransitionType.slide:
        return 'Slide';
      case TransitionType.scale:
        return 'Scale';
      case TransitionType.rotation:
        return 'Rotation';
    }
  }

  String _getTransitionDescription(TransitionType type) {
    switch (type) {
      case TransitionType.fade:
        return 'Smooth fade in/out effect';
      case TransitionType.slide:
        return 'Slide from right to left';
      case TransitionType.scale:
        return 'Scale up from center';
      case TransitionType.rotation:
        return 'Rotate and fade effect';
    }
  }
}
