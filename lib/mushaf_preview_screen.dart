import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tajweed/mushaf_db_initializer.dart';
import 'package:tajweed/mushaf_db_reader.dart';
import 'package:tajweed/mushaf_html_generator.dart';

/// Screen for generating Mushaf HTML with Tajweed coloring
class MushafPreviewScreen extends StatefulWidget {
  const MushafPreviewScreen({super.key});

  @override
  State<MushafPreviewScreen> createState() => _MushafPreviewScreenState();
}

class _MushafPreviewScreenState extends State<MushafPreviewScreen> {
  bool _isGenerating = false;
  String _statusMessage = '';
  int _currentPage = 0;
  int _totalPages = 0;
  String? _outputPath;

  // Page range for generation
  int _startPage = 1;
  int _endPage = 5;

  // Page size selection
  PageSize _selectedPageSize = PageSize.a4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mushaf HTML Generator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page range selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Page Range',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: 'Start Page',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            controller: TextEditingController(
                              text: _startPage.toString(),
                            ),
                            onChanged: (value) {
                              final parsed = int.tryParse(value);
                              if (parsed != null && parsed > 0) {
                                _startPage = parsed;
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: 'End Page',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            controller: TextEditingController(
                              text: _endPage.toString(),
                            ),
                            onChanged: (value) {
                              final parsed = int.tryParse(value);
                              if (parsed != null && parsed > 0) {
                                _endPage = parsed;
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Quran Mushaf has 604 pages total',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Page size selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Page Size',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    SegmentedButton<PageSize>(
                      segments: const [
                        ButtonSegment(
                          value: PageSize.a3,
                          label: Text('A3'),
                          icon: Icon(Icons.crop_landscape),
                        ),
                        ButtonSegment(
                          value: PageSize.a4,
                          label: Text('A4'),
                          icon: Icon(Icons.description),
                        ),
                        ButtonSegment(
                          value: PageSize.a5,
                          label: Text('A5'),
                          icon: Icon(Icons.crop_portrait),
                        ),
                      ],
                      selected: {_selectedPageSize},
                      onSelectionChanged: (Set<PageSize> selection) {
                        setState(() {
                          _selectedPageSize = selection.first;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_selectedPageSize.name}: ${_selectedPageSize.widthMm}mm × ${_selectedPageSize.heightMm}mm, Font: ${_selectedPageSize.fontSize}px',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Generate button
            Center(
              child: ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generateHtml,
                icon: _isGenerating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.file_download),
                label: Text(_isGenerating ? 'Generating...' : 'Generate HTML'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Progress and status
            if (_isGenerating || _statusMessage.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      if (_isGenerating && _totalPages > 0) ...[
                        LinearProgressIndicator(
                          value: _currentPage / _totalPages,
                        ),
                        const SizedBox(height: 8),
                        Text('Processing page $_currentPage of $_totalPages'),
                      ] else if (_statusMessage.isNotEmpty &&
                          !_isGenerating) ...[
                        const SizedBox(height: 8),
                        Text(_statusMessage),
                      ],
                    ],
                  ),
                ),
              ),

            // Output path
            if (_outputPath != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green, width: 2),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            'HTML Generated Successfully!',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        'Saved to: $_outputPath',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _openOutputFolder,
                        icon: const Icon(Icons.folder_open),
                        label: const Text('Open Folder'),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Tajweed color legend
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tajweed Color Legend',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: const [
                        _ColorLegendItem(
                            color: Color(0xFF4CAF50), label: 'Lafzatullah'),
                        _ColorLegendItem(
                            color: Color(0xFF06B0B6), label: 'Izhar'),
                        _ColorLegendItem(
                            color: Color(0xFFB71C1C), label: 'Ikhfaa'),
                        _ColorLegendItem(
                            color: Color(0xFFF06292),
                            label: 'Idgham w/ Ghunna'),
                        _ColorLegendItem(
                            color: Color(0xFF2196F3), label: 'Iqlab'),
                        _ColorLegendItem(
                            color: Color(0xFF7B8F0A), label: 'Qalqala'),
                        _ColorLegendItem(
                            color: Color(0xFFFF9800), label: 'Ghunna'),
                        _ColorLegendItem(
                            color: Color(0xFF8E64D6), label: 'Prolonging'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateHtml() async {
    setState(() {
      _isGenerating = true;
      _statusMessage = 'Initializing databases...';
      _currentPage = 0;
      _totalPages = _endPage - _startPage + 1;
      _outputPath = null;
    });

    try {
      // Initialize databases
      await MushafDbInitializer.initialize();

      setState(() {
        _statusMessage = 'Opening databases...';
      });

      // Open database reader
      final dbReader = MushafDbReader();
      await dbReader.open();

      setState(() {
        _statusMessage = 'Generating HTML...';
      });

      // Generate HTML
      final generator =
          MushafHtmlGenerator(dbReader, pageSize: _selectedPageSize);
      final html = await generator.generateHtml(
        startPage: _startPage,
        endPage: _endPage,
        onProgress: (current, total) {
          setState(() {
            _currentPage = current;
            _totalPages = total;
            _statusMessage = 'Processing page $current of $total...';
          });
        },
      );

      // Close database
      await dbReader.close();

      setState(() {
        _statusMessage = 'Saving file...';
      });

      // Save to documents directory
      final docsDir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName =
          'mushaf_${_selectedPageSize.name}_pages_${_startPage}_to_${_endPage}_$timestamp.html';
      final outputFile = File('${docsDir.path}/$fileName');
      await outputFile.writeAsString(html);

      setState(() {
        _isGenerating = false;
        _statusMessage = 'Completed successfully!';
        _outputPath = outputFile.path;
      });
    } catch (e) {
      setState(() {
        _isGenerating = false;
        _statusMessage = 'Error: $e';
      });
    }
  }

  void _openOutputFolder() {
    if (_outputPath == null) return;

    final file = File(_outputPath!);
    final folder = file.parent.path;

    // Open folder in system file manager (macOS)
    Process.run('open', [folder]);
  }
}

class _ColorLegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _ColorLegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
