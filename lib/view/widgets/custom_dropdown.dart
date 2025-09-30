

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:attendance_app/constants/app_colors.dart';
import 'package:attendance_app/view/widgets/text_widget.dart';

class CustomDropDown extends StatelessWidget {
  const CustomDropDown({
    super.key,
    required this.hint,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    this.bgColor,
    this.marginBottom,
    this.width,
    this.labelText,
  });

  final List<String>? items; // Changed to List<String> to match the data type
  final String? selectedValue;
  final ValueChanged<String?>? onChanged; // Changed to String? to match controller methods
  final String hint;
  final String? labelText;
  final Color? bgColor;
  final double? marginBottom, width;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: marginBottom ?? 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (labelText != null)
            TextWidget(
              paddingBottom: 10,
              text: labelText!,
              size: 16,
              textAlign: TextAlign.start,
              weight: FontWeight.w600,
            ),
          DropdownButtonHideUnderline(
            child: DropdownButton2<String?>( // Added explicit generic type
              items: items!
                  .map(
                    (item) => DropdownMenuItem<String?>(
                      value: item,
                      child: TextWidget(
                        text: item,
                        size: 9,
                        color: kBlack,
                        weight: FontWeight.w600,
                      ),
                    ),
                  )
                  .toList(),
              value: (selectedValue != null &&
                      selectedValue!.isNotEmpty &&
                      selectedValue != hint)
                  ? selectedValue
                  : null,
              hint: TextWidget(
                text: hint,
                size: 12,
                color: kSubText,
                textAlign: TextAlign.start,
                weight: FontWeight.w500,
              ),
              onChanged: onChanged,
              iconStyleData: const IconStyleData(icon: SizedBox()),
              isDense: true,
              isExpanded: true,
              customButton: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                height: 48,
                decoration: BoxDecoration(
                  color: bgColor ?? kWhite,
                  border: Border.all(color: kBorderColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidget(
                      text: (selectedValue == null ||
                              selectedValue!.isEmpty ||
                              selectedValue == hint)
                          ? hint
                          : selectedValue!,
                      size: 9,
                      color: kBlack,
                      weight: FontWeight.w600,
                    ),
                    const Icon(Icons.arrow_drop_down, color: kBlack),
                  ],
                ),
              ),
              menuItemStyleData: const MenuItemStyleData(height: 35),
              dropdownStyleData: DropdownStyleData(
                elevation: 6,
                maxHeight: 300,
                offset: const Offset(0, -5),
                decoration: BoxDecoration(
                  border: Border.all(color: kBorderColor),
                  borderRadius: BorderRadius.circular(10),
                  color: kWhite,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}