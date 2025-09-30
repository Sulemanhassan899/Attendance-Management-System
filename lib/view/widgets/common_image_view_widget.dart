import 'dart:io';
import 'package:attendance_app/constants/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:svg_flutter/svg.dart';

class CommonImageView extends StatelessWidget {
  // ignore_for_file: must_be_immutable
  String? url;
  String? imagePath;
  String? svgPath;
  File? file;
  double? height;
  double? width;
  double? radius;
  final BoxFit fit;
  final String placeHolder;

  CommonImageView({
    super.key,
    this.url,
    this.imagePath,
    this.svgPath,
    this.file,
    this.height,
    this.width,
    this.radius = 0.0,
    this.fit = BoxFit.cover,
    this.placeHolder = 'assets/images/no_image_found.png',
  });

  @override
  Widget build(BuildContext context) {
    return _buildImageView();
  }

  Widget _buildImageView() {
    if (svgPath != null && svgPath!.isNotEmpty) {
      return Animate(
        effects: [FadeEffect(duration: Duration(milliseconds: 500))],
        child: SizedBox(
          height: height,
          width: width,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius!),
            child: SvgPicture.asset(
              svgPath!,
              height: height,
              width: width,
              fit: fit,
            ),
          ),
        ),
      );
    } else if (file != null && file!.path.isNotEmpty) {
      return Animate(
        effects: [FadeEffect(duration: Duration(milliseconds: 500))],
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius!),
          child: Image.file(file!, height: height, width: width, fit: fit),
        ),
      );
    } else if (url != null && url!.isNotEmpty) {
      return Animate(
        effects: [FadeEffect(duration: Duration(milliseconds: 500))],
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius!),
          child: CachedNetworkImage(
            height: height,
            width: width,
            fit: fit,
            imageUrl: url!,
            placeholder:
                (context, url) => SizedBox(
                  height: 23,
                  width: 23,
                  child: Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: kGreyColor,
                        backgroundColor: Colors.grey.shade100,
                      ),
                    ),
                  ),
                ),
            errorWidget:
                (context, url, error) => Image.asset(
                  placeHolder,
                  height: height,
                  width: width,
                  fit: fit,
                ),
          ),
        ),
      );
    } else if (imagePath != null && imagePath!.isNotEmpty) {
      return Animate(
        effects: [FadeEffect(duration: Duration(milliseconds: 500))],
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius!),
          child: Image.asset(
            imagePath!,
            height: height,
            width: width,
            fit: fit,
          ),
        ),
      );
    }
    return SizedBox();
  }
}

class CommonImageViewWithBorder extends StatelessWidget {
  final String? url;
  final String? imagePath;
  final String? svgPath;
  final File? file;
  final double? height;
  final double? width;
  final double topLeftRadius;
  final double topRightRadius;
  final double bottomLeftRadius;
  final double bottomRightRadius;
  final BoxFit fit;
  final String placeHolder;

  const CommonImageViewWithBorder({
    super.key,
    this.url,
    this.imagePath,
    this.svgPath,
    this.file,
    this.height,
    this.width,
    this.topLeftRadius = 0.0,
    this.topRightRadius = 0.0,
    this.bottomLeftRadius = 0.0,
    this.bottomRightRadius = 0.0,
    this.fit = BoxFit.cover,
    this.placeHolder = 'assets/images/no_image_found.png',
  });

  BorderRadius get borderRadius => BorderRadius.only(
    topLeft: Radius.circular(topLeftRadius),
    topRight: Radius.circular(topRightRadius),
    bottomLeft: Radius.circular(bottomLeftRadius),
    bottomRight: Radius.circular(bottomRightRadius),
  );

  @override
  Widget build(BuildContext context) {
    return _buildImageView();
  }

  Widget _buildImageView() {
    if (svgPath != null && svgPath!.isNotEmpty) {
      return SizedBox(
        height: height,
        width: width,
        child: ClipRRect(
          borderRadius: borderRadius,
          child: SvgPicture.asset(
            svgPath!,
            height: height,
            width: width,
            fit: fit,
          ),
        ),
      );
    } else if (file != null && file!.path.isNotEmpty) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: Image.file(file!, height: height, width: width, fit: fit),
      );
    } else if (url != null && url!.isNotEmpty) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: CachedNetworkImage(
          height: height,
          width: width,
          fit: fit,
          imageUrl: url!,
          placeholder:
              (context, url) => SizedBox(
                height: 23,
                width: 23,
                child: Center(
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: kGreyColor,
                      backgroundColor: Colors.grey.shade100,
                    ),
                  ),
                ),
              ),
          errorWidget:
              (context, url, error) => Image.asset(
                placeHolder,
                height: height,
                width: width,
                fit: fit,
              ),
        ),
      );
    } else if (imagePath != null && imagePath!.isNotEmpty) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: Image.asset(imagePath!, height: height, width: width, fit: fit),
      );
    }
    return const SizedBox();
  }
}
