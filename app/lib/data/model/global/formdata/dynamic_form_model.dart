// ignore_for_file: prefer_null_aware_operators

import 'package:ovo_meet/data/model/global/formdata/global_keyc_formData.dart';

class DynamicFormModel {
  int? id;
  String? act;
  GlobalKYCForm? formData;
  String? createdAt;
  String? updatedAt;

  DynamicFormModel({
    this.id,
    this.act,
    this.formData,
    this.createdAt,
    this.updatedAt,
  });

  factory DynamicFormModel.fromJson(Map<String, dynamic> json) {
    return DynamicFormModel(
      id: json["id"],
      act: json["act"],
      formData: json["form_data"] == null ? null : GlobalKYCForm.fromJson(json["form_data"]),
      createdAt: json["created_at"] == null ? null : json["created_at"].toString(),
      updatedAt: json["updated_at"] == null ? null : json["updated_at"].toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "act": act,
        "form_data": formData,
        "created_at": createdAt?.toString(),
        "updated_at": updatedAt?.toString(),
      };
}
