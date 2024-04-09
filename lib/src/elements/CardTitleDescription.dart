import 'package:flutter/material.dart';

class CardTitleDescription extends StatefulWidget {
  String title;
  double fontSize;
  String description;
  TextAlign textAlign;

  CardTitleDescription(
      {Key? key, this.title = "", this.description = "", this.fontSize = 14, this.textAlign = TextAlign.left})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => new _CardTitleDescription();
}

class _CardTitleDescription extends State<CardTitleDescription> {
  @override
  Widget build(BuildContext context) {
    String description = widget.description != null ? widget.description : "";
    return Container(
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.topLeft,
      margin: const EdgeInsets.only(top: 0.0, bottom: 0.0, left: 0.0, right: 0.0),
      padding: EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 15.0),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.transparent)),
        color: Colors.transparent,
      ),
      child: Container(
        //height: 250,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              (widget.title != null && widget.title != "")
                  ? Text(
                      widget.title,
                      //overflow: TextOverflow.ellipsis,
                      //softWrap: true,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : Container(),
              SizedBox(height: 10.0),
              Text(
                description,
                //overflow: TextOverflow.ellipsis,
                //softWrap: true,
                textAlign: widget.textAlign,
                style: TextStyle(fontSize: widget.fontSize, fontWeight: FontWeight.w300),
              )
            ])),
          ],
        ),
      ),
    );
  }
}
