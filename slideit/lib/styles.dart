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

void showNewGameDialog(BuildContext context, void Function() action1, void Function() action2) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setDialogState) {
          return AlertDialog(
            title: Text("NEW GAME", textAlign: TextAlign.center),
            content: Text("Choose a type of game"),
            actions: [
              CustomTextButton(
                backgroundColor: Theme.of(context).primaryColor,
                textColor: Theme.of(context).scaffoldBackgroundColor,
                text: "RANDOM", 
                width: MediaQuery.of(context).size.width * 0.7, 
                action: action1,
              ),
              SizedBox(height: 8,),
              CustomTextButton(
                backgroundColor: Theme.of(context).primaryColor,
                textColor: Theme.of(context).scaffoldBackgroundColor,
                text: "GALLERY", 
                width: MediaQuery.of(context).size.width * 0.7, 
                action: action2,
              )
            ],
          );
        }
      );
    },
  );
}
