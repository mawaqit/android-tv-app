class NavigationIcon {
  String id;
  String icon;
  String title;
  String value;
  String type;
  String url;
  String status;
  String fixed;
  String createdAt;
  String updatedAt;
  String iconUrl;
  String iconUrlBase64;

  NavigationIcon(
      {this.id,
        this.icon,
        this.title,
        this.value,
        this.type,
        this.url,
        this.status,
        this.fixed,
        this.createdAt,
        this.updatedAt,
        this.iconUrl,
        this.iconUrlBase64});

  NavigationIcon.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    icon = json['icon'];
    title = json['title'];
    value = json['value'];
    type = json['type'];
    url = json['url'];
    status = json['status'];
    fixed = json['fixed'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    iconUrl = json['icon_url'];
    iconUrlBase64 = json['icon_url_base64'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['icon'] = this.icon;
    data['title'] = this.title;
    data['value'] = this.value;
    data['type'] = this.type;
    data['url'] = this.url;
    data['status'] = this.status;
    data['fixed'] = this.fixed;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['icon_url'] = this.iconUrl;
    data['icon_url_base64'] = this.iconUrlBase64;
    return data;
  }
}