import 'package:flutter/material.dart';
import 'package:flyweb/generated/l10n.dart';
import 'package:flyweb/i18n/i18n.dart';
import 'package:flyweb/src/widgets/WhiteButton.dart';
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
                child: Text(S.current.ok),
                onPressed: onDone,
              ),
            ),
          ),
        ],
        text:
            'Mawaqit offers you a new way to track and manage prayer times, indeed we offer an end-to-end system that '
            'provides mosque managers with an online tool available 24/24h.',
      ),
    );
  }
}
