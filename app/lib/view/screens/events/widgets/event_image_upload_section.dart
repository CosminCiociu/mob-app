import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/core/utils/my_images.dart';
import 'package:ovo_meet/data/controller/events/my_events_controller.dart';

class EventImageUploadSection extends StatelessWidget {
  final MyEventsController controller;

  const EventImageUploadSection({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.space8),
          child: Container(
            width: double.infinity,
            height: 180,
            color: MyColor.getCardBgColor(),
            child: _buildEventImage(),
          ),
        ),
        Positioned(
          top: Dimensions.space15,
          right: Dimensions.space15,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(height: Dimensions.space10),
              _EventImageButton(
                icon: Icons.upload,
                label: MyStrings.uploadImage,
                onTap: controller.showImagePickerOptions,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build event image widget with proper error handling
  Widget _buildEventImage() {
    try {
      // If there's a locally picked image file, use it first
      if (controller.imageFile != null) {
        return Image.file(
          controller.imageFile!,
          width: double.infinity,
          height: 180,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error loading local image file: $error');
            return _buildPlaceholderImage();
          },
        );
      }

      // If there's an event image path
      if (controller.eventImagePath.isNotEmpty) {
        if (controller.eventImagePath.startsWith('http')) {
          // Network image with error handling
          return Image.network(
            controller.eventImagePath,
            width: double.infinity,
            height: 180,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  color: MyColor.getPrimaryColor(),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Error loading network image: $error');
              return _buildPlaceholderImage();
            },
          );
        } else if (controller.eventImagePath.startsWith('assets/')) {
          // Asset image
          return Image.asset(
            controller.eventImagePath,
            width: double.infinity,
            height: 180,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Error loading asset image: $error');
              return _buildPlaceholderImage();
            },
          );
        } else {
          // Try as local file first, then as asset
          return Image.file(
            File(controller.eventImagePath),
            width: double.infinity,
            height: 180,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Error loading local file, trying as asset: $error');
              return Image.asset(
                controller.eventImagePath,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (context, assetError, assetStackTrace) {
                  debugPrint('Error loading as asset too: $assetError');
                  return _buildPlaceholderImage();
                },
              );
            },
          );
        }
      }

      // No image path, use placeholder
      return _buildPlaceholderImage();
    } catch (e) {
      // If any error occurs, use placeholder
      debugPrint('Error in _buildEventImage: $e');
      return _buildPlaceholderImage();
    }
  }

  /// Build placeholder image widget
  Widget _buildPlaceholderImage() {
    return Image.asset(
      MyImages.placeHolderImage,
      width: double.infinity,
      height: 180,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        // If even the placeholder fails, show a simple container
        debugPrint('Error loading placeholder image: $error');
        return Container(
          width: double.infinity,
          height: 180,
          color: MyColor.getGreyColor().withOpacity(0.3),
          child: Center(
            child: Icon(
              Icons.image_not_supported,
              size: 48,
              color: MyColor.getGreyColor(),
            ),
          ),
        );
      },
    );
  }
}

class _EventImageButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _EventImageButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon:
          Icon(icon, color: MyColor.getWhiteColor(), size: Dimensions.space20),
      label: Text(label, style: TextStyle(color: MyColor.getWhiteColor())),
      style: ElevatedButton.styleFrom(
        backgroundColor: MyColor.getBlackColor().withOpacity(0.5),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.space12)),
        elevation: 0,
        padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.space12, vertical: Dimensions.space8),
      ),
    );
  }
}
