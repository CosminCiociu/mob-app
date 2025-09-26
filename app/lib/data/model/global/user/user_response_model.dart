class GlobalUser {
  int? id;
  String? firstName;
  String? lastName;
  String? username;
  String? email;
  String? countryCode;
  String? mobile;
  String? refBy;
  Address? address;
  String? image;
  String? status;
  String? kv;
  String? ev;
  String? sv;
  String? profileComplete;
  String? verCodeSendAt;
  String? ts;
  String? tv;
  String? tsc;
  String? banReason;
  String? createdAt;
  String? updatedAt;
  String? getImage;

  GlobalUser({
    this.id,
    this.firstName,
    this.lastName,
    this.username,
    this.email,
    this.countryCode,
    this.mobile,
    this.refBy,
    this.address,
    this.image,
    this.status,
    this.kv,
    this.ev,
    this.sv,
    this.profileComplete,
    this.verCodeSendAt,
    this.ts,
    this.tv,
    this.tsc,
    this.banReason,
    this.createdAt,
    this.updatedAt,
    this.getImage,
  });

  factory GlobalUser.fromJson(Map<String, dynamic> json) => GlobalUser(
        id: json["id"],
        firstName: json["firstname"] ?? '',
        lastName: json["lastname"] ?? '',
        username: json["username"] ?? '',
        email: json["email"] ?? '',
        countryCode: json["country_code"] ?? '',
        mobile: json["mobile"] ?? '',
        refBy: json["ref_by"] ?? '',
        address: json["address"] == null ? null : Address.fromJson(json["address"]),
        image: json["image"] ?? '',
        status: json["status"] ?? '',
        kv: json["kv"] ?? '',
        ev: json["ev"] ?? '',
        sv: json["sv"] ?? '',
        profileComplete: json["profile_complete"] ?? '',
        verCodeSendAt: json["ver_code_send_at"] ?? '',
        ts: json["ts"] ?? '',
        tv: json["tv"] ?? '',
        tsc: json["tsc"] ?? '',
        banReason: json["ban_reason"] ?? '',
        createdAt: json["created_at"] ?? '',
        updatedAt: json["updated_at"] ?? '',
        getImage: json["get_image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "firstname": firstName,
        "lastname": lastName,
        "username": username,
        "email": email,
        "country_code": countryCode,
        "mobile": mobile,
        "ref_by": refBy,
        "address": address?.toJson(),
        "image": image,
        "status": status,
        "kv": kv,
        "ev": ev,
        "sv": sv,
        "profile_complete": profileComplete,
        "ver_code_send_at": verCodeSendAt,
        "ts": ts,
        "tv": tv,
        "tsc": tsc,
        "ban_reason": banReason,
        "created_at": createdAt?.toString(),
        "updated_at": updatedAt?.toString(),
        "get_image": getImage,
      };
}

class Address {
  String? address;
  String? state;
  String? zip;
  String? country;
  String? city;

  Address({
    this.address,
    this.state,
    this.zip,
    this.country,
    this.city,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        address: json["address"],
        state: json["state"],
        zip: json["zip"].toString(),
        country: json["country"],
        city: json["city"],
      );

  Map<String, dynamic> toJson() => {
        "address": address,
        "state": state,
        "zip": zip,
        "country": country,
        "city": city,
      };
}
