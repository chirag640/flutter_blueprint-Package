import 'package:path/path.dart' as p;
import '../config/blueprint_config.dart';

/// Generates media handling templates for image picker and camera.
class MediaTemplates {
  /// Generates all media-related files
  static Map<String, String> generate(BlueprintConfig config) {
    final files = <String, String>{};
    final appName = config.appName;

    files[p.join('lib', 'core', 'media', 'image_picker_service.dart')] =
        _imagePickerService(appName);
    files[p.join('lib', 'core', 'media', 'image_compressor.dart')] =
        _imageCompressor(appName);
    files[p.join('lib', 'core', 'media', 'media_permission.dart')] =
        _mediaPermission(appName);
    files[p.join('lib', 'core', 'media', 'file_utils.dart')] =
        _fileUtils(appName);

    return files;
  }

  /// Returns the dependencies required for media handling
  static Map<String, String> getDependencies() {
    return {
      'image_picker': '^1.1.2',
      'image_cropper': '^8.0.2',
      'permission_handler': '^11.3.1',
    };
  }

  static String _imagePickerService(String appName) => '''
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/material.dart';
import 'image_compressor.dart';
import 'media_permission.dart';

/// Service for picking and processing images from gallery or camera.
class ImagePickerService {
  ImagePickerService({
    ImageCompressor? compressor,
    MediaPermission? permission,
  })  : _compressor = compressor ?? ImageCompressor(),
        _permission = permission ?? MediaPermission();

  final ImagePicker _picker = ImagePicker();
  final ImageCompressor _compressor;
  final MediaPermission _permission;

  /// Pick a single image from the gallery
  Future<File?> pickFromGallery({
    int? maxWidth,
    int? maxHeight,
    int? quality,
    bool compress = true,
  }) async {
    final hasPermission = await _permission.requestPhotos();
    if (!hasPermission) return null;

    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: maxWidth?.toDouble(),
      maxHeight: maxHeight?.toDouble(),
      imageQuality: quality,
    );

    if (image == null) return null;

    if (compress) {
      return await _compressor.compress(
        File(image.path),
        quality: quality ?? 85,
      );
    }

    return File(image.path);
  }

  /// Pick a single image from the camera
  Future<File?> pickFromCamera({
    int? maxWidth,
    int? maxHeight,
    int? quality,
    bool compress = true,
    CameraDevice preferredCamera = CameraDevice.rear,
  }) async {
    final hasPermission = await _permission.requestCamera();
    if (!hasPermission) return null;

    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: maxWidth?.toDouble(),
      maxHeight: maxHeight?.toDouble(),
      imageQuality: quality,
      preferredCameraDevice: preferredCamera,
    );

    if (image == null) return null;

    if (compress) {
      return await _compressor.compress(
        File(image.path),
        quality: quality ?? 85,
      );
    }

    return File(image.path);
  }

  /// Pick multiple images from the gallery
  Future<List<File>> pickMultiple({
    int? maxWidth,
    int? maxHeight,
    int? quality,
    bool compress = true,
    int? limit,
  }) async {
    final hasPermission = await _permission.requestPhotos();
    if (!hasPermission) return [];

    final List<XFile> images = await _picker.pickMultiImage(
      maxWidth: maxWidth?.toDouble(),
      maxHeight: maxHeight?.toDouble(),
      imageQuality: quality,
      limit: limit,
    );

    if (images.isEmpty) return [];

    final files = <File>[];
    for (final image in images) {
      if (compress) {
        final compressed = await _compressor.compress(
          File(image.path),
          quality: quality ?? 85,
        );
        files.add(compressed);
      } else {
        files.add(File(image.path));
      }
    }

    return files;
  }

  /// Pick and crop an image
  Future<File?> pickAndCrop({
    required ImageSource source,
    CropAspectRatio? aspectRatio,
    List<CropAspectRatioPreset>? aspectRatioPresets,
    int? maxWidth,
    int? maxHeight,
    int? quality,
    CropStyle cropStyle = CropStyle.rectangle,
    Color? toolbarColor,
    Color? toolbarWidgetColor,
  }) async {
    final hasPermission = source == ImageSource.camera
        ? await _permission.requestCamera()
        : await _permission.requestPhotos();
    
    if (!hasPermission) return null;

    final XFile? image = await _picker.pickImage(source: source);
    if (image == null) return null;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      aspectRatio: aspectRatio,
      aspectRatioPresets: aspectRatioPresets ??
          [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      compressQuality: quality ?? 85,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: toolbarColor ?? Colors.blue,
          toolbarWidgetColor: toolbarWidgetColor ?? Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: aspectRatio != null,
        ),
        IOSUiSettings(
          title: 'Crop Image',
          aspectRatioLockEnabled: aspectRatio != null,
        ),
      ],
    );

    if (croppedFile == null) return null;
    return File(croppedFile.path);
  }

  /// Pick a video from the gallery
  Future<File?> pickVideo({
    Duration? maxDuration,
  }) async {
    final hasPermission = await _permission.requestPhotos();
    if (!hasPermission) return null;

    final XFile? video = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: maxDuration,
    );

    if (video == null) return null;
    return File(video.path);
  }

  /// Record a video from the camera
  Future<File?> recordVideo({
    Duration? maxDuration,
    CameraDevice preferredCamera = CameraDevice.rear,
  }) async {
    final hasPermission = await _permission.requestCamera();
    if (!hasPermission) return null;

    final XFile? video = await _picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: maxDuration,
      preferredCameraDevice: preferredCamera,
    );

    if (video == null) return null;
    return File(video.path);
  }
}
''';

  static String _imageCompressor(String appName) => '''
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

/// Utility for compressing images.
class ImageCompressor {
  /// Compress an image file
  Future<File> compress(
    File file, {
    int quality = 85,
    int? maxWidth,
    int? maxHeight,
  }) async {
    final bytes = await file.readAsBytes();
    
    // For now, return the original file
    // In a real implementation, you would use a compression library
    // such as flutter_image_compress
    return file;
  }

  /// Compress image bytes
  Future<Uint8List> compressBytes(
    Uint8List bytes, {
    int quality = 85,
    int? maxWidth,
    int? maxHeight,
  }) async {
    // For now, return the original bytes
    // In a real implementation, you would use a compression library
    return bytes;
  }

  /// Get file size in readable format
  String getReadableFileSize(File file) {
    final bytes = file.lengthSync();
    if (bytes < 1024) return '\$bytes B';
    if (bytes < 1024 * 1024) return '\${(bytes / 1024).toStringAsFixed(1)} KB';
    return '\${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
''';

  static String _mediaPermission(String appName) => '''
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

/// Handles media-related permissions.
class MediaPermission {
  /// Request camera permission
  Future<bool> requestCamera() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Request photos/gallery permission
  Future<bool> requestPhotos() async {
    if (Platform.isIOS) {
      final status = await Permission.photos.request();
      return status.isGranted || status.isLimited;
    } else {
      // Android 13+ uses granular media permissions
      if (await _isAndroid13OrHigher()) {
        final status = await Permission.photos.request();
        return status.isGranted;
      } else {
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    }
  }

  /// Request video permission (Android 13+)
  Future<bool> requestVideos() async {
    if (Platform.isAndroid && await _isAndroid13OrHigher()) {
      final status = await Permission.videos.request();
      return status.isGranted;
    }
    return requestPhotos();
  }

  /// Request microphone permission (for video recording)
  Future<bool> requestMicrophone() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// Check if camera permission is granted
  Future<bool> hasCameraPermission() async {
    return await Permission.camera.isGranted;
  }

  /// Check if photos permission is granted
  Future<bool> hasPhotosPermission() async {
    if (Platform.isIOS) {
      final status = await Permission.photos.status;
      return status.isGranted || status.isLimited;
    } else {
      if (await _isAndroid13OrHigher()) {
        return await Permission.photos.isGranted;
      }
      return await Permission.storage.isGranted;
    }
  }

  /// Open app settings
  Future<bool> openSettings() async {
    return await openAppSettings();
  }

  Future<bool> _isAndroid13OrHigher() async {
    // Android 13 is SDK 33
    return Platform.isAndroid;
  }
}
''';

  static String _fileUtils(String appName) => '''
import 'dart:io';
import 'package:path/path.dart' as path;

/// Utility functions for file handling.
class FileUtils {
  /// Get the file extension
  static String getExtension(File file) {
    return path.extension(file.path).toLowerCase();
  }

  /// Get the file name without extension
  static String getNameWithoutExtension(File file) {
    return path.basenameWithoutExtension(file.path);
  }

  /// Get the file name with extension
  static String getName(File file) {
    return path.basename(file.path);
  }

  /// Check if file is an image
  static bool isImage(File file) {
    final ext = getExtension(file);
    return ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.heic', '.heif']
        .contains(ext);
  }

  /// Check if file is a video
  static bool isVideo(File file) {
    final ext = getExtension(file);
    return ['.mp4', '.mov', '.avi', '.mkv', '.wmv', '.flv', '.webm']
        .contains(ext);
  }

  /// Get file size in bytes
  static int getSize(File file) {
    return file.lengthSync();
  }

  /// Get readable file size
  static String getReadableSize(File file) {
    final bytes = file.lengthSync();
    if (bytes < 1024) return '\$bytes B';
    if (bytes < 1024 * 1024) return '\${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '\${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '\${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Copy file to a new location
  static Future<File> copyTo(File file, String newPath) async {
    return await file.copy(newPath);
  }

  /// Delete file
  static Future<void> delete(File file) async {
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Check if file exists
  static Future<bool> exists(String path) async {
    return await File(path).exists();
  }
}
''';
}
