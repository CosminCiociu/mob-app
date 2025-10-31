import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../domain/repositories/image_repository.dart';
import '../../core/utils/dimensions.dart';
import '../../core/utils/firebase_repository_base.dart';

/// Image picker implementation of ImageRepository
class ImagePickerRepository extends FirebaseRepositoryBase
    implements ImageRepository {
  static const String _repositoryName = 'ImagePickerRepository';
  final ImagePicker _picker = ImagePicker();

  @override
  Future<File?> pickImageFromGallery() async {
    return FirebaseRepositoryBase.executeWithErrorHandling(
        'pick image from gallery', () async {
      FirebaseRepositoryBase.logDebug(
          _repositoryName, 'Picking image from gallery');

      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: Dimensions.maxImageWidth,
        maxHeight: Dimensions.maxImageHeight,
        imageQuality: Dimensions.imageQuality,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        FirebaseRepositoryBase.logInfo(
            _repositoryName, 'Successfully picked image from gallery');
        return file;
      }

      FirebaseRepositoryBase.logWarning(
          _repositoryName, 'No image selected from gallery');
      return null;
    });
  }

  @override
  Future<File?> pickImageFromCamera() async {
    return FirebaseRepositoryBase.executeWithErrorHandling(
        'pick image from camera', () async {
      FirebaseRepositoryBase.logDebug(
          _repositoryName, 'Taking photo from camera');

      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: Dimensions.maxImageWidth,
        maxHeight: Dimensions.maxImageHeight,
        imageQuality: Dimensions.imageQuality,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        FirebaseRepositoryBase.logInfo(
            _repositoryName, 'Successfully took photo from camera');
        return file;
      }

      FirebaseRepositoryBase.logWarning(
          _repositoryName, 'No photo taken from camera');
      return null;
    });
  }

  @override
  Future<String?> uploadImage(File imageFile, String path) async {
    return FirebaseRepositoryBase.executeWithErrorHandling('upload image',
        () async {
      FirebaseRepositoryBase.logDebug(
          _repositoryName, 'Uploading image to path: $path');

      // TODO: Implement Firebase Storage upload
      // For now, return the local path
      final localPath = imageFile.path;

      FirebaseRepositoryBase.logInfo(
          _repositoryName, 'Image upload completed (local path returned)');
      return localPath;
    });
  }

  @override
  Future<void> deleteImage(String imageUrl) async {
    return FirebaseRepositoryBase.executeWithErrorHandling('delete image',
        () async {
      FirebaseRepositoryBase.logDebug(
          _repositoryName, 'Deleting image: $imageUrl');

      // TODO: Implement Firebase Storage deletion
      // For now, this is a no-op

      FirebaseRepositoryBase.logInfo(
          _repositoryName, 'Image deletion completed (no-op)');
    });
  }
}
