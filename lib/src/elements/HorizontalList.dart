import 'package:flutter/material.dart';
import 'package:mawaqit/src/helpers/HexColor.dart';
import 'package:mawaqit/src/models/settings.dart';
import 'package:mawaqit/src/themes/UIImages.dart';

class HorizontalList extends StatefulWidget {
  String title;
  String description;
  String selected;
  String selectedFirstColor;
  String selectedSecondColor;
  String type;
  IconData icon;
  List list;
  Function? onTap;
  Function? onTapColor;
  Function? onTapLoader;
  Settings? settings;

  HorizontalList({Key? key,
    this.title = "",
    this.description = "",
    this.selected = "",
    this.selectedFirstColor = "",
    this.selectedSecondColor = "",
    this.type = "",
    this.icon = Icons.edit,
    this.list = const [],
    this.onTap,
    this.onTapColor,
    this.onTapLoader,
    this.settings = null})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => new _HorizontalList();
}

class _HorizontalList extends State<HorizontalList> {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery
            .of(context)
            .size
            .width,
        alignment: Alignment.topLeft,
        margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
        padding: EdgeInsets.fromLTRB(0.0, 15.0, 0, 15.0),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.transparent)),
          color: Colors.transparent,
        ),
        child: Container(
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
              Flexible(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                    Container(
                      child: Text(
                        widget.title,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                      ),
                      margin: EdgeInsets.only(top: 0.0, bottom: 0.0, left: 12.0, right: 12.0),
                    ),
                    SizedBox(height: 10.0),
                    _buildHorizontalList(
                        widget.list,
                        widget.onTap,
                        widget.onTapColor,
                        widget.onTapLoader,
                        widget.selected,
                        widget.selectedFirstColor,
                        widget.selectedSecondColor,
                        widget.type,
                        widget.settings)
                  ]))
            ])));
  }

  Widget _buildHorizontalList(List list, Function? onTap, Function? onTapColor, Function? onTapLoader, String selected,
      String selectedFirstColor, String selectedSecondColor, String type, Settings? settings) {
    if (type == "option") {
      return SizedBox(
        height: 100.0,
        child: new ListView(
          scrollDirection: Axis.horizontal,
          children: list.map((obj) {
            return _buildItem(obj['image'], obj['value'], obj['url'], onTap, selected, settings!);
          }).toList(),
        ),
      );
    }
    if (type == "color") {
      return SizedBox(
        height: 150.0,
        child: new ListView(
          scrollDirection: Axis.horizontal,
          children: list.map((obj) {
            return _buildItemGradient(
                obj['title'],
                obj['image'],
                obj['firstColor'],
                obj['secondColor'],
                onTapColor,
                selectedFirstColor,
                selectedSecondColor,
                settings);
          }).toList(),
        ),
      );
    } else {
      return SizedBox(
        height: 120.0,
        child: new ListView(
          scrollDirection: Axis.horizontal,
          children: list.map((obj) {
            return _buildItemLoader(obj, onTapLoader, settings!);
          }).toList(),
        ),
      );
    }
  }

  Widget _buildItem(AssetImage image_, String? text, String? url, Function? onTap, String selected, Settings settings) {
    double edgeSize = 0.0;

    return Container(
        padding: EdgeInsets.all(edgeSize),
        margin: EdgeInsets.fromLTRB(Directionality.of(context) == TextDirection.rtl ? 0 : 15, 12,
            Directionality.of(context) == TextDirection.rtl ? 15 : 0, 12),
        child: SizedBox(
          width: 230,
          child: Container(
              margin: EdgeInsets.all(0.0),
              padding: EdgeInsets.all(0.0),
              alignment: Alignment.topCenter,
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(
                    width: 0.0,
                    color: Colors.transparent,
                  ),
                  boxShadow: [
                    new BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: new Offset(2.0, 2.0),
                        blurRadius: 8.0,
                        spreadRadius: 1.0)
                  ]),
              child: ElevatedButton(
                  onPressed: () {
                    onTap!(text, url);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    padding: EdgeInsets.all(0.0),
                  ),
                  child: Ink(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              HexColor(settings.firstColor).withOpacity(selected == text ? 1.0 : 0.4),
                              HexColor(settings.secondColor).withOpacity(selected == text ? 1.0 : 0.4)
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(12.0)),
                      child: new Column(
                        //constraints:BoxConstraints(maxWidth: 300.0, minHeight: 50.0),
                        //alignment: Alignment.center,
                          children: [
                            new Expanded(
                              child: new Container(
                                decoration: new BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.0),
                                  image: new DecorationImage(
                                    image: image_,
                                    //image: new NetworkImage('${image_}'),
                                    //image: new ExactAssetImage('assets/images/navigation_center.png') ,
                                    fit: BoxFit.fill,
                                    //colorFilter: new ColorFilter.mode(Colors.white.withOpacity( settings == text ? 1.0 : 0.1 ), BlendMode.dstATop),
                                  ),
                                ),
                                alignment: AlignmentDirectional.topCenter,
                                child: Row(
                                  /*
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      child: new Text(selected),
                                      //color: Colors.green,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      color: Colors.yellow.withOpacity(0.5),
                                      child: new Text(text),
                                    ),
                                  ),
                                ],
                                */
                                ),
                              ),
                            ),
                          ])))),
        ));
  }

  Widget _buildItemGradient(String title, AssetImage? image_, String? firstColor, String? secondColor,
      Function? onTapColor, String selectedFirstColor, String selectedSecondColor, Settings? settings) {
    double edgeSize = 0.0;

    return Container(
        padding: EdgeInsets.all(edgeSize),
        margin: EdgeInsets.fromLTRB(15, 12, 0, 12),
        child: SizedBox(
          width: 130,
          child: Container(
              margin: EdgeInsets.all(0.0),
              padding: EdgeInsets.all(0.0),
              alignment: Alignment.topCenter,
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(
                    width: 0.0,
                    color: Colors.transparent,
                  ),
                  boxShadow: [
                    new BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: new Offset(2.0, 2.0),
                        blurRadius: 8.0,
                        spreadRadius: 1.0)
                  ]),
              child: ElevatedButton(
                  onPressed: () {
                    onTapColor!(firstColor, secondColor);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    padding: EdgeInsets.all(0.0),
                  ),
                  child: Ink(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              HexColor(firstColor).withOpacity(
                                  (selectedFirstColor == firstColor && selectedSecondColor == secondColor) ? 1.0 : 0.4),
                              HexColor(secondColor).withOpacity(
                                  (selectedFirstColor == firstColor && selectedSecondColor == secondColor) ? 1.0 : 0.4)
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(12.0)),
                      child: new Column(children: [
                        new Expanded(
                          child: new Container(
                            decoration: null,
                            alignment: AlignmentDirectional.topCenter,
                            child: Column(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    alignment: FractionalOffset(0.5, 0.5),
                                    child: (selectedFirstColor == firstColor && selectedSecondColor == secondColor)
                                        ? UIImages.checked
                                        : null,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    //color: Colors.yellow.withOpacity(0.5),
                                    child: Text(
                                      title,
                                      //overflow: TextOverflow.ellipsis,
                                      //softWrap: true,
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color:
                                          (selectedFirstColor == firstColor && selectedSecondColor == secondColor)
                                              ? Colors.white
                                              : Colors.grey[300]),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ])))),
        ));
  }

  Widget _buildItemLoader(dynamic obj, Function? onTapLoader, Settings settings) {
    double edgeSize = 0.0;

    return Container(
        padding: EdgeInsets.all(edgeSize),
        margin: EdgeInsets.fromLTRB(15, 12, 0, 12),
        child: SizedBox(
          width: 100,
          child: Container(
              margin: EdgeInsets.all(0.0),
              padding: EdgeInsets.all(0.0),
              alignment: Alignment.topCenter,
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(
                    width: 0.0,
                    color: Colors.transparent,
                  ),
                  boxShadow: [
                    new BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: new Offset(2.0, 2.0),
                        blurRadius: 8.0,
                        spreadRadius: 1.0)
                  ]),
              child: ElevatedButton(
                  onPressed: () {
                    onTapLoader!(obj["value"]);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    padding: EdgeInsets.all(0.0),
                  ),
                  child: Ink(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              HexColor(settings.firstColor).withOpacity(settings.loader == obj["value"] ? 1.0 : 0.4),
                              HexColor(settings.secondColor).withOpacity(settings.loader == obj["value"] ? 1.0 : 0.4)
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(12.0)),
                      child: new Column(children: [
                        new Expanded(
                          child: new Container(
                            decoration: null,
                            alignment: AlignmentDirectional.topCenter,
                            child: Column(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Container(alignment: FractionalOffset(0.5, 0.5), child: obj["loading"]),
                                ),
                                /*
                              Expanded(
                                flex: 1,
                                child: Container(
                                  //color: Colors.yellow.withOpacity(0.5),
                                  child: Text(
                                    "title",
                                    //overflow: TextOverflow.ellipsis,
                                    //softWrap: true,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color:
                                        (  settings.loader == "RotatingCircle")
                                            ? Colors.white
                                            : Colors.grey[300]),
                                  ),
                                ),
                              ),
                               */
                              ],
                            ),
                          ),
                        ),
                      ])))),
        ));
  }
}
