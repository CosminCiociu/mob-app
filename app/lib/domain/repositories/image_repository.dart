import 'dart:io';

/// Repository interface for image operations
abstract class ImageRepository {
  /// Pick image from gallery
  Future<File?> pickImageFromGallery();

  /// Pick image from camera
  Future<File?> pickImageFromCamera();

  /// Upload image to storage and return URL
  Future<String?> uploadImage(File imageFile, String path);

  /// Delete image from storage
  Future<void> deleteImage(String imageUrl);
}
