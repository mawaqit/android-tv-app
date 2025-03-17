import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/main.dart';
import 'package:mawaqit/src/models/mosque.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/state_management/on_boarding/v2/search_selection_type_provider.dart';
import 'package:mawaqit/src/widgets/mosque_simple_tile.dart';
import 'package:provider/provider.dart';
import 'package:fpdart/fpdart.dart' as fp;
import '../../../../i18n/AppLanguage.dart';
import '../../../helpers/AppRouter.dart';
import '../../../helpers/SharedPref.dart';
import '../../../helpers/keyboard_custom.dart';
import '../../../state_management/random_hadith/random_hadith_notifier.dart';
import '../../home/OfflineHomeScreen.dart';

class ChromeCastMosqueInputId extends ConsumerStatefulWidget {
  const ChromeCastMosqueInputId({
    Key? key,
    this.onDone,
    this.selectedNode = const None(),
  }) : super(key: key);

  final void Function()? onDone;
  final Option<FocusNode> selectedNode;

  @override
  ConsumerState<ChromeCastMosqueInputId> createState() => _MosqueInputIdState();
}

class _MosqueInputIdState extends ConsumerState<ChromeCastMosqueInputId> {
  final inputController = TextEditingController();
  Mosque? searchOutput;
  SharedPref sharedPref = SharedPref();
  bool showKeyboard = true;
  bool inputHasFocus = false;
  bool loading = false;
  String? error;
  FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    super.dispose();
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
  }

  void _onFocusChange() {
    setState(() {
      inputHasFocus = _focus.hasFocus ? false : true;
      showKeyboard = _focus.hasFocus ? false : true;
    });
  }

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
    final mosqueManager = context.read<MosqueManager>();

    await mosqueManager.searchMosqueWithId(mosqueId).then((value) {
      setState(() {
        showKeyboard = false;

        searchOutput = value;
        loading = false;
      });
    }).catchError((e, stack) {
      debugPrintStack(stackTrace: stack, label: e.toString());
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

  onboardingWorkflowDone() {
    sharedPref.save('boarding', 'true');
    AppRouter.pushReplacement(OfflineHomeScreen());
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
            buildInputWidget(context, theme),
            showKeyboard || inputHasFocus
                ? KeyboardCustom(
                    keyboardType: KeyboardType.numeric,
                    controller: inputController,
                    applyMask: applyNameMask,
                    onSubmit: _setMosqueId, // Pass the callback function
                  ).animate().slideY(begin: 1).fade()
                : SizedBox(),
            if (searchOutput != null)
              MosqueSimpleTile(
                focusNode: _focus,
                key: ValueKey(searchOutput!.uuid),
                autoFocus: true,
                mosque: searchOutput!,
                selectedNode: widget.selectedNode,
                onTap: () {
                  return context.read<MosqueManager>().setMosqueUUid(searchOutput!.uuid.toString()).then((value) async {
                    final mosqueManager = context.read<MosqueManager>();
                    final hadithLangCode = await context.read<AppLanguage>().getHadithLanguage(mosqueManager);
                    ref.read(randomHadithNotifierProvider.notifier).fetchAndCacheHadith(language: hadithLangCode);
                    !context.read<MosqueManager>().typeIsMosque ? onboardingWorkflowDone() : widget.onDone?.call();
                    if(searchOutput != null){
                      if (searchOutput?.type == "MOSQUE") {
                        ref.read(mosqueManagerProvider.notifier).state = fp.Option.fromNullable(SearchSelectionType.mosque);
                      } else {
                        ref.read(mosqueManagerProvider.notifier).state = fp.Option.fromNullable(SearchSelectionType.home);
                      }
                    }
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
                },
              ).animate().slideY(begin: 1).fade(),
          ],
        ),
      ),
    );
  }

  final navKey = GlobalKey<NavigatorState>();

  KeyEventResult _handleKeyEvent(FocusNode node, RawKeyEvent event) {
    if (LogicalKeyboardKey.arrowLeft == event.logicalKey) {
      FocusManager.instance.primaryFocus!.focusInDirection(TraversalDirection.left);
    } else if (LogicalKeyboardKey.arrowRight == event.logicalKey) {
      FocusManager.instance.primaryFocus!.focusInDirection(TraversalDirection.right);
    } else if (LogicalKeyboardKey.arrowUp == event.logicalKey) {
      FocusManager.instance.primaryFocus!.focusInDirection(TraversalDirection.up);
    } else if (LogicalKeyboardKey.arrowDown == event.logicalKey) {
      FocusManager.instance.primaryFocus!.focusInDirection(TraversalDirection.down);
    } else if (LogicalKeyboardKey.goBack == event.logicalKey) {
      navKey.currentState!.pop();
    }
    return KeyEventResult.handled;
  }

  Padding buildInputWidget(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Focus(
          canRequestFocus: false,
          onKey: _handleKeyEvent,
          child: TextFormField(
            controller: inputController,
            style: GoogleFonts.inter(
              color: theme.brightness == Brightness.dark ? null : theme.primaryColor,
            ),
            onFieldSubmitted: _setMosqueId,
            cursorColor: theme.brightness == Brightness.dark ? null : theme.primaryColor,
            keyboardType: TextInputType.none,
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
    );
  }
}
