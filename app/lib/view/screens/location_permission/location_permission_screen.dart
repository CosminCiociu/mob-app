import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/utils/my_color.dart';
import '../../../core/utils/my_strings.dart';
import '../../../core/utils/dimensions.dart';
import '../../../core/utils/style.dart';
import '../../components/location/location_permission_icon.dart';
import '../../components/location/location_permission_card.dart';
import '../../components/buttons/custom_elevated_button.dart';
import '../../components/app-bar/custom_appbar.dart';

class LocationPermissionScreen extends StatefulWidget {
  final bool showSkipOption;
  final VoidCallback? onSkip;
  final VoidCallback? onLocationEnabled;
  final String? customTitle;
  final String? customDescription;

  const LocationPermissionScreen({
    super.key,
    this.showSkipOption = false,
    this.onSkip,
    this.onLocationEnabled,
    this.customTitle,
    this.customDescription,
  });

  @override
  State<LocationPermissionScreen> createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationServiceDialog();
        return;
      }

      // Check current permission status
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        _handleLocationEnabled();
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        _showOpenSettingsDialog();
        return;
      }

      // Request permission
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        _handleLocationEnabled();
      } else if (permission == LocationPermission.deniedForever) {
        _showOpenSettingsDialog();
      } else {
        _showPermissionDeniedMessage();
      }
    } catch (e) {
      _showErrorMessage('Failed to request location permission: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleLocationEnabled() {
    if (widget.onLocationEnabled != null) {
      widget.onLocationEnabled!();
    } else {
      Get.back(result: true);
    }
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          MyStrings.locationAccessRequired,
          style: boldLarge.copyWith(color: MyColor.getTextColor()),
        ),
        content: Text(
          MyStrings.locationServiceDisabledMessage,
          style:
              regularDefault.copyWith(color: MyColor.getSecondaryTextColor()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              MyStrings.cancel,
              style: regularDefault.copyWith(
                  color: MyColor.getSecondaryTextColor()),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Geolocator.openLocationSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: MyColor.primaryColor,
            ),
            child: Text(
              MyStrings.openSettingsButton,
              style: boldDefault.copyWith(color: MyColor.getWhiteColor()),
            ),
          ),
        ],
      ),
    );
  }

  void _showOpenSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          MyStrings.locationAccessRequired,
          style: boldLarge.copyWith(color: MyColor.getTextColor()),
        ),
        content: Text(
          MyStrings.locationDeniedMessage,
          style:
              regularDefault.copyWith(color: MyColor.getSecondaryTextColor()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              MyStrings.cancel,
              style: regularDefault.copyWith(
                  color: MyColor.getSecondaryTextColor()),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Geolocator.openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: MyColor.primaryColor,
            ),
            child: Text(
              MyStrings.openSettingsButton,
              style: boldDefault.copyWith(color: MyColor.getWhiteColor()),
            ),
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(MyStrings.locationDeniedMessage),
        backgroundColor: MyColor.locationErrorColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: MyColor.locationErrorColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _handleSkip() {
    if (widget.onSkip != null) {
      widget.onSkip!();
    } else {
      Get.back(result: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.getBackgroundColor(),
      appBar: CustomAppBar(
        title: widget.customTitle ?? MyStrings.enableLocation,
        bgColor: MyColor.getBackgroundColor(),
        isShowBackBtn: true,
        isTitleCenter: true,
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.locationScreenPadding),
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Location Icon
                      const LocationPermissionIcon(),

                      const SizedBox(height: Dimensions.space40),

                      // Info Card
                      LocationPermissionCard(
                        title:
                            widget.customTitle ?? MyStrings.allowLocationAccess,
                        description: widget.customDescription ??
                            MyStrings.needLocationForEvents,
                      ),

                      const SizedBox(height: Dimensions.space40),
                    ],
                  ),
                ),

                // Bottom Actions
                Column(
                  children: [
                    // Enable Location Button
                    CustomElevatedBtn(
                      text: MyStrings.enableLocationButton,
                      press: _requestLocationPermission,
                      isLoading: _isLoading,
                      bgColor: MyColor.primaryColor,
                      height: Dimensions.locationButtonHeight,
                    ),

                    // Skip Button (if enabled)
                    if (widget.showSkipOption) ...[
                      const SizedBox(height: Dimensions.space15),
                      TextButton(
                        onPressed: _isLoading ? null : _handleSkip,
                        child: Text(
                          MyStrings.skipForNow,
                          style: regularDefault.copyWith(
                            color: MyColor.getSecondaryTextColor(),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
