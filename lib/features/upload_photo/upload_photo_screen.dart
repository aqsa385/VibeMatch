
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../services/photo_picker_service.dart';
import '../choose_option/widgets/option_card.dart';

class UploadPhotoScreen extends StatefulWidget {
  const UploadPhotoScreen({super.key});

  @override
  State<UploadPhotoScreen> createState() => _UploadPhotoScreenState();
}

class _UploadPhotoScreenState extends State<UploadPhotoScreen> {
  final _service = PhotoPickerService();
  bool _busy = false;

  Future<void> _pick(PhotoSource source) async {
    if (_busy) return;
    setState(() => _busy = true);
    final result = await _service.pick(source);
    if (!mounted) return;
    setState(() => _busy = false);

    switch (result.status) {
      case PickStatus.success:
        context.push('/analyzing', extra: result.path!);
        break;

      case PickStatus.cancelled:
        break;

      case PickStatus.denied:
        _snack(source == PhotoSource.camera
            ? 'Camera permission is needed to take a photo.'
            : 'Gallery permission is needed to pick a photo.');
        break;

      case PickStatus.permanentlyDenied:
        _showSettingsDialog(source);
        break;

      case PickStatus.error:
        _snack('Something went wrong. Please try again.');
        break;
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showSettingsDialog(PhotoSource source) {
    final what = source == PhotoSource.camera ? 'camera' : 'photos';

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Permission needed'),
        content: Text(
            'VibeMatch needs access to your $what. Please enable it in app settings.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: const Text('Open settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Vibe Match'), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add a picture',
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Where should we get your photo?',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium,
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 190,
                          child: OptionCard(
                            icon: Icons.photo_camera_rounded,
                            iconColor: const Color(0xFF5C4BDB),
                            background: const Color(0xFFF3E8FF),
                            title: 'Take a photo',
                            subtitle: 'Use your camera',
                            onTap: () => _pick(PhotoSource.camera),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 190,
                          child: OptionCard(
                            icon: Icons.photo_library_rounded,
                            iconColor: const Color(0xFF42A5F5),
                            background: const Color(0xFFE3F2FD),
                            title: 'Upload from gallery',
                            subtitle: 'Pick an existing photo',
                            onTap: () => _pick(PhotoSource.gallery),
                          ),
                        ),
                        if (_busy) ...[
                          const SizedBox(height: 20),
                          const Center(child: CircularProgressIndicator()),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
