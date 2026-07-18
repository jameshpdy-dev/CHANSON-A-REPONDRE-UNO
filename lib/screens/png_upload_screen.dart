import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Lets a user select PNG card images from the local device.
class PngUploadScreen extends StatefulWidget {
  /// Creates the PNG upload screen.
  const PngUploadScreen({super.key});

  @override
  State<PngUploadScreen> createState() => _PngUploadScreenState();
}

/// Holds the selected PNG card images for preview.
class _PngUploadScreenState extends State<PngUploadScreen> {
  List<PlatformFile> _files = const [];

  Future<void> _selectPngFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['png'],
      allowMultiple: true,
      withData: true,
    );
    if (result == null) return;
    setState(() {
      _files = result.files
          .where(
            (file) =>
                file.name.toLowerCase().endsWith('.png') && file.bytes != null,
          )
          .toList(growable: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload PNG Cards'),
        leading: IconButton(
          onPressed: () => context.go('/decks'),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Decks',
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: FilledButton.icon(
              onPressed: _selectPngFiles,
              icon: const Icon(Icons.upload_file_rounded),
              label: const Text('Upload .png cards'),
            ),
          ),
          Expanded(
            child: _files.isEmpty
                ? const Center(
                    child: Text('Select one or more PNG card images.'),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 900
                          ? 5
                          : constraints.maxWidth >= 600
                          ? 3
                          : 2;
                      return GridView.builder(
                        padding: const EdgeInsets.all(20),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: .72,
                        ),
                        itemCount: _files.length,
                        itemBuilder: (context, index) =>
                            _PngCardTile(file: _files[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Renders one selected PNG card and opens it at full size.
class _PngCardTile extends StatelessWidget {
  /// Creates a selected-PNG tile.
  const _PngCardTile({required this.file});

  final PlatformFile file;

  @override
  Widget build(BuildContext context) {
    final bytes = file.bytes!;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => Scaffold(
              appBar: AppBar(title: Text(file.name)),
              body: InteractiveViewer(
                child: Center(child: Image.memory(bytes, fit: BoxFit.contain)),
              ),
            ),
          ),
        ),
        child: Column(
          children: [
            Expanded(child: Image.memory(bytes, fit: BoxFit.cover)),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                file.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
