import 'package:flutter/material.dart';
import 'package:mawaqit/generated/l10n.dart';
import 'package:mawaqit/src/widgets/WhiteButton.dart';
import 'package:google_fonts/google_fonts.dart';

class OnBoardingTextWidget extends StatelessWidget {
  final void Function() onDone;

  const OnBoardingTextWidget({
    Key? key,
    required this.onDone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.justify,
      text: TextSpan(
        style: GoogleFonts.montserrat(
          color: Colors.white54,
          fontSize: 24,
          fontWeight: FontWeight.w300,
          height: 48 / 33,
        ),
        children: [
          WidgetSpan(
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: WhiteButton(
                text: S.of(context).ok,
                onPressed: onDone,
              ),
            ),
          ),
        ],
        text: S.of(context).mawaqitDesc,
      ),
    );
  }
}
