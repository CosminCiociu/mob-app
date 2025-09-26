import '../global/meassage_model.dart';
import '../user/user.dart';

class ProfileResponseModel {
  ProfileResponseModel({
      this.remark, 
      this.status, 
      this.message, 
      this.data,});

  ProfileResponseModel.fromJson(dynamic json) {
    remark = json['remark'];
    status = json['status'];
    message = json['message'] != null ? Message.fromJson(json['message']) : null;
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
  String? remark;
  String? status;
  Message? message;
  Data? data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['remark'] = remark;
    map['status'] = status;
    if (message != null) {
      map['message'] = message?.toJson();
    }
    if (data != null) {
      map['data'] = data?.toJson();
    }
    return map;
  }

}

class Data {
  Data({
      this.user,});

  Data.fromJson(dynamic json) {
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }
  User? user;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (user != null) {
      map['user'] = user?.toJson();
    }
    return map;
  }

}