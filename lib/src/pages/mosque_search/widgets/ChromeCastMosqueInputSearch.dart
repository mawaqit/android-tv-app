import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/main.dart';
import 'package:mawaqit/src/models/mosque.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/widgets/mosque_simple_tile.dart';
import 'package:provider/provider.dart';

import '../../../helpers/AppRouter.dart';
import '../../../helpers/SharedPref.dart';
import '../../../helpers/keyboard_custom.dart';
import '../../home/OfflineHomeScreen.dart';

class ChromeCastMosqueInputSearch extends StatefulWidget {
  const ChromeCastMosqueInputSearch({Key? key, this.onDone}) : super(key: key);
  final void Function()? onDone;

  @override
  State<ChromeCastMosqueInputSearch> createState() => _MosqueInputSearchState();
}

class _MosqueInputSearchState extends State<ChromeCastMosqueInputSearch> {
  final inputController = TextEditingController();
  final scrollController = ScrollController();
  SharedPref sharedPref = SharedPref();

  List<Mosque> results = [];
  bool loading = false;
  bool noMore = false;
  String? error;
  bool showKeyboard = true;
  bool inputHasFocus = false;

  void Function()? loadMore;
  onboardingWorkflowDone() {
    sharedPref.save('boarding', 'true');
    AppRouter.pushReplacement(OfflineHomeScreen());
  }

  FocusNode _focus = FocusNode();
  FocusNode _focusNodeList = FocusNode();
  final navKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChange);
    _focusNodeList.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    super.dispose();
    _focus.removeListener(_onFocusChange);
    _focusNodeList.removeListener(_onFocusChange);
    _focus.dispose();
    _focusNodeList.dispose();
  }

  void _onFocusChange() {
    print("show" + _focus.hasFocus.toString());
    setState(() {
      inputHasFocus = _focus.hasFocus ? true : false;
      showKeyboard = _focus.hasFocus || _focusNodeList.hasFocus ? false : true;
    });
  }

  void scrollToTheEndOfTheList() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: 200.milliseconds,
      curve: Curves.ease,
    );
  }

  void _searchMosque(String mosque, int page) async {
    if (loading) return;
    loadMore = () => _searchMosque(mosque, page + 1);

    if (mosque.isEmpty) {
      setState(() {
        error = S.of(context).mosqueNameError;
        loading = false;
      });
      return;
    }

    setState(() {
      error = null;
      loading = true;
      showKeyboard = false;

      if (page == 1) results = [];
    });
    final mosqueManager = Provider.of<MosqueManager>(context, listen: false);
    await mosqueManager
        .searchMosques(mosque, page: page)
        .then((value) => setState(() {
              loading = false;

              if (page == 1) results = [];

              results = [...results, ...value];
/*               showKeyboard = true;
 */ /*               inputHasFocus = false;
 */
              noMore = results.isEmpty;
            }))
        .catchError((e, stack) => setState(() {
              logger.w(e.toString(), stackTrace: stack);
              loading = false;
              error = S.of(context).backendError;
            }));
  }

  /// handle on mosque tile clicked
  Future<void> _selectMosque(Mosque mosque) {
    return context
        .read<MosqueManager>()
        .setMosqueUUid(mosque.uuid.toString())
        .then((value) {
      !context.read<MosqueManager>().typeIsMosque
          ? onboardingWorkflowDone()
          : widget.onDone?.call();
    }).catchError((e, stack) {
      if (e is InvalidMosqueId) {
        setState(() {
          loading = false;
          error = S.of(context).slugError;
        });
      } else {
        setState(() {
          loading = false;
          error = S.of(context).backendError;
        });
      }
    });
  }

  String applyNameMask(String value) {
    String maskedValue = value;
    return maskedValue;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      child: Align(
          alignment: Alignment(0, -.3),
          child: Column(
            children: [
              Text(
                S.of(context).searchMosque,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.w700,
                  color: theme.brightness == Brightness.dark
                      ? null
                      : theme.primaryColor,
                ),
              ).animate().slideY(begin: -1).fade(),
              SizedBox(height: 20),
              searchField(theme)
                  .animate()
                  .slideX(begin: 1, delay: 200.milliseconds)
                  .fadeIn(),
              SizedBox(height: 20),
              showKeyboard || inputHasFocus
                  ? KeyboardCustom(
                      keyboardType: KeyboardType.alphanumeric,
                      controller: inputController,
                      applyMask: applyNameMask,
                      onSubmit: (val) => _searchMosque(
                        inputController.text,
                        1,
                      ), // Pass the callback function
                    ).animate().slideY(begin: 1).fade()
                  : SizedBox(),
              Expanded(
                child: ListView(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  controller: scrollController,
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(vertical: 80, horizontal: 10),
                  cacheExtent: 99999,
                  children: [
                    results.isNotEmpty
                        ? Focus(
                            focusNode: _focusNodeList,
                            child: Column(
                              children: [
                                for (var i = 0; i < results.length; i++)
                                  MosqueSimpleTile(
                                    autoFocus: i == 0,
                                    mosque: results[i],
                                    onTap: () => _selectMosque(results[i]),
                                  )
                                      .animate()
                                      .slideX(delay: 70.milliseconds * (i % 5))
                                      .fade(),
                              ],
                            ),
                          )
                        : SizedBox(),
                    // to allow user to scroll to the end of lis
                    results.isNotEmpty
                        ? FocusableActionDetector(
                            onFocusChange: (i) {
                              if (!i) return;
                              if (noMore) return;

                              loadMore?.call();
                              scrollToTheEndOfTheList();
                            },
                            child: Center(
                              child: SizedBox(
                                height: 40,
                                child: Builder(
                                  builder: (context) {
                                    if (loading)
                                      return CircularProgressIndicator();

                                    if (noMore && results.isEmpty)
                                      return Text(
                                          S.of(context).mosqueNoResults);
                                    if (noMore)
                                      return Text(S.of(context).mosqueNoMore);

                                    return SizedBox();
                                  },
                                ),
                              ),
                            ),
                          )
                        : SizedBox(),
                  ],
                ),
              ),
            ],
          )),
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, RawKeyEvent event) {
    if (LogicalKeyboardKey.arrowLeft == event.logicalKey) {
      FocusManager.instance.primaryFocus!
          .focusInDirection(TraversalDirection.left);
    } else if (LogicalKeyboardKey.arrowRight == event.logicalKey) {
      FocusManager.instance.primaryFocus!
          .focusInDirection(TraversalDirection.right);
    } else if (LogicalKeyboardKey.arrowUp == event.logicalKey) {
      FocusManager.instance.primaryFocus!
          .focusInDirection(TraversalDirection.up);
    } else if (LogicalKeyboardKey.arrowDown == event.logicalKey) {
      FocusManager.instance.primaryFocus!
          .focusInDirection(TraversalDirection.down);
    } else if (LogicalKeyboardKey.goBack == event.logicalKey) {
      navKey.currentState!.pop();
    }
    return KeyEventResult.handled;
  }

  Widget searchField(ThemeData theme) {
    return Focus(
      canRequestFocus: false,
      onKey: _handleKeyEvent,
      child: TextFormField(
        controller: inputController,
        style: GoogleFonts.inter(
          color:
              theme.brightness == Brightness.dark ? null : theme.primaryColor,
        ),
        onFieldSubmitted: (val) => _searchMosque(val, 1),
        cursorColor:
            theme.brightness == Brightness.dark ? null : theme.primaryColor,
        keyboardType: TextInputType.none,
        autofocus: true,
        focusNode: _focus,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          filled: true,
          errorText: error,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
          hintText: S.of(context).searchForMosque,
          hintStyle: TextStyle(
            fontWeight: FontWeight.normal,
            color: theme.brightness == Brightness.dark
                ? null
                : theme.primaryColor.withOpacity(0.4),
          ),
          suffixIcon: ExcludeFocus(
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () => _searchMosque(inputController.text, 0),
              child: Icon(Icons.search_rounded),
            ),
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
    );
  }
}
