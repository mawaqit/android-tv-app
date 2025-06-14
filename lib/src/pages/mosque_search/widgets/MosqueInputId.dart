import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/models/mosque.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/widgets/mosque_simple_tile.dart';
import 'package:provider/provider.dart';

import '../../../../i18n/AppLanguage.dart';
import '../../../helpers/AppRouter.dart';
import '../../../helpers/SharedPref.dart';
import '../../../state_management/random_hadith/random_hadith_notifier.dart';
import '../../home/OfflineHomeScreen.dart';

class MosqueInputId extends ConsumerStatefulWidget {
  const MosqueInputId({Key? key, this.onDone}) : super(key: key);

  final void Function()? onDone;

  @override
  ConsumerState<MosqueInputId> createState() => _MosqueInputIdState();
}

class _MosqueInputIdState extends ConsumerState<MosqueInputId> {
  final inputController = TextEditingController();
  Mosque? searchOutput;
  SharedPref sharedPref = SharedPref();

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
    final mosqueManager = context.read<MosqueManager>();

    await mosqueManager.searchMosqueWithId(mosqueId).then((value) {
      setState(() {
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
            if (searchOutput != null)
              MosqueSimpleTile(
                key: ValueKey(searchOutput!.uuid),
                autoFocus: true,
                mosque: searchOutput!,
                onTap: () {
                  return context.read<MosqueManager>().setMosqueUUid(searchOutput!.uuid.toString()).then((value) async {
                    final mosqueManager = context.read<MosqueManager>();
                    final hadithLangCode = await context.read<AppLanguage>().getHadithLanguage(mosqueManager);
                    ref.read(randomHadithNotifierProvider.notifier).fetchAndCacheHadith(language: hadithLangCode);

                    !context.read<MosqueManager>().typeIsMosque ? onboardingWorkflowDone() : widget.onDone?.call();
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

  Padding buildInputWidget(BuildContext context, ThemeData theme) {
    final bool dark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Material(
        elevation: 4,
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(40),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          decoration: BoxDecoration(
            color: dark ? const Color(0xFF262626) : const Color(0xFFF1F1F3),
            borderRadius: BorderRadius.circular(40),
          ),
          child: TextFormField(
            controller: inputController,
            autofocus: true,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.search,
            cursorColor: Colors.white70,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.white,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            onFieldSubmitted: _setMosqueId,
            decoration: InputDecoration(
              // ------- visual bits -------
              hintText: S.of(context).selectWithMosqueId,
              hintStyle: GoogleFonts.inter(
                color: Colors.white.withOpacity(.55),
                fontWeight: FontWeight.w400,
              ),
              filled: true,
              fillColor: Colors.transparent, // we use the BoxDecoration color
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              // ------- icon on the right -------
              suffixIcon: IconButton(
                tooltip: 'Search by ID',
                iconSize: 24,
                splashRadius: 24,
                icon: loading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.search_rounded),
                color: Colors.white70,
                onPressed: () => _setMosqueId(inputController.text),
              ),
              // ------- invisible borders -------
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40),
                borderSide: BorderSide.none,
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40),
                borderSide: BorderSide(color: theme.colorScheme.error),
              ),
              errorStyle: const TextStyle(height: 0), // hide text gap
              errorText: error,
            ),
          ),
        ),
      ),
    );
  }
}
