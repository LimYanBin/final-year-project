import 'package:flutter/material.dart';

class AppC {
  static const Color lBlue = Color.fromARGB(255, 65, 221, 187);
  static const Color dBlue = Color.fromARGB(255, 170, 211, 235);
  static const Color green1 = Color(0xFF6FA34F);
  static const Color green2 = Color(0xFF558564);
  static const Color red = Color(0xFFEB3223);
  static const Color black = Color(0xFF001011);
  static const Color bgdWhite = Color(0xFFFFFCF2);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lGrey = Color(0xFFD9D9D9);
  static const Color dGrey = Color(0xFF706F6F);
  static const Color lPurple = Color(0xFFF3E5F5);
  static const Color purple = Color(0xFFE1BEE7);
  static const Color dPurple = Color(0xFFAB47B3);
  static const Color lBlurGrey = Color(0xFFCFD8DC);
  static const Color blurGrey = Color(0xFF90A4AE);
  static const Color dBlurGrey = Color(0xFF607D8B);
  static const Color gold = Color.fromARGB(255, 238, 191, 62);
  static const Color warning = Color.fromARGB(255, 180, 68, 24);
}

class AppText {
  static const TextStyle title = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.w500,
    color: AppC.black,
    fontFamily: 'Roboto',
  );

  static const TextStyle title2 = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w500,
    color: AppC.black,
    fontFamily: 'Roboto',
  );

  static const TextStyle title3 = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w500,
    color: AppC.black,
    fontFamily: 'Roboto',
  );

  static const TextStyle text = TextStyle(
    fontFamily: 'Roboto',
    color: AppC.black,
    fontWeight: FontWeight.normal,
    fontSize: 18.0,
  );

  static const TextStyle text2 = TextStyle(
    fontFamily: 'Roboto',
    color: AppC.black,
    fontWeight: FontWeight.normal,
    fontSize: 12.0,
  );

  static const TextStyle text3 = TextStyle(
    fontFamily: 'Roboto',
    color: AppC.green1,
    fontWeight: FontWeight.normal,
    fontSize: 15.0,
  );

  static const TextStyle treatment = TextStyle(
    fontFamily: 'Roboto',
    color: AppC.black,
    fontWeight: FontWeight.normal,
    fontSize: 15.0,
  );

  static const TextStyle warning = TextStyle(
    fontFamily: 'Roboto',
    color: AppC.warning,
    fontWeight: FontWeight.normal,
    fontSize: 12.0,
  );

  static const TextStyle button = TextStyle(
    fontFamily: 'Roboto',
    color: AppC.bgdWhite,
    fontWeight: FontWeight.normal,
    fontSize: 18.0,
  );
  //out of stock
  static const TextStyle status1 = TextStyle(
    fontFamily: 'Roboto',
    color: AppC.red,
    fontWeight: FontWeight.normal,
    fontSize: 18.0,
  );
  //available
  static const TextStyle status2 = TextStyle(
    fontFamily: 'Roboto',
    color: AppC.green1,
    fontWeight: FontWeight.normal,
    fontSize: 18.0,
  );

  static const TextStyle message = TextStyle(
    fontFamily: 'Roboto',
    color: AppC.green1,
    fontWeight: FontWeight.normal,
    fontSize: 18.0,
  );
}

class AppButton {
  static final ButtonStyle buttonStyleCreate = OutlinedButton.styleFrom(
      backgroundColor: AppC.green1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      side: BorderSide(color: AppC.green1, width: 2),
      fixedSize: Size(180, 40));

  static final ButtonStyle buttonStyleAdd = OutlinedButton.styleFrom(
      backgroundColor: AppC.green1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      side: BorderSide(color: AppC.green1, width: 2),
      fixedSize: Size(200, 40));

  static final ButtonStyle buttonStyleUpdate = OutlinedButton.styleFrom(
      backgroundColor: AppC.green1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      side: BorderSide(color: AppC.green1, width: 2),
      fixedSize: Size(150, 40));

  static final ButtonStyle buttonStyleDelete = OutlinedButton.styleFrom(
      backgroundColor: AppC.red,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      side: BorderSide(color: AppC.red, width: 2),
      fixedSize: Size(150, 40));

  static final ButtonStyle buttonStyleBlack = OutlinedButton.styleFrom(
    backgroundColor: AppC.dGrey,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    side: BorderSide(color: AppC.dGrey, width: 2),
  );

  static final ButtonStyle buttonStyleAuth = OutlinedButton.styleFrom(
      backgroundColor: AppC.dGrey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      side: BorderSide(color: AppC.black, width: 2),
      fixedSize: Size(250, 40));

  static final ButtonStyle buttonStyleDisease = OutlinedButton.styleFrom(
      backgroundColor: AppC.lPurple,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      side: BorderSide(color: AppC.dPurple, width: 2),
      fixedSize: Size(250, 45));

  static final ButtonStyle buttonStyleFarm = OutlinedButton.styleFrom(
      backgroundColor: AppC.lBlurGrey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      side: BorderSide(color: AppC.dBlurGrey, width: 2),
      fixedSize: Size(250, 45));

  static final ButtonStyle buttonStyleHistory = OutlinedButton.styleFrom(
      backgroundColor: AppC.lBlurGrey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      side: BorderSide(color: AppC.dBlurGrey, width: 2),
      fixedSize: Size(250, 60));

  static final ButtonStyle ele =
      ElevatedButton.styleFrom(fixedSize: Size(250, 45));
}

class AppTextField {
  static const TextStyle textField = TextStyle(
    backgroundColor: AppC.white,
  );
}

class AppBoxDecoration {
  static final BoxDecoration box = BoxDecoration(
    color: AppC.white,
    borderRadius: BorderRadius.circular(8.0),
    border: Border.all(color: AppC.black),
  );

  static final BoxDecoration box2 = BoxDecoration(
    color: AppC.bgdWhite,
    borderRadius: BorderRadius.circular(8.0),
    border: Border.all(color: AppC.black),
  );

  static final BoxDecoration box3 = BoxDecoration(
    color: AppC.lGrey,
    borderRadius: BorderRadius.circular(8.0),
    border: Border.all(color: AppC.black),
  );

  static final BoxConstraints boxConstraints = BoxConstraints(
    minHeight: 50,
    minWidth: 300,
    maxHeight: 200,
    maxWidth: 300,
  );

  static final BoxConstraints boxConstraints2 = BoxConstraints(
    minHeight: 50,
    minWidth: 350,
    maxHeight: 200,
  );

  static final BoxConstraints boxConstraints3 = BoxConstraints(
    minHeight: 50,
    minWidth: 350,
  );

  static final BoxDecoration mapBox = BoxDecoration(
    border: Border.all(color: Colors.black, width: 2), // Border color and width
    borderRadius: BorderRadius.circular(10),
  );
}

class CustomRadioListTile<T> extends StatelessWidget {
  final T value;
  final T? groupValue;
  final ValueChanged<T?> onChanged;
  final Widget title;
  final bool showError;

  CustomRadioListTile({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.title,
    required this.showError,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: GestureDetector(
        onTap: () {
          onChanged(value);
        },
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            border: Border.all(
              color: value == groupValue
                  ? AppC.lBlue
                  : showError
                      ? AppC.warning
                      : AppC.dGrey,
              width: 2.0,
            ),
            color: value == groupValue ? AppC.lBlue : Colors.transparent,
          ),
          child: value == groupValue
              ? Icon(
                  Icons.check,
                  size: 20.0,
                  color: AppC.black,
                )
              : null,
        ),
      ),
      title: title,
      onTap: () {
        onChanged(value);
      },
    );
  }
}
