import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../domain/repositories/image_repository.dart';
import '../../core/utils/dimensions.dart';

/// Image picker implementation of ImageRepository
class ImagePickerRepository implements ImageRepository {
  final ImagePicker _picker = ImagePicker();

  @override
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: Dimensions.maxImageWidth,
        maxHeight: Dimensions.maxImageHeight,
        imageQuality: Dimensions.imageQuality,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick image from gallery: $e');
    }
  }

  @override
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: Dimensions.maxImageWidth,
        maxHeight: Dimensions.maxImageHeight,
        imageQuality: Dimensions.imageQuality,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to take photo: $e');
    }
  }

  @override
  Future<String?> uploadImage(File imageFile, String path) async {
    // TODO: Implement Firebase Storage upload
    // For now, return the local path
    return imageFile.path;
  }

  @override
  Future<void> deleteImage(String imageUrl) async {
    // TODO: Implement Firebase Storage deletion
    // For now, this is a no-op
  }
}
