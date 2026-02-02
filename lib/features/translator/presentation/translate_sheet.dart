import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';

class TranslateSheet extends StatefulWidget {
  final String text;

  const TranslateSheet({super.key, required this.text});

  @override
  State<TranslateSheet> createState() => _TranslateSheetState();
}

class _TranslateSheetState extends State<TranslateSheet> {
  String _selectedLanguage = 'Spanish';
  String? _translatedText;
  bool _isLoading = false;

  final List<String> _languages = [
    'Spanish',
    'French',
    'German',
    'Italian',
    'Portuguese',
    'Chinese',
    'Japanese',
    'Korean',
    'Arabic',
    'Russian',
  ];

  Future<void> _translate() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate translation (replace with actual AI translation service)
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _translatedText = 'Simulated translation to $_selectedLanguage. Please integrate with a real translation service.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.translate,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.text,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedLanguage,
                decoration: const InputDecoration(
                  labelText: AppStrings.selectLanguage,
                  border: OutlineInputBorder(),
                ),
                items: _languages.map((language) {
                  return DropdownMenuItem(
                    value: language,
                    child: Text(language),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value!;
                    _translatedText = null;
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _translate,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(AppStrings.translate),
              ),
              if (_translatedText != null) ...[
                const SizedBox(height: 16),
                Text(
                  AppStrings.translatedText,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Text(
                    _translatedText!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
