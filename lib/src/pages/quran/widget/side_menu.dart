import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:mawaqit/i18n/AppLanguage.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:sizer/sizer.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = S.of(context);
    final isArabic = context.select<AppLanguage, bool>((value) => value.isArabic());
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        width: 18.w,
        constraints: BoxConstraints(
          minWidth: 30,
          maxWidth: 100,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.only(
            topRight: isArabic ? Radius.circular(30) : Radius.zero,
            bottomRight: isArabic ? Radius.circular(30) : Radius.zero,
            topLeft: isArabic ? Radius.zero : Radius.circular(30),
            bottomLeft: isArabic ? Radius.zero : Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(Icons.book, size: 48, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.explore, size: 48, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.mosque, size: 48, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.play_arrow, size: 48, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
