import 'package:attendance_app/constants/app_colors.dart';
import 'package:attendance_app/view/widgets/text_widget.dart';
import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ButtonWidget extends StatelessWidget {
  const ButtonWidget({
    super.key,
    required this.buttonText,
    this.onTap,
    this.height = 48,
    this.width,
    this.backgroundColor,
    this.fontColor,
    this.fontSize = 15,
    this.outlineColor = kTransperentColor,
    this.radius = 6,
    this.svgIcon,
    this.haveSvg = false,
    this.choiceIcon,
    this.isleft = false,
    this.mhoriz = 0,
    this.hasicon = false,
    this.hasshadow = false,
    this.mBottom = 0,
    this.hasgrad = false,
    this.isactive = true,
    this.mTop = 0,
    this.fontWeight = FontWeight.w400,
  });

  final String buttonText;
  final VoidCallback? onTap; // <-- made nullable
  final double? height;
  final double? width;
  final double radius;
  final double fontSize;
  final Color outlineColor;
  final bool hasicon, isleft, hasshadow, hasgrad, isactive;
  final Color? backgroundColor, fontColor;
  final String? svgIcon, choiceIcon;
  final bool haveSvg;
  final double mTop, mBottom, mhoriz;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onTap == null;

    return Bounce(
      duration: Duration(milliseconds: isDisabled ? 0 : 100),
      onTap: isDisabled ? null : onTap, // <-- disable bounce if null
      child: Opacity(
        opacity: isDisabled ? 0.6 : 1.0, // <-- faded look when disabled
        child: Container(
          margin: EdgeInsets.only(
            top: mTop,
            bottom: mBottom,
            left: mhoriz,
            right: mhoriz,
          ),
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: backgroundColor ?? kPrimaryColor,
            border: Border.all(color: outlineColor),
            borderRadius: BorderRadius.circular(radius),
            boxShadow: hasshadow
                ? [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: TextWidget(
                text: buttonText,
                size: fontSize,
                letterSpacing: 0.5,
                color: fontColor ?? kWhite,
                weight: fontWeight,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
