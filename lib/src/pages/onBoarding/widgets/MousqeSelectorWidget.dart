import 'package:flutter/material.dart';
import 'package:flyweb/i18n/AppLanguage.dart';
import 'package:flyweb/i18n/i18n.dart';
import 'package:flyweb/src/helpers/SharedPref.dart';
import 'package:flyweb/src/widgets/WhiteButton.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class OnBoardingMosqueSelector extends StatefulWidget {
  final void Function(String url) onDone;

  OnBoardingMosqueSelector({
    Key key,
    @required this.onDone,
  }) : super(key: key);

  @override
  State<OnBoardingMosqueSelector> createState() =>
      _OnBoardingMosqueSelectorState();
}

class _OnBoardingMosqueSelectorState extends State<OnBoardingMosqueSelector> {
  final sharedPref = SharedPref();
  final controller = TextEditingController();

  bool loading = false;
  String error;

  Future<void> _onDone(String mosqueId) async {
    setState(() => loading = true);

    sharedPref.save('boarding', 'true');
    sharedPref.save('mosqueId', mosqueId);

    var url =
        'https://mawaqit.net/${AppLanguage().appLocal.languageCode}/id/$mosqueId?view=desktop';

    var value = await http.get(Uri.parse(url));

    if (value.statusCode != 200) {
      setState(() {
        loading = false;

        error = 'invalid Mosque id';
      });
    } else {
      widget.onDone(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            I18n.current.descLang,
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w200,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    autofocus: true,
                    controller: controller,
                    onSubmitted: _onDone,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      isDense: true,
                      alignLabelWithHint: false,
                      errorText: error,
                      hintText: 'Mosque Id ',
                      prefixText: 'Enter Mosque Id : ',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 5,
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                loading
                    ? CircularProgressIndicator()
                    : WhiteButton(
                        onPressed: () => _onDone(controller.text),
                        child: Text(I18n.current.ok),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
