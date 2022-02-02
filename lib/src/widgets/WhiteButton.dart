import 'package:flutter/material.dart';
import 'package:flyweb/src/helpers/AppConfig.dart';
import 'package:google_fonts/google_fonts.dart';

class WhiteButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;

  const WhiteButton({
    Key key,
    @required this.onPressed,
    @required this.child,
  }) : super(key: key);

  @override
  State<WhiteButton> createState() => _WhiteButtonState();
}

class _WhiteButtonState extends State<WhiteButton> {
  bool focused = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          focusColor: Colors.deepPurple.withOpacity(.5),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 30),
            child: Text(
              "OK",
              style: GoogleFonts.roboto(
                color: AppColors().mainColor(),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          onTap: widget.onPressed,
        ),
      ),
    );
  }
}
