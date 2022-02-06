import 'package:flutter/material.dart';
import 'package:flyweb/i18n/AppLanguage.dart';
import 'package:flyweb/i18n/i18n.dart';
import 'package:flyweb/src/pages/LanguageScreen.dart';
import 'package:flyweb/src/widgets/WhiteButton.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class OnBoardingLanguageSelector extends StatelessWidget {
  final void Function() onDone;

  const OnBoardingLanguageSelector({
    Key? key,
    required this.onDone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var appLanguage = Provider.of<AppLanguage>(context);

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            I18n.current!.descLang,
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w200,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Row(
              children: [
                Expanded(
                  child: Ink(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: InkWell(
                      focusColor: Colors.deepPurple.withOpacity(.5),
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LanguageScreen(),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 15,
                        ),
                        child: Text(
                          "${I18n.current!.appLang} (${appLanguage.currentLanguageName})",
                          style: TextStyle(color: Colors.black38),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                WhiteButton(
                  onPressed: onDone,
                  child: Text(I18n.current!.ok),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
