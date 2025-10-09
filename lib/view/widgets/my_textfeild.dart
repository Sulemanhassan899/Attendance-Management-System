import 'package:attendance_app/constants/app_colors.dart';
import 'package:attendance_app/view/widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';

class MyTextField extends StatefulWidget {
  String? label, hint;
  TextEditingController? controller;
  ValueChanged<String>? onChanged;
  bool? isObSecure, haveLabel, isReadOnly;
  double? marginBottom, radius;
  int? maxLines;
  double? labelSize, hintsize;
  FocusNode? focusNode;
  Color? filledColor, focusedFillColor, bordercolor, hintColor, labelColor;
  Widget? prefix, suffix;
  FontWeight? labelWeight, hintWeight;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final double? height;
  final double? Width;
  final FormFieldValidator<String>? validator;
  Color? backgroundColor;
  Color? borderColor;
  String? errorText;

  MyTextField({
    super.key,
    this.controller,
    this.hint,
    this.label,
    this.onChanged,
    this.isObSecure = false,
    this.marginBottom = 16.0,
    this.maxLines = 1,
    this.filledColor,
    this.focusedFillColor,
    this.hintColor,
    this.labelColor,
    this.haveLabel = true,
    this.labelSize,
    this.hintsize,
    this.prefix,
    this.suffix,
    this.labelWeight,
    this.hintWeight,
    this.keyboardType,
    this.isReadOnly,
    this.onTap,
    this.bordercolor,
    this.focusNode,
    this.radius,
    this.height = 48,
    this.Width,
    this.validator,
    this.backgroundColor, // Set the background color here
    this.borderColor, // Set the border color here
    this.errorText, // Set the error text here
  });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode?.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = widget.focusNode?.hasFocus ?? false;
    });
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_onFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: const [
        FadeEffect(duration: Duration(milliseconds: 500)),
        MoveEffect(
          curve: Curves.ease,
          duration: Duration(milliseconds: 500),
          transformHitTests: F,
        ),
      ],
      child: Padding(
        padding: EdgeInsets.only(bottom: widget.marginBottom ?? 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.label != null && _isFocused)
              TextWidget(
                text: widget.label ?? '',
                size: widget.labelSize ?? 10,
                paddingBottom: 8,
                color: kPrimaryColor,
                weight: widget.labelWeight ?? FontWeight.w500,
              ),
            Container(
              width: widget.Width ?? double.infinity,
              decoration: BoxDecoration(
                color: widget.backgroundColor,

                borderRadius: BorderRadius.circular(widget.radius ?? 12),
                //  color: filledColor ?? Colors.white,
              ),
              child: TextFormField(
                validator: widget.validator,
                focusNode: widget.focusNode,

                onTap: widget.onTap,
                textAlignVertical: TextAlignVertical.center,
                keyboardType: widget.keyboardType,
                cursorColor: kPrimaryColor,
                maxLines: widget.maxLines ?? 1,
                readOnly: widget.isReadOnly ?? false,
                controller: widget.controller,
                onChanged: widget.onChanged,
                textInputAction: TextInputAction.done,
                obscureText: widget.isObSecure ?? false,
                obscuringCharacter: '*',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  decoration: TextDecoration.none,
                  color: kBlack,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor:
                      _isFocused
                          ? widget.focusedFillColor ?? kTransperentColor
                          : widget.filledColor ?? kTransperentColor,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(widget.radius ?? 8),
                    borderSide: const BorderSide(color: kBorderColor, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(widget.radius ?? 8),
                    borderSide: const BorderSide(
                      color: kBorderColor, // Use widget.bordercolor
                      width: 1,
                    ),
                  ),
                  prefixIcon: widget.prefix,
                  prefixIconConstraints: const BoxConstraints.tightFor(),
                  suffixIconConstraints: const BoxConstraints.tightFor(),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: widget.suffix,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: (widget.maxLines ?? 1) > 1 ? 15 : 0,
                  ),
                  hintText: widget.hint,
                  hintStyle: TextStyle(
                    fontSize: widget.hintsize ?? 16,
                    letterSpacing: 0.5,
                    color: widget.hintColor ?? kSubText,
                    fontWeight: widget.hintWeight ?? FontWeight.w400,
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(widget.radius ?? 8),
                    borderSide: const BorderSide(width: 1, color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(widget.radius ?? 8),
                    borderSide: const BorderSide(width: 1, color: Colors.red),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}