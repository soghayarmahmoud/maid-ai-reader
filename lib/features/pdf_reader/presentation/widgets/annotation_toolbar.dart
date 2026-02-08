// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

/// Annotation Toolbar for PDF editing
class AnnotationToolbar extends StatefulWidget {
  final Function(AnnotationTool) onToolSelected;
  final Function(Color) onColorChanged;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onSave;

  const AnnotationToolbar({
    super.key,
    required this.onToolSelected,
    required this.onColorChanged,
    required this.onUndo,
    required this.onRedo,
    required this.onSave,
  });

  @override
  State<AnnotationToolbar> createState() => _AnnotationToolbarState();
}

class _AnnotationToolbarState extends State<AnnotationToolbar> {
  AnnotationTool _selectedTool = AnnotationTool.none;
  Color _selectedColor = Colors.yellow;
  
  // Preset colors for quick access
  final List<Color> _presetColors = [
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.red,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.cyan,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Annotation Tools
            _buildToolButton(
              icon: Icons.highlight,
              label: 'Highlight',
              tool: AnnotationTool.highlight,
              shortcut: 'Ctrl+H',
            ),
            _buildToolButton(
              icon: Icons.format_underlined,
              label: 'Underline',
              tool: AnnotationTool.underline,
              shortcut: 'Ctrl+U',
            ),
            _buildToolButton(
              icon: Icons.strikethrough_s,
              label: 'Strikeout',
              tool: AnnotationTool.strikeout,
              shortcut: 'Ctrl+S',
            ),
            _buildToolButton(
              icon: Icons.edit,
              label: 'Free Draw',
              tool: AnnotationTool.draw,
              shortcut: 'Ctrl+D',
            ),
            _buildToolButton(
              icon: Icons.text_fields,
              label: 'Text',
              tool: AnnotationTool.text,
              shortcut: 'Ctrl+T',
            ),
            _buildToolButton(
              icon: Icons.comment,
              label: 'Comment',
              tool: AnnotationTool.comment,
              shortcut: 'Ctrl+C',
            ),
            _buildToolButton(
              icon: Icons.arrow_forward,
              label: 'Arrow',
              tool: AnnotationTool.arrow,
            ),
            _buildToolButton(
              icon: Icons.crop_square,
              label: 'Rectangle',
              tool: AnnotationTool.rectangle,
            ),
            _buildToolButton(
              icon: Icons.circle_outlined,
              label: 'Circle',
              tool: AnnotationTool.circle,
            ),
            
            const VerticalDivider(),
            
            // Color Picker
            const SizedBox(width: 8),
            const Text('Color:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            
            // Preset colors
            ...List<Widget>.generate(
              _presetColors.length,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedColor = _presetColors[index];
                      widget.onColorChanged(_selectedColor);
                    });
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _presetColors[index],
                      border: Border.all(
                        color: _selectedColor == _presetColors[index]
                            ? Colors.black
                            : Colors.grey,
                        width: _selectedColor == _presetColors[index] ? 3 : 1,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
            
            // Custom color picker
            const SizedBox(width: 4),
            IconButton(
              icon: Icon(Icons.color_lens, color: _selectedColor),
              onPressed: () => _showColorPicker(context),
              tooltip: 'Custom Color',
            ),
            
            const VerticalDivider(),
            
            // Undo/Redo/Save
            IconButton(
              icon: const Icon(Icons.undo),
              onPressed: widget.onUndo,
              tooltip: 'Undo',
            ),
            IconButton(
              icon: const Icon(Icons.redo),
              onPressed: widget.onRedo,
              tooltip: 'Redo',
            ),
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: widget.onSave,
              tooltip: 'Save Annotations',
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required AnnotationTool tool,
    String? shortcut,
  }) {
    final isSelected = _selectedTool == tool;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(icon),
            onPressed: () {
              setState(() {
                _selectedTool = tool;
                widget.onToolSelected(tool);
              });
            },
            tooltip: shortcut != null ? '$label ($shortcut)' : label,
            color: isSelected ? Theme.of(context).primaryColor : null,
            style: IconButton.styleFrom(
              backgroundColor: isSelected
                  ? Theme.of(context).primaryColor.withOpacity(0.2)
                  : null,
            ),
          ),
          if (isSelected)
            Container(
              width: 40,
              height: 3,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showColorPicker(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) {
              setState(() {
                _selectedColor = color;
                widget.onColorChanged(color);
              });
            },
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

enum AnnotationTool {
  none,
  highlight,
  underline,
  strikeout,
  draw,
  text,
  comment,
  arrow,
  rectangle,
  circle,
}
