import 'package:flutter/cupertino.dart';

class Slider {
  String? image;
  String? imageUrl;
  String? title;
  String? description;

  Slider({this.image, this.imageUrl, this.title, this.description});

  Slider.fromJson(Map<String, dynamic> json) {
    image = json['image'];
    imageUrl = json['image_url'];
    title = json['title'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['image'] = this.image;
    data['image_url'] = this.imageUrl;
    data['title'] = this.title;
    data['description'] = this.description;
    return data;
  }
}

