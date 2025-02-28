import 'package:flutter/material.dart';

class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback action;
  final Color backgroundColor;
  final double width;
  final Color textColor;
  final bool enabled;

  const CustomTextButton({
    super.key,
    required this.text,
    required this.width,
    required this.action,
    this.backgroundColor = Colors.lightBlueAccent,
    this.textColor = Colors.white,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ElevatedButton(
        onPressed: enabled ? action : () => {},
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? backgroundColor : Colors.grey,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 5,
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 22, color: textColor),
        ),
      ),
    );
  }
}
