

class User {
  User({
    int? id,
    String? firstname,
    String? lastname,
    String? username,
    String? email,
    String? dialCode,
    String? mobile,
    String? refBy,
    String? countryName,
    String? countryCode,
    String? city,
    String? state,
    String? zip,
    String? address,
    String? status,
    String? kycRejectionReason,
    String? kv,
    String? ev,
    String? sv,
    String? profileComplete,
    String? verCodeSendAt,
    String? ts,
    String? tv,
    String? tsc,
    String? banReason,
    String? provider,
    String? createdAt,
    String? updatedAt,}){
    _id = id;
    _firstname = firstname;
    _lastname = lastname;
    _username = username;
    _email = email;
    _dialCode = dialCode;
    _mobile = mobile;
    _refBy = refBy;
    _countryName = countryName;
    _countryCode = countryCode;
    _city = city;
    _state = state;
    _zip = zip;
    _address = address;
    _status = status;
    _kycRejectionReason = kycRejectionReason;
    _kv = kv;
    _ev = ev;
    _sv = sv;
    _profileComplete = profileComplete;
    _verCodeSendAt = verCodeSendAt;
    _ts = ts;
    _tv = tv;
    _tsc = tsc;
    _banReason = banReason;
    _provider = provider;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
  }

  User.fromJson(dynamic json) {
    _id                 = json['id'];
    _firstname          = json['firstname'] != null? json['firstname'].toString(): "";
    _lastname           = json['lastname'] != null? json['lastname'].toString() : "";
    _username           = json['username'] != null? json['username'].toString(): "";
    _email              = json['email'] != null? json['email'].toString(): "";
    _dialCode           = json['dial_code'] != null? json['dial_code'].toString(): "";
    _mobile             = json['mobile'] != null? json['mobile'].toString(): "";
    _refBy              = json['ref_by'] != null? json['ref_by'].toString(): "";
    _city               = json['city'] != null? json['city'].toString(): "";
    _state              = json['state'] != null? json['state'].toString(): "";
    _zip                = json['zip'] != null? json['zip'].toString(): "";
    _address            = json['address'] != null? json['address'].toString(): "";
    _status             = json['status'] != null? json['status'].toString(): "";
    _countryName        = json['country_name'] != null? json['country_name'].toString(): "";
    _countryCode        = json['country_code'] != null? json['country_code'].toString(): "";
    _kycRejectionReason = json['kyc_rejection_reason'] != null? json['kyc_rejection_reason'].toString(): "";
    _profileComplete    = json['profile_complete']   != null? json['profile_complete'].toString(): "";
    _verCodeSendAt      = json['ver_code_send_at']   != null? json['ver_code_send_at'].toString(): "";
    _ts                 = json['ts']  != null? json['ts'].toString(): "";
    _tv                 = json['tv']  != null? json['tv'].toString(): "";
    _tsc                = json['tsc'] != null? json['tsc'].toString(): "";
    _kv                 = json['kv']  != null? json['kv'].toString(): "";
    _ev                 = json['ev']  != null? json['ev'].toString(): "";
    _sv                 = json['sv']  != null? json['sv'].toString(): "";
    _banReason          = json['ban_reason'] != null? json['ban_reason'].toString(): "";
    _provider           = json['provider']   != null? json['provider'].toString(): "";
    _createdAt          = json['created_at'] != null? json['created_at'].toString(): "";
    _updatedAt          = json['updated_at'] != null? json['updated_at'].toString(): "";
  }
  int? _id;
  String? _firstname;
  String? _lastname;
  String? _username;
  String? _email;
  String? _dialCode;
  String? _mobile;
  String? _refBy;
  String? _countryName;
  String? _countryCode;
  String? _city;
  String? _state;
  String? _zip;
  String? _address;
  String? _status;
  String? _kycRejectionReason;
  String? _kv;
  String? _ev;
  String? _sv;
  String? _profileComplete;
  String? _verCodeSendAt;
  String? _ts;
  String? _tv;
  String? _tsc;
  String? _banReason;
  String? _provider;
  String? _createdAt;
  String? _updatedAt;

  int? get id => _id;
  String? get firstname => _firstname;
  String? get lastname => _lastname;
  String? get username => _username;
  String? get email => _email;
  String? get dialCode => _dialCode;
  String? get mobile => _mobile;
  String? get refBy => _refBy;
  String? get countryName => _countryName;
  String? get countryCode => _countryCode;
  String? get city => _city;
  String? get state => _state;
  String? get zip => _zip;
  String? get address => _address;
  String? get status => _status;
  String? get kycRejectionReason => _kycRejectionReason;
  String? get kv => _kv;
  String? get ev => _ev;
  String? get sv => _sv;
  String? get profileComplete => _profileComplete;
  String? get verCodeSendAt => _verCodeSendAt;
  String? get ts => _ts;
  String? get tv => _tv;
  String? get tsc => _tsc;
  String? get banReason => _banReason;
  String? get provider => _provider;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['firstname'] = _firstname;
    map['lastname'] = _lastname;
    map['username'] = _username;
    map['email'] = _email;
    map['dial_code'] = _dialCode;
    map['mobile'] = _mobile;
    map['ref_by'] = _refBy;
    map['country_name'] = _countryName;
    map['country_code'] = _countryCode;
    map['city'] = _city;
    map['state'] = _state;
    map['zip'] = _zip;
    map['address'] = _address;
    map['status'] = _status;
    map['kyc_rejection_reason'] = _kycRejectionReason;
    map['kv'] = _kv;
    map['ev'] = _ev;
    map['sv'] = _sv;
    map['profile_complete'] = _profileComplete;
    map['ver_code_send_at'] = _verCodeSendAt;
    map['ts'] = _ts;
    map['tv'] = _tv;
    map['tsc'] = _tsc;
    map['ban_reason'] = _banReason;
    map['provider'] = _provider;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    return map;
  }

}