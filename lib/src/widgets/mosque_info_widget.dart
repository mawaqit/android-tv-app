import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mawaqit/generated/l10n.dart';
import 'package:mawaqit/src/helpers/mawaqit_icons_icons.dart';
import 'package:mawaqit/src/models/mosque.dart';
import 'package:mawaqit/src/widgets/mawaqit_circle_button_widget.dart';

class MosqaueInfoWidget extends StatefulWidget {
  const MosqaueInfoWidget({Key? key, required this.mosque}) : super(key: key);

  final Mosque mosque;

  @override
  State<MosqaueInfoWidget> createState() => _MosqaueInfoWidgetState();
}

class _MosqaueInfoWidgetState extends State<MosqaueInfoWidget> {
  Widget _buildTime(BuildContext context, String name, int index) => Padding(
        padding: const EdgeInsets.only(top: 3.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Text(
                name,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Row(
              children: [
                Text(
                  widget.mosque.times![index],
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(vertical: 1.0),
            //   child: Text(
            //     getIqama(mosque, index, this.times[index]),
            //     style: GoogleFonts.inter(
            //       color: theme.primaryColor,
            //       fontWeight: FontWeight.w400,
            //     ),
            //   ),
            // ),
            // index == this.nextPrayer
            //     ? Container(
            //         color: theme.primaryColor,
            //         width: MediaQuery.of(context).size.width * 0.15,
            //         height: 2,
            //       )
            //     : Container(
            //         height: 1,
            //       )
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    final isLight = theme.brightness == Brightness.light;

    theme = theme.copyWith(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      focusColor: theme.focusColor.withOpacity(.1),
      textTheme: theme.textTheme.apply(
        bodyColor: !isLight ? Colors.white70 : theme.primaryColor,
      ),
      iconTheme: IconThemeData(
        color: isLight ? Color.fromRGBO(78, 43, 129, 0.4) : Colors.white.withOpacity(.3),
        size: MediaQuery.of(context).size.height / 11,
      ),
      primaryIconTheme: IconThemeData(
        color: isLight ? Color.fromRGBO(78, 43, 129, 1) : Colors.white,
        size: MediaQuery.of(context).size.height / 11,
      ),
    );

    return Theme(
      data: theme,
      child: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            buildTitleBar(theme),
            SizedBox(height: 3),
            Expanded(
              child: ListView(
                clipBehavior: Clip.antiAlias,
                children: [
                  Material(
                    borderRadius: BorderRadius.circular(20),
                    color: theme.cardColor,
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () {},
                          child: buildImageSection(),
                        ),
                        InkWell(
                          onTap: () {},
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  widget.mosque.localisation ?? '',
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(),
                                ),
                              ),
                              SizedBox(),
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(
                              //     horizontal: 0,
                              //   ),
                              //   child: IconButton(
                              //     color: theme.primaryColor,
                              //     icon: Icon(
                              //       MawaqitIcons.icon_copy,
                              //     ),
                              //     splashColor: Colors.white,
                              //     onPressed: () {
                              //       // Clipboard.setData(
                              //       //   new ClipboardData(text: mosque.localisation),
                              //       // );
                              //     },
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                        Divider(thickness: 1),
                        if (widget.mosque.times != null)
                          InkWell(
                            onTap: () {},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      S.of(context).shuruq,
                                      style: GoogleFonts.inter(fontSize: 16),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          widget.mosque.times![1],
                                          style: GoogleFonts.inter(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      S.of(context).jumua,
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      widget.mosque.jumua ?? S.of(context).noJumua,
                                      style: GoogleFonts.inter(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        SizedBox(height: 8),
                        InkWell(
                          onTap: () {},
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildTime(context, S.of(context).fajr, 0),
                              _buildTime(context, S.of(context).duhr, 2),
                              _buildTime(context, S.of(context).asr, 3),
                              _buildTime(context, S.of(context).maghrib, 4),
                              _buildTime(context, S.of(context).isha, 5),
                            ],
                          ),
                        ),
                        Divider(thickness: 1),
                        InkWell(
                          onTap: () {},
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 10,
                            runSpacing: 10,
                            children: _buildFacilities(theme),
                          ),
                        ),
                        SizedBox(height: 20),
                        // mosque.paymentWebsite != null
                        //     ? Column(
                        //         children: [
                        //           Padding(
                        //             padding: const EdgeInsets.symmetric(
                        //               horizontal: 10.0,
                        //             ),
                        //             child: Divider(
                        //               thickness: 1,
                        //               color: theme.dividerColor,
                        //             ),
                        //           ),
                        //           Padding(
                        //             padding: const EdgeInsets.symmetric(
                        //               vertical: 8.0,
                        //             ),
                        //             child: MosqueDonateButton(
                        //               icon: MawaqitIcons.icon_donation,
                        //               size: 21,
                        //               onPressed: () {
                        //                 launch(mosque.paymentWebsite);
                        //               },
                        //             ),
                        //           ),
                        //         ],
                        //       )
                        //     : SizedBox(
                        //         height: 15,
                        //       ),
                      ],
                    ),
                  ),
                  Focus(
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        S.of(context).mosqueAnnouncement,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(color: theme.textTheme.bodyMedium?.color),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  AspectRatio buildImageSection() {
    return AspectRatio(
      aspectRatio: 2,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            widget.mosque.image ?? '',
            fit: BoxFit.cover,
          )
          //todo build actions
          // Column(
          //   children: _buildActions(context),
          // ),
        ],
      ),
    );
  }

  buildTitleBar(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // MawaqitCircleButton(
        //   icon: favoriteMosques.favoriteMosquesUuids.indexOf(mosque.uuid) > -1
        //       ? MawaqitIcons.icon_mosque_remove
        //       : MawaqitIcons.icon_mosque_add,
        //   size: 21,
        //   onPressed: _buildFunction(),
        //   color: _buildColor(),
        // ),
        Expanded(
          child: Text(
            widget.mosque.label ?? widget.mosque.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.headlineSmall,
            // style: theme.textTheme,
          ),
        ),
        MawaqitCircleButton(
          icon: MawaqitIcons.icon_close,
          size: 21,
          color: Colors.red,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  List<Widget> _buildFacilities(ThemeData theme) {
    List<Widget> items = [];

    if (widget.mosque.parking != null) {
      items.add(Column(
        children: [
          widget.mosque.parking!
              ? Icon(
                  MawaqitIcons.icon_facilities_parking,
                  color: theme.primaryIconTheme.color,
                )
              : Icon(
                  MawaqitIcons.icon_facilities_parking_disabled,
                  color: theme.iconTheme.color,
                ),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.height * 0.15,
              minWidth: MediaQuery.of(context).size.height * 0.15,
            ),
            child: Text(
              S.of(context).mosque_Facilities_Parking,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: GoogleFonts.inter(
                color: widget.mosque.parking!
                    ? theme.primaryIconTheme.color
                    : theme.iconTheme.color,
              ),
            ),
          ),
        ],
      ));
    }

    if (widget.mosque.handicapAccessibility != null) {
      items.add(
        Column(
          children: [
            widget.mosque.handicapAccessibility!
                ? Icon(
                    MawaqitIcons.icon_facilities_wheelchair,
                    color: theme.primaryIconTheme.color,
                  )
                : Icon(
                    MawaqitIcons.icon_facilities_wheelchair_disabled,
                    color: theme.iconTheme.color,
                  ),
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.height * 0.15,
                minWidth: MediaQuery.of(context).size.height * 0.15,
              ),
              child: Text(
                S.of(context).mosque_Facilities_DisabledAccess,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: GoogleFonts.inter(
                  color: widget.mosque.handicapAccessibility!
                      ? theme.primaryIconTheme.color
                      : theme.iconTheme.color,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (widget.mosque.ablutions != null) {
      items.add(Column(children: [
        widget.mosque.ablutions!
            ? Icon(
                MawaqitIcons.icon_facilities_ablutions,
                color: theme.primaryIconTheme.color,
              )
            : Icon(
                MawaqitIcons.icon_facilities_ablutions_disabled,
                color: theme.iconTheme.color,
              ),
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.height * 0.15,
            minWidth: MediaQuery.of(context).size.height * 0.15,
          ),
          child: Text(
            S.of(context).mosque_Facilities_AblutionsRoom,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: GoogleFonts.inter(
              color: widget.mosque.ablutions!
                  ? theme.primaryIconTheme.color
                  : theme.iconTheme.color,
            ),
          ),
        ),
      ]));
    }

    if (widget.mosque.womenSpace != null) {
      items.add(Column(children: [
        widget.mosque.womenSpace!
            ? Icon(
                MawaqitIcons.icon_facilities_woman,
                color: theme.primaryIconTheme.color,
              )
            : Icon(
                MawaqitIcons.icon_facilities_woman_disabled,
                color: theme.iconTheme.color,
              ),
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.height * 0.15,
            minWidth: MediaQuery.of(context).size.height * 0.15,
          ),
          child: Text(
            S.of(context).mosque_Facilities_WomanSpace,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: GoogleFonts.inter(
              color: widget.mosque.womenSpace!
                  ? theme.primaryIconTheme.color
                  : theme.iconTheme.color,
            ),
          ),
        ),
      ]));
    }

    if (widget.mosque.adultCourses != null) {
      items.add(Column(children: [
        widget.mosque.adultCourses!
            ? Icon(
                MawaqitIcons.icon_facilities_adults,
                color: theme.primaryIconTheme.color,
              )
            : Icon(
                MawaqitIcons.icon_facilities_adults_disabled,
                color: theme.iconTheme.color,
              ),
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.height * 0.15,
            minWidth: MediaQuery.of(context).size.height * 0.15,
          ),
          child: Text(
            S.of(context).mosque_Facilities_AdultsCourse,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: GoogleFonts.inter(
              color: widget.mosque.adultCourses!
                  ? theme.primaryIconTheme.color
                  : theme.iconTheme.color,
            ),
          ),
        ),
      ]));
    }

    if (widget.mosque.childrenCourses != null) {
      items.add(Column(children: [
        widget.mosque.childrenCourses!
            ? Icon(
                MawaqitIcons.icon_facilities_children,
                color: theme.primaryIconTheme.color,
              )
            : Icon(
                MawaqitIcons.icon_facilities_children_disabled,
                color: theme.iconTheme.color,
              ),
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.height * 0.15,
            minWidth: MediaQuery.of(context).size.height * 0.15,
          ),
          child: Text(
            S.of(context).mosque_Facilities_ChildrenCourses,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: GoogleFonts.inter(
              color: widget.mosque.childrenCourses!
                  ? theme.primaryIconTheme.color
                  : theme.iconTheme.color,
            ),
          ),
        ),
      ]));
    }

    if (widget.mosque.aidPrayer != null) {
      items.add(Column(children: [
        widget.mosque.aidPrayer!
            ? Icon(
                MawaqitIcons.icon_facilities_aidsalat,
                color: theme.primaryIconTheme.color,
              )
            : Icon(
                MawaqitIcons.icon_facilities_aidsalat_disabled,
                color: theme.iconTheme.color,
              ),
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.height * 0.15,
            minWidth: MediaQuery.of(context).size.height * 0.15,
          ),
          child: Text(
            S.of(context).mosque_Facilities_SalatAlAid,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: GoogleFonts.inter(
              color: widget.mosque.aidPrayer!
                  ? theme.primaryIconTheme.color
                  : theme.iconTheme.color,
            ),
          ),
        ),
      ]));
    }

    if (widget.mosque.janazaPrayer != null) {
      items.add(Column(children: [
        widget.mosque.janazaPrayer!
            ? Icon(
                MawaqitIcons.icon_facilities_janazah,
                color: theme.primaryIconTheme.color,
              )
            : Icon(
                MawaqitIcons.icon_facilities_janazah_diabled,
                color: theme.iconTheme.color,
              ),
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.height * 0.15,
            minWidth: MediaQuery.of(context).size.height * 0.15,
          ),
          child: Text(
            S.of(context).mosque_Facilities_SalatAlJanaza,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: GoogleFonts.inter(
              color: widget.mosque.janazaPrayer!
                  ? theme.primaryIconTheme.color
                  : theme.iconTheme.color,
            ),
          ),
        ),
      ]));
    }

    if (widget.mosque.ramadanMeal != null) {
      items.add(Column(children: [
        widget.mosque.ramadanMeal!
            ? Icon(
                MawaqitIcons.icon_facilities_iftar,
                color: theme.primaryIconTheme.color,
              )
            : Icon(
                MawaqitIcons.icon_facilities_iftar_disabled,
                color: theme.iconTheme.color,
              ),
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.height * 0.15,
            minWidth: MediaQuery.of(context).size.height * 0.15,
          ),
          child: Text(
            S.of(context).mosques_Facilities_IftarRamadan,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: GoogleFonts.inter(
              color: widget.mosque.ramadanMeal!
                  ? theme.primaryIconTheme.color
                  : theme.iconTheme.color,
            ),
          ),
        ),
      ]));
    }
    return items;
  }
}
