class Tab {
  String? id = "";
  String? title = "";
  String? url = "";
  String? icon_url = "";
  String? icon_base64 = "";

  Tab({this.id, this.title, this.url, this.icon_url, this.icon_base64});

  Tab.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    url = json['url'];
    icon_url = json['icon_url'];
    icon_base64 = json['icon_base64'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['url'] = this.url;
    data['icon_url'] = this.icon_url;
    data['icon_base64'] = this.icon_base64;
    return data;
  }
}
