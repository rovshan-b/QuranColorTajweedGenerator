import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class NumberInput extends StatefulWidget {
  final String label;
  final num value;
  final ValueChanged<num> onChanged;
  final bool isDecimal;
  final Widget? suffix;
  final bool enabled;

  const NumberInput({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.isDecimal = false,
    this.suffix,
    this.enabled = true,
  });

  @override
  State<NumberInput> createState() => _NumberInputState();
}

class _NumberInputState extends State<NumberInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
  }

  @override
  void didUpdateWidget(NumberInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      final currentVal = widget.isDecimal
          ? double.tryParse(_controller.text)
          : int.tryParse(_controller.text);
      if (widget.value != currentVal) {
        _controller.text = widget.value.toString();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: widget.enabled,
      decoration: InputDecoration(
        labelText: widget.label,
        border: const OutlineInputBorder(),
        isDense: true,
        suffixIcon: widget.suffix,
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: widget.isDecimal),
      controller: _controller,
      onChanged: (val) {
        final parsed =
            widget.isDecimal ? double.tryParse(val) : int.tryParse(val);
        if (parsed != null) {
          widget.onChanged(parsed);
        }
      },
    );
  }
}

class TextInput extends StatefulWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final Widget? suffix;
  final bool enabled;

  const TextInput({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.suffix,
    this.enabled = true,
  });

  @override
  State<TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(TextInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: widget.enabled,
      decoration: InputDecoration(
        labelText: widget.label,
        border: const OutlineInputBorder(),
        isDense: true,
        suffixIcon: widget.suffix,
      ),
      controller: _controller,
      onChanged: widget.onChanged,
    );
  }
}

class ColorInput extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final Widget? suffix;
  final bool enabled;

  const ColorInput({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.suffix,
    this.enabled = true,
  });

  Color _parseColor(String hex) {
    try {
      String cleanHex = hex.replaceFirst('#', '');
      if (cleanHex.length == 6) cleanHex = 'FF$cleanHex';
      return Color(int.parse(cleanHex, radix: 16));
    } catch (_) {
      return Colors.black;
    }
  }

  String _toHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase().substring(2)}';
  }

  void _showPicker(BuildContext context) {
    Color pickerColor = _parseColor(value);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pick $label'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (c) => pickerColor = c,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              onChanged(_toHex(pickerColor));
              Navigator.pop(context);
            },
            child: const Text('Select'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(value);
    return InkWell(
      onTap: enabled ? () => _showPicker(context) : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).hintColor,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(value,
                        style: const TextStyle(fontFamily: 'monospace')),
                  ],
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              if (suffix != null) ...[
                const SizedBox(width: 8),
                suffix!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
