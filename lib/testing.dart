import 'package:flutter/material.dart';


class ErrorMessage{
  showMyDialog() async {
    return showDialog<void>(
      builder: (BuildContext context) {
        return AlertDialog(
          title: Container(
            child: Center(
              child: Text("Your content"),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                print("OK");
              },
            ),
          ],
        );
      },
    );
  }
}
// Future<void>