import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mawaqit/generated/l10n.dart';
import 'package:mawaqit/src/helpers/SharedPref.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
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

  bool loading = false;
  String? error;

  void _setMosqueId(String mosqueId) async {
    if (mosqueId.isEmpty) {
      return setState(() => error = S.of(context).missingMosqueId);
    }
    if (int.tryParse(mosqueId) == null) {
      return setState(() => S.of(context).mosqueIdIsNotValid(mosqueId));
    }

    setState(() => loading = true);
    final mosqueManager = Provider.of<MosqueManager>(context, listen: false);
    await mosqueManager.setMosqueId(mosqueId).then((value) {
      setState(() => loading = false);

      sharedPref.save('boarding', 'true');
      widget.onDone();
    }).catchError((e) {
      setState(() {
        loading = false;
        error = S.of(context).mosqueIdIsNotValid(mosqueId);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            child: TextFormField(
              style: GoogleFonts.inter(
                color: Theme.of(context).primaryColor,
              ),
              onFieldSubmitted: _setMosqueId,
              cursorColor: Theme.of(context).primaryColor,
              keyboardType: TextInputType.number,
              autofocus: true,
              textInputAction: TextInputAction.search,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp("[0-9]")),
              ],
              decoration: InputDecoration(
                fillColor: Theme.of(context).cardColor,
                filled: true,
                errorText: error,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                hintText: S.of(context).selectMosqueId,
                hintStyle: TextStyle(
                  fontWeight: FontWeight.normal,
                  color: Theme.of(context).primaryColor.withOpacity(0.4),
                ),
                suffixIcon: IconButton(
                  tooltip: "Search by GPS",
                  icon: loading ? CircularProgressIndicator() : Icon(Icons.search),
                  color: Theme.of(context).primaryColor,
                  onPressed: () {},
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
                  horizontal: 10,
                ),
              ),
            ),
          ),
        ),
        // Container(
        //   height: 50.0.h,
        //   child: ListView.builder(
        //     addAutomaticKeepAlives: true,
        //     cacheExtent: 2000,
        //     padding: EdgeInsets.only(
        //       top: 1.0,
        //       bottom: 30.0,
        //     ),
        //     controller: _scrollController,
        //     itemCount: searchedMosqueList.length + 1,
        //     itemBuilder: (context, index) {
        //       FavoriteMosques favoriteMosques = Provider.of<FavoriteMosques>(context);
        //
        //       if (index < searchedMosqueList.length) {
        //         final searchMosque = searchedMosqueList[index];
        //         final detailMosque = fetchedMosqueList[index];
        //         return MosqueSearchWidget(
        //           searchedMosque: searchMosque,
        //           fetchedMosque: detailMosque,
        //           gps: searchByGPS,
        //           position: position,
        //           favoriteMosques: favoriteMosques,
        //         );
        //       }
        //       double cWidth = MediaQuery
        //           .of(context)
        //           .size
        //           .width * 0.85;
        //
        //       if (this.gpsError && this.searchByGPS) {
        //         return Padding(
        //           padding: const EdgeInsets.all(8.0),
        //           child: Row(
        //             children: [
        //               Spacer(),
        //               Container(
        //                 width: cWidth,
        //                 child: AutoSizeText(
        //                   this.gpsErrorText,
        //                   style: TextStyle(
        //                     fontWeight: FontWeight.w500,
        //                     color: Theme
        //                         .of(context)
        //                         .primaryColor,
        //                   ),
        //                 ),
        //               ),
        //               Spacer(),
        //             ],
        //           ),
        //         );
        //       }
        //
        //       if (this.loading)
        //         return Row(
        //           children: [
        //             Spacer(),
        //             Column(
        //               children: [
        //                 CircularProgressIndicator(
        //                   backgroundColor: Colors.white,
        //                 ),
        //                 Container(
        //                   width: cWidth,
        //                   margin: EdgeInsets.only(top: 20),
        //                   child: Visibility(
        //                     visible: showLoadingMsg,
        //                     child: Text(
        //                       AppLocalizations
        //                           .of(context)
        //                           .search_iOs14_message,
        //                       style: TextStyle(color: Theme
        //                           .of(context)
        //                           .hintColor),
        //                     ),
        //                   ),
        //                 )
        //               ],
        //             ),
        //             Spacer(),
        //           ],
        //         );
        //
        //       if (this.error)
        //         return Row(
        //           children: [
        //             Spacer(),
        //             Text("Oops an error has occurred"),
        //             Spacer(),
        //           ],
        //         );
        //
        //       if (searchedMosqueList.length == 0 && this.firstLoad)
        //         return Container(
        //           child: Padding(
        //             padding: const EdgeInsets.symmetric(
        //               horizontal: 15.0,
        //               vertical: 8.0,
        //             ),
        //             child: AutoSizeText(
        //               AppLocalizations
        //                   .of(context)
        //                   .search_HelpText,
        //               style: TextStyle(
        //                 fontWeight: FontWeight.w500,
        //                 color: Theme
        //                     .of(context)
        //                     .primaryColor,
        //               ),
        //             ),
        //           ),
        //         );
        //
        //       if (searchedMosqueList.length == 0 && this.searchPage == 1)
        //         return Container(
        //           child: Padding(
        //             padding: const EdgeInsets.symmetric(
        //               horizontal: 15.0,
        //               vertical: 8.0,
        //             ),
        //             child: AutoSizeText(
        //               AppLocalizations
        //                   .of(context)
        //                   .search_no_result,
        //               style: TextStyle(
        //                 fontWeight: FontWeight.w500,
        //                 color: Theme
        //                     .of(context)
        //                     .primaryColor,
        //               ),
        //               textAlign: TextAlign.justify,
        //             ),
        //           ),
        //         );
        //
        //       return Text("");
        //     },
        //   ),
        // ),
      ],
    );
  }
}
