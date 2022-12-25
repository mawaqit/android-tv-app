import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mawaqit/generated/l10n.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';

class MosqueInputId extends StatefulWidget {
  const MosqueInputId({Key? key, this.onDone}) : super(key: key);

  final void Function()? onDone;

  @override
  State<MosqueInputId> createState() => _MosqueInputIdState();
}

class _MosqueInputIdState extends State<MosqueInputId> {
  final inputController = TextEditingController();

  bool loading = false;
  String? error;

  void _setMosqueId(String mosqueId) async {
    if (mosqueId.isEmpty) {
      return setState(() => error = S.of(context).missingMosqueId);
    }
    if (int.tryParse(mosqueId) == null) {
      return setState(() => S.of(context).mosqueIdIsNotValid(mosqueId));
    }

    setState(() {
      error = null;
      loading = true;
    });
    final mosqueManager = Provider.of<MosqueManager>(context, listen: false);
    await mosqueManager.setMosqueId(mosqueId).then((value) {
      setState(() => loading = false);

      widget.onDone?.call();
    }).catchError((e) {
      if (e is InvalidMosqueId) {
        setState(() {
          loading = false;
          error = S.of(context).mosqueIdIsNotValid(mosqueId);
        });
      } else {
        setState(() {
          loading = false;
          error = S.of(context).backendError;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      child: Align(
        alignment: Alignment(0, -.3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              S.of(context).selectMosqueId,
              style: TextStyle(
                fontSize: 25.0,
                fontWeight: FontWeight.w700,
                color: theme.brightness == Brightness.dark ? null : theme.primaryColor,
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextFormField(
                  controller: inputController,
                  style: GoogleFonts.inter(
                    color: theme.brightness == Brightness.dark ? null : theme.primaryColor,
                  ),
                  onFieldSubmitted: _setMosqueId,
                  cursorColor: theme.brightness == Brightness.dark ? null : theme.primaryColor,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                  ],
                  decoration: InputDecoration(
                    filled: true,
                    errorText: error,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                    hintText: S.of(context).selectWithMosqueId,
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: theme.brightness == Brightness.dark ? null : theme.primaryColor.withOpacity(0.4),
                    ),
                    suffixIcon: IconButton(
                      tooltip: "Search by Id",
                      icon: loading ? CircularProgressIndicator() : Icon(Icons.search),
                      color: theme.brightness == Brightness.dark ? Colors.white70 : theme.primaryColor,
                      onPressed: () => _setMosqueId(inputController.text),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(width: 0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(width: 0),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 2,
                      horizontal: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
