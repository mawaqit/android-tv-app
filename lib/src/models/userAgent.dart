class UserAgent {
  String id = "";
  String title = "";
  String valueAndroid = "";
  String valueIOS = "";

  UserAgent({this.id, this.title, this.valueAndroid, this.valueIOS});

  UserAgent.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    valueAndroid = json['value_android'];
    valueIOS = json['value_ios'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['value_android'] = this.valueAndroid;
    data['value_ios'] = this.valueIOS;
    return data;
  }
}
