import 'package:flutter/cupertino.dart';
import 'package:mawaqit/src/mawaqit_image/mawaqit_image_cache.dart';
import 'package:mawaqit/src/models/slider.dart';

class SlideItem extends StatelessWidget {
  final int index;
  final List<Slider> sliderList;

  SlideItem(this.index, this.sliderList);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.width,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: MawaqitNetworkImageProvider(sliderList[index].imageUrl!),
            ),
          ),
        ),
        SizedBox(
          height: 20.0,
        ),
        Text(
          sliderList[index].title!,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        SizedBox(
          height: 15.0,
        ),
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(
              sliderList[index].description!,
              style: TextStyle(
                letterSpacing: 1.5,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        )
      ],
    );
  }
}
