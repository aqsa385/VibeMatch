import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

enum PhotoSource { camera, gallery }

enum PickStatus { success, cancelled, denied, permanentlyDenied, error }

class PickResult {
  const PickResult(this.status, {this.path});
  final PickStatus status;
  final String? path;
}

class PhotoPickerService {
  final ImagePicker _picker = ImagePicker();

  Future<PickResult> pick(PhotoSource source) async {
    try {
      final permission = await _ensurePermission(source);
      if (permission != PickStatus.success) return PickResult(permission);

      final file = await _picker.pickImage(
        source: source == PhotoSource.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 90,
      );

      if (file == null) return const PickResult(PickStatus.cancelled);
      return PickResult(PickStatus.success, path: file.path);
    } catch (_) {
      return const PickResult(PickStatus.error);
    }
  }

  Future<PickStatus> _ensurePermission(PhotoSource source) async {
    if (source == PhotoSource.camera) {
      final status = await Permission.camera.request();
      if (status.isGranted) return PickStatus.success;
      if (status.isPermanentlyDenied) return PickStatus.permanentlyDenied;
      return PickStatus.denied;
    }

    // Gallery: Android 13+ uses "photos", older Android uses "storage".
    final photos = await Permission.photos.request();
    if (photos.isGranted || photos.isLimited) return PickStatus.success;

    final storage = await Permission.storage.request();
    if (storage.isGranted) return PickStatus.success;

    if (photos.isPermanentlyDenied) return PickStatus.permanentlyDenied;
    return PickStatus.denied;
  }
}