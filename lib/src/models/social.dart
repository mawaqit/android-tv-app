class Social {
  String? id="";
  String? title="";
  String? linkUrl="";
  String? idApp="";
  String? icon="";
  String? url="";
  String? status="";
  String? date="";
  String? iconUrl="";

  Social(
      {this.id,
        this.title,
        this.linkUrl,
        this.idApp,
        this.icon,
        this.url,
        this.status,
        this.date,
        this.iconUrl});

  Social.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    linkUrl = json['link_url'];
    idApp = json['id_app'];
    icon = json['icon'];
    url = json['url'];
    status = json['status'];
    date = json['date'];
    iconUrl = json['icon_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['link_url'] = this.linkUrl;
    data['id_app'] = this.idApp;
    data['icon'] = this.icon;
    data['url'] = this.url;
    data['status'] = this.status;
    data['date'] = this.date;
    data['icon_url'] = this.iconUrl;
    return data;
  }
}