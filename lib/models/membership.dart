class Membership {
  String? membershipId;
  String? membershipName;
  String? membershipPicture;
  String? membershipDescription;
  String? membershipPrice;

  Membership(
      {this.membershipId,
      this.membershipName,
      this.membershipPicture,
      this.membershipDescription,
      this.membershipPrice});

  Membership.fromJson(Map<String, dynamic> json) {
    membershipId = json['membership_id'];
    membershipName = json['membership_name'];
    membershipPicture = json['membership_picture'];
    membershipDescription = json['membership_description'];
    membershipPrice = json['membership_price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['membership_id'] = membershipId;
    data['membership_name'] = membershipName;
    data['membership_picture'] = membershipPicture;
    data['membership_description'] = membershipDescription;
    data['membership_price'] = membershipPrice;
    return data;
  }
}
