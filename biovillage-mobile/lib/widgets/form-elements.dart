import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:biovillage/theme/colors.dart';

class CustomTextFormField extends StatelessWidget {
  CustomTextFormField({
    this.controller,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.sentences,
    this.hintText,
    this.errorText,
    this.onFieldSubmitted,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.hintStyle,
    this.textStyle,
    this.minLines,
    this.maxLines = 1,
    this.enabled = true,
    this.onTap,
    this.textAlign = TextAlign.start,
    this.contentPadding,
    this.outlineInputBorder,
    this.fillColor,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final String hintText;
  final String errorText;
  final Function onFieldSubmitted;
  final Function(String) onChanged;
  final Icon prefixIcon;
  final Icon suffixIcon;
  final TextStyle hintStyle;
  final TextStyle textStyle;
  final int minLines;
  final int maxLines;
  final bool enabled;
  final Function onTap;
  final TextAlign textAlign;
  final EdgeInsets contentPadding;
  final OutlineInputBorder outlineInputBorder;
  final Color fillColor;

  @override
  Widget build(BuildContext context) {
    final OutlineInputBorder border = outlineInputBorder ??
        OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(5),
        );
    return TextFormField(
      controller: controller,
      enabled: enabled,
      textAlign: textAlign,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      onFieldSubmitted: (value) => onFieldSubmitted != null ? onFieldSubmitted() : null,
      onTap: onTap,
      onChanged: (value) => onChanged != null ? onChanged(value) : null,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        isDense: contentPadding != null,
        contentPadding: contentPadding ?? EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        hintText: hintText,
        hintStyle: hintStyle ??
            TextStyle(
              fontSize: 13.w,
              fontWeight: FontWeight.w400,
              color: ColorsTheme.textTertiary,
            ),
        filled: true,
        fillColor: fillColor ?? ColorsTheme.textFieldBg,
        enabledBorder: border,
        border: border,
        focusedBorder: border,
        disabledBorder: border,
        errorText: errorText,
        errorStyle: TextStyle(fontSize: 11.w, height: 1, color: ColorsTheme.error),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: ColorsTheme.error),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: ColorsTheme.error),
        ),
      ),
      style: textStyle ??
          TextStyle(
            fontSize: 13.w,
            color: enabled ? ColorsTheme.textMain : ColorsTheme.textFieldDisabledText,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
    );
  }
}

class CustomRadio extends StatelessWidget {
  CustomRadio({
    @required this.value,
    @required this.activeValue,
    this.onChange,
  });

  final value;
  final activeValue;
  final Function onChange;

  @override
  Widget build(BuildContext context) {
    bool isActive = value == activeValue;
    return Material(
      borderRadius: BorderRadius.circular(100),
      clipBehavior: Clip.antiAlias,
      color: Colors.transparent,
      child: InkWell(
        onTap: onChange != null ? () => onChange(value) : null,
        splashColor: ColorsTheme.primary.withOpacity(.4),
        highlightColor: ColorsTheme.primary.withOpacity(.2),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          alignment: Alignment.center,
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: isActive ? ColorsTheme.primary : ColorsTheme.radioNotActive, width: 2),
          ),
          child: AnimatedContainer(
            alignment: Alignment.center,
            duration: Duration(milliseconds: 300),
            width: isActive ? 10 : 0,
            height: isActive ? 10 : 0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: ColorsTheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}
