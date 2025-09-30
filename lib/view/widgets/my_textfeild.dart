import 'package:attendance_app/constants/app_colors.dart';
import 'package:attendance_app/view/widgets/text_widget.dart';
import 'package:flutter/material.dart';

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
    return Padding(
      padding: EdgeInsets.only(bottom: widget.marginBottom ?? 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: widget.height ?? 50,
                width: widget.Width ?? double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.radius ?? 8),
                  color: widget.focusedFillColor,
                ),
                child: TextFormField(
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
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    // fontFamily: AppFonts.Poppins,
                    decoration: TextDecoration.none,
                    color: kBlack,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: widget.focusedFillColor ?? kTransperentColor,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(widget.radius ?? 8),
                      borderSide: BorderSide(color: kPrimaryColor, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(widget.radius ?? 8),
                      borderSide: BorderSide(
                        color:
                            _isFocused
                                ? widget.focusedFillColor ?? kPrimaryColor
                                : widget.bordercolor ?? kBorderColor,
                        width: 1,
                      ),
                    ),
                    prefixIcon: widget.prefix,
                    prefixIconConstraints: BoxConstraints.tightFor(),
                    suffixIconConstraints: BoxConstraints.tightFor(),
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
                      fontSize: widget.hintsize ?? 14,
                      // fontFamily: AppFonts.Poppins,
                      color: widget.hintColor ?? kSubText,
                      fontWeight: widget.hintWeight ?? FontWeight.w600,
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(widget.radius ?? 8),
                      borderSide: BorderSide(width: 1, color: Colors.red),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(widget.radius ?? 8),
                      borderSide: BorderSide(width: 1, color: Colors.red),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 1,
                left: 10,
                child: Container(
                  padding: EdgeInsets.only(
                    top: 0,
                    bottom: 0,
                    left: 5,
                    right: 5,
                  ),
                  color: kWhite,
                  child: Column(
                    children: [
                      if (widget.label != null && _isFocused)
                        TextWidget(
                          text: widget.label ?? '',
                          size: widget.labelSize ?? 12,
                          paddingBottom: 8,
                          color: kPrimaryColor,
                          // fontFamily: AppFonts.Poppins,
                          weight: widget.labelWeight ?? FontWeight.w700,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
