import 'package:flutter/material.dart';

double width(BuildContext context, double value) => ((MediaQuery.of(context).size.width)~/value).toDouble();
double height(BuildContext context, double value) => ((MediaQuery.of(context).size.height)~/value).toDouble();

Color blue = const Color.fromRGBO(25, 99, 209, 1);
Color white = const Color.fromRGBO(255, 255, 255, 1);
Color black = const Color.fromRGBO(0, 0, 0, 1);

Widget text(String value, double size, Color color) => Text(
  value,
  style: TextStyle(
    color: color,
    fontSize: size,
    fontFamily: 'Futura',
    fontWeight: FontWeight.w500
  ),
);

Widget divider = Divider(
  color: black,
  height: 10,
  thickness: 1,
);

Widget textField(String text, String hintText) => 
  Container(
    height: 40,
    child: TextField(
      onChanged: (value) => text = value,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontFamily: 'Futura',
          fontSize: 14
        ),
        border: OutlineInputBorder()
      ) 
    ),
  );
