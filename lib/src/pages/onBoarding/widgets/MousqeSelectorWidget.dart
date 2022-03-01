import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flyweb/generated/l10n.dart';
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
  State<OnBoardingMosqueSelector> createState() => _OnBoardingMosqueSelectorState();
}

class _OnBoardingMosqueSelectorState extends State<OnBoardingMosqueSelector> {
  final sharedPref = SharedPref();
  final controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool loading = false;
  String? error;

  Future<void> _onDone(String mosqueId) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      error = null;
      loading = true;
    });

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
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      controller: controller,
                      onFieldSubmitted: _onDone,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                      ],
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Missing mosque ID';

                        if (int.tryParse(v) == null) return '$v isn\'t a valid mosque id';

                        return null;
                      },
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
                ),
                const SizedBox(width: 10),
                loading
                    ? CircularProgressIndicator()
                    : WhiteButton(
                        onPressed: () => _onDone(controller.text),
                        child: Text(S.of(context).ok),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
