import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flyweb/src/themes/UIImages.dart';

class Options {
  static List navigatinBarStyle = [
    {
      'value': 'center',
      'image': UIImages.navigation_center,
    },
    {
      'value': 'left',
      'image': UIImages.navigation_left,
    },
    {
      'value': 'right',
      'image': UIImages.navigation_right,
    },
    {
      'value': 'empty',
      'image': UIImages.navigation_no,
    },
  ];

  static List headerTypeOptions = [
    {
      'value': 'text',
      'image': UIImages.header_type_nameapp,
    },
    {
      'value': 'image',
      'image': UIImages.header_type_logo,
    },
    {
      'value': 'empty',
      'image': UIImages.header_type_empty,
    }
  ];

  static List listLeftOptions = [
    {
      'value': 'icon_menu',
      'image': UIImages.menu_left_drawer,
    },
    {
      'value': 'icon_home',
      'image': UIImages.menu_left_home,
    },
    {
      'value': 'icon_share',
      'image': UIImages.menu_left_share,
    },
    {
      'value': 'icon_reload',
      'image': UIImages.menu_left_roload,
    },
    {
      'value': 'icon_back',
      'image': UIImages.menu_left_back,
    },
    {
      'value': 'icon_forward',
      'image': UIImages.menu_left_forward,
    },
    {
      'value': 'icon_back_forward',
      'image': UIImages.menu_left_back_forward,
    },
    {
      'value': 'icon_cart',
      'url': "https://demo.foodomaa.com/cart",
      'image': UIImages.menu_left_cart,
    },
    {
      'value': 'icon_sale',
      'url': "https://demo.foodomaa.com",
      'image': UIImages.menu_left_sale,
    },
    {
      'value': 'icon_search',
      'url': "https://demo.foodomaa.com/explore",
      'image': UIImages.menu_left_search,
    },
    {
      'value': 'icon_exit',
      'image': UIImages.menu_left_exit,
    },
    {
      'value': 'icon_empty',
      'image': UIImages.menu_left_no,
    },
  ];

  static List listRightOptions = [
    {
      'value': 'icon_home',
      'image': UIImages.menu_right_home,
    },
    {
      'value': 'icon_reload',
      'image': UIImages.menu_right_roload,
    },
    {
      'value': 'icon_share',
      'image': UIImages.menu_right_share,
    },
    {
      'value': 'icon_back',
      'image': UIImages.menu_right_back,
    },
    {
      'value': 'icon_forward',
      'image': UIImages.menu_right_forward,
    },
    {
      'value': 'icon_back_forward',
      'image': UIImages.menu_right_back_forward,
    },
    {
      'value': 'icon_cart',
      'url': "https://demo.foodomaa.com/cart",
      'image': UIImages.menu_right_cart,
    },
    {
      'value': 'icon_sale',
      'url': "https://demo.foodomaa.com/",
      'image': UIImages.menu_right_sale,
    },
    {
      'value': 'icon_search',
      'url': "https://demo.foodomaa.com/explore",
      'image': UIImages.menu_right_search,
    },
    {
      'value': 'icon_exit',
      'image': UIImages.menu_right_exit,
    },
    {
      'value': 'icon_empty',
      'image': UIImages.menu_right_no,
    },
  ];

  static List listColorsGradient = [
    {
      'firstColor': "#7366FF",
      'secondColor': "#FF6CAB",
      'title': "Gradient 1",
    },
    {
      'firstColor': "#2E8DE1",
      'secondColor': "#B65EBA",
      'title': "Gradient 2",
    },
    {
      'firstColor': "#8A64EB",
      'secondColor': "#64E8DE",
      'title': "Gradient 3",
    },
    {
      'firstColor': "#B65EBA",
      'secondColor': "#7BF2E9",
      'title': "Gradient 4",
    },
    {
      'firstColor': "#7D77FF",
      'secondColor': "#FF9482",
      'title': "Gradient 5",
    },
    {
      'firstColor': "#FF881B",
      'secondColor': "#FFCF1B",
      'title': "Gradient 6",
    },
    {
      'firstColor': "#EA4D2C",
      'secondColor': "#FFA62E",
      'title': "Gradient 7",
    },
    {
      'firstColor': "#00B8BA",
      'secondColor': "#00FFED",
      'title': "Gradient 8",
    },
    {
      'firstColor': "#6454F0",
      'secondColor': "#00B8BA",
      'title': "Gradient 9",
    },
    {
      'firstColor': "#3A3985",
      'secondColor': "#3499FF",
      'title': "Gradient 10",
    },
    {
      'firstColor': "#F650A0",
      'secondColor': "#FF9897",
      'title': "Gradient 11",
    },
    {
      'firstColor': "#F120A0",
      'secondColor': "#FF1881",
      'title': "Gradient 12",
    },
  ];

  static List listColorsSolid = [
    {
      'firstColor': "#FF6CAB",
      'secondColor': "#FF6CAB",
      'title': "Solid 1",
    },
    {
      'firstColor': "#B65EBA",
      'secondColor': "#B65EBA",
      'title': "Solid 2",
    },
    {
      'firstColor': "#FF9482",
      'secondColor': "#FF9482",
      'title': "Solid 3",
    },
    {
      'firstColor': "#7D77FF",
      'secondColor': "#7D77FF",
      'title': "Solid 4",
    },
    {
      'firstColor': "#FFCF1B",
      'secondColor': "#FFCF1B",
      'title': "Solid 5",
    },
    {
      'firstColor': "#FF881B",
      'secondColor': "#FF881B",
      'title': "Solid 6",
    },
    {
      'firstColor': "#FFA62E",
      'secondColor': "#FFA62E",
      'title': "Solid 7",
    },
    {
      'firstColor': "#00B8BA",
      'secondColor': "#00B8BA",
      'title': "Solid 8",
    },
    {
      'firstColor': "#6454F0",
      'secondColor': "#6454F0",
      'title': "Solid 9",
    },
    {
      'firstColor': "#3499FF",
      'secondColor': "#3499FF",
      'title': "Solid 10",
    },
    {
      'firstColor': "#3A3985",
      'secondColor': "#3A3985",
      'title': "Solid 11",
    },
    {
      'firstColor': "#F650A0",
      'secondColor': "#F650A0",
      'title': "Solid 12",
    },
    {
      'firstColor': "#F110A0",
      'secondColor': "#F110A0",
      'title': "Solid 13",
    }
  ];

  static List listLoader = [
    {
      'value': 'ChasingDots',
      'loading': SpinKitChasingDots(
        color: Colors.white,
        size: 50.0,
      ),
    },
    {
      'value': 'Circle',
      'loading': SpinKitCircle(
        color: Colors.white,
        size: 50.0,
      ),
    },
    {
      'value': 'CubeGrid',
      'loading': SpinKitCubeGrid(
        color: Colors.white,
        size: 50.0,
      ),
    },
    {
      'value': 'FadingCircle',
      'loading': SpinKitFadingCircle(
        color: Colors.white,
        size: 50.0,
      ),
    },
    {
      'value': 'RotatingCircle',
      'loading': SpinKitRotatingCircle(
        color: Colors.white,
        size: 50.0,
      ),
    },
    {
      'value': 'RotatingPlain',
      'loading': SpinKitRotatingPlain(
        color: Colors.white,
        size: 50.0,
      ),
    },
    {
      'value': 'DoubleBounce',
      'loading': SpinKitDoubleBounce(
        color: Colors.white,
        size: 50.0,
      ),
    },
    {
      'value': 'Wave',
      'loading': SpinKitWave(
        color: Colors.white,
        size: 50.0,
      ),
    },
    {
      'value': 'WanderingCubes',
      'loading': SpinKitWanderingCubes(
        color: Colors.white,
        size: 50.0,
      ),
    },
    {
      'value': 'FadingFour',
      'loading': SpinKitFadingFour(
        color: Colors.white,
        size: 50.0,
      ),
    },
    {
      'value': 'FadingCube',
      'loading': SpinKitFadingCube(
        color: Colors.white,
        size: 50.0,
      ),
    },
    {
      'value': 'empty',
      'loading': UIImages.no,
    },
  ];
}
