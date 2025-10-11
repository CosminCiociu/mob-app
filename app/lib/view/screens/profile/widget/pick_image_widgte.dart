import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ovo_meet/core/route/route.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/view/components/image/custom_svg_picture.dart';
import 'package:ovo_meet/view/screens/auth/profile_complete/widget/build_circle_widget.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ovo_meet/view/components/circle_image_button.dart';
import '../../../../../../../../core/utils/my_color.dart';
import '../../../../../../../core/utils/my_images.dart';

class PickImageWidget extends StatefulWidget {
  final String imagePath;
  final VoidCallback onClicked;
  final bool isEdit;

  const PickImageWidget({
    super.key,
    required this.imagePath,
    required this.onClicked,
    this.isEdit = false,
  });

  @override
  State<PickImageWidget> createState() => _PickImageWidgetState();
}

class _PickImageWidgetState extends State<PickImageWidget> {
  XFile? imageFile;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            !widget.isEdit
                ? ClipOval(
                    child: Material(
                        color: MyColor.getTransparentColor(),
                        child: const CircleImageWidget(
                          imagePath: MyImages.profile,
                          width: Dimensions.space70,
                          height: Dimensions.space70,
                          isAsset: true,
                        )),
                  )
                : buildImage(),
            widget.isEdit
                ? Positioned(
                    bottom: 0,
                    right: -4,
                    child: GestureDetector(
                        onTap: () {
                          Get.toNamed(RouteHelper.editProfileScreen);
                        },
                        child: BuildCircleWidget(
                            padding: 3,
                            color: Colors.white,
                            child: BuildCircleWidget(
                                padding: 8,
                                color: MyColor.getPrimaryColor(),
                                child: const CustomSvgPicture(
                                    image: MyImages.edit,
                                    color: MyColor.colorWhite,
                                    height: Dimensions.space10)))),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget buildImage() {
    final Object image;
    if (imageFile != null) {
      image = FileImage(File(imageFile!.path));
    } else if (widget.imagePath.contains('http')) {
      image = NetworkImage(widget.imagePath);
    } else {
      image = const AssetImage(MyImages.profile);
    }

    bool isAsset = widget.imagePath.contains('http') == true ? false : true;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: MyColor.getScreenBgColor(), width: 1),
      ),
      child: ClipOval(
        child: Material(
          color: MyColor.getCardBgColor(),
          child: imageFile != null
              ? Ink.image(
                  image: image as ImageProvider,
                  fit: BoxFit.cover,
                  width: Dimensions.space70,
                  height: Dimensions.space70,
                  child: InkWell(
                    onTap: widget.onClicked,
                  ),
                )
              : CircleImageWidget(
                  press: () {},
                  isAsset: isAsset,
                  imagePath: isAsset ? MyImages.profile : widget.imagePath,
                  height: Dimensions.space70,
                  width: Dimensions.space70,
                ),
        ),
      ),
    );
  }
}
