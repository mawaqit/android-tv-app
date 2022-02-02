class Floating {
  String id = "";
  String title = "";
  String type = "";
  String icon = "";
  String url = "";
  String status = "";
  String backgroundColor = "";
  String iconColor = "";
  String date = "";
  String iconUrl = "";

  Floating({
    this.id,
    this.title,
    this.type,
    this.icon,
    this.url,
    this.status,
    this.backgroundColor,
    this.iconColor,
    this.date,
    this.iconUrl,
  });

  Floating.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    type = json['type'];
    icon = json['icon'];
    url = json['url'];
    status = json['status'];
    backgroundColor = json['backgroundColor'];
    iconColor = json['iconColor'];
    date = json['date'];
    iconUrl = json['icon_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['type'] = this.type;
    data['icon'] = this.icon;
    data['url'] = this.url;
    data['status'] = this.status;
    data['backgroundColor'] = this.backgroundColor;
    data['iconColor'] = this.iconColor;
    data['date'] = this.date;
    data['icon_url'] = this.iconUrl;
    return data;
  }
}
