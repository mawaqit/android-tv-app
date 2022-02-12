import 'package:flutter/material.dart';
import 'package:flyweb/i18n/i18n.dart';
import 'package:flyweb/src/helpers/SharedPref.dart';
import 'package:flyweb/src/services/mosque_manager.dart';
import 'package:flyweb/src/widgets/WhiteButton.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class OnBoardingMosqueSelector extends StatefulWidget {
  final void Function() onDone;

  OnBoardingMosqueSelector({
    Key? key,
    required this.onDone,
  }) : super(key: key);

  @override
  State<OnBoardingMosqueSelector> createState() =>
      _OnBoardingMosqueSelectorState();
}

class _OnBoardingMosqueSelectorState extends State<OnBoardingMosqueSelector> {
  final sharedPref = SharedPref();
  final controller = TextEditingController();

  bool loading = false;
  String? error;

  Future<void> _onDone(String mosqueId) async {
    setState(() => loading = true);

    final mosqueManager = Provider.of<MosqueManager>(context, listen: false);

    mosqueManager.setMosqueId(mosqueId).then((value) {
      setState(() => loading = false);

      sharedPref.save('boarding', 'true');
      widget.onDone();
    }).catchError((e) {
      setState(() {
        loading = false;

        error = 'invalid Mosque id';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Select Mosque Id",
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
