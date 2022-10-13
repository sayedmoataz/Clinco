class DoctorGuideStep {
  String? order, title;

  DoctorGuideStep(this.order, this.title);

  DoctorGuideStep.fromJson(dynamic json) {
    order = json['order'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() => {
        'order': order,
        'title': title,
      };
}
