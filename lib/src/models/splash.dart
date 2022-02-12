class Splash {
  String? id = "";
  String? firstColor = "";
  String? secondColor = "";
  String? logo_splash = "";
  String? img_splash = "";
  String? enable_logo = "";
  String? enable_img = "";
  String? logo_splash_base64 = "";
  String? img_splash_base64 = "";

  Splash({
    this.id,
    this.firstColor,
    this.secondColor,
    this.logo_splash,
    this.img_splash,
    this.enable_logo,
    this.enable_img,
    this.logo_splash_base64,
    this.img_splash_base64,
  });

  Splash.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstColor = json['firstColor'];
    secondColor = json['secondColor'];
    logo_splash = json['logo_splash'];
    img_splash = json['img_splash'];
    enable_logo = json['enable_logo'];
    enable_img = json['enable_img'];
    logo_splash_base64 = json['logo_splash_base64'];
    img_splash_base64 = json['img_splash_base64'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['firstColor'] = this.firstColor;
    data['secondColor'] = this.secondColor;
    data['logo_splash'] = this.logo_splash;
    data['img_splash'] = this.img_splash;
    data['enable_logo'] = this.enable_logo;
    data['enable_img'] = this.enable_img;
    data['logo_splash_base64'] = this.logo_splash_base64;
    data['img_splash_base64'] = this.img_splash_base64;
    return data;
  }
}
