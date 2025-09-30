import 'package:attendance_app/constants/app_colors.dart';
import 'package:attendance_app/view/widgets/text_widget.dart';
import 'package:bounce/bounce.dart';

import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ButtonWidget extends StatelessWidget {
  const ButtonWidget({
    super.key,
    required this.onTap,
    required this.buttonText,
    this.height = 48,
    this.width,
    this.backgroundColor,
    this.fontColor,
    this.fontSize = 15,
    this.outlineColor = kTransperentColor,
    this.radius = 7,
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
  final VoidCallback onTap;
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
    return 
       Bounce(
        duration: Duration(milliseconds: isactive ? 100 : 0),
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.only(
            top: mTop,
            bottom: mBottom,
            left: mhoriz,
            right: mhoriz,
          ),
          height: height,
          width: width,
          decoration:
              hasgrad
                  ? BoxDecoration(
                    color: backgroundColor ?? kPrimaryColor,
                    border: Border.all(color: outlineColor),
                    borderRadius: BorderRadius.circular(radius),
                  )
                  : BoxDecoration(
                    color:
                        isactive
                            ? backgroundColor ?? kTransperentColor
                            : backgroundColor ??
                                Color(0xff0E1A34).withOpacity(0.35),
                    border: Border.all(color: outlineColor),
                    borderRadius: BorderRadius.circular(radius),
                  ),
          child: Material(
            color: kTransperentColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
               
                TextWidget(
                  paddingLeft: hasicon ? 10 : 0,
                  text: buttonText,
                  size: fontSize,
                  letterSpacing: 0.5,
                  color: fontColor ?? kWhite,
                  weight: FontWeight.w800,
                ),
              ],
            ),
          ),
        ),
      
       );
  }
}
