import 'package:flutter/material.dart';
import 'package:guidemap/utils/x_colors.dart';

class XWidgets {
  const XWidgets._();

  static Widget iconTextBtn({
    required IconData iconData,
    required String text,
    required void Function()? onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: XColors.greyDark,
        foregroundColor: XColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
      ),
      icon: Icon(iconData, size: 20),
      label: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }

  static Widget textBtn({
    required String text,
    required void Function()? onPressed,
    TextStyle? textStyle,
    bool loading = false,
  }) {
    return ElevatedButton(
      onPressed: (onPressed != null)
          ? loading
              ? () {}
              : onPressed
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: XColors.greyDark,
        foregroundColor: XColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
      child: loading
          ? const SizedBox(
              width: 21,
              height: 21,
              child: CircularProgressIndicator(color: XColors.white),
            )
          : Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ).merge(textStyle),
            ),
    );
  }

  static Widget switchListTile({
    required bool value,
    required String text,
    required void Function(bool)? onChanged,
  }) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      applyCupertinoTheme: true,
      activeTrackColor: XColors.greyDark,
      activeColor: XColors.white,
      title: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: XColors.greyDark.withOpacity(value ? 1 : 0.5),
        ),
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}
