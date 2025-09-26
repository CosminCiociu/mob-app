import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../model/country_model/country_model.dart';

class ProfileCompleteController extends GetxController {
  TextEditingController countryController = TextEditingController(); // for filtering country in bottom sheet
  TextEditingController usernameController = TextEditingController();
  TextEditingController mobileNoController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController zipCodeController = TextEditingController();
  TextEditingController cityController = TextEditingController();

  FocusNode usernameFocusNode = FocusNode();
  FocusNode mobileNoFocusNode = FocusNode();
  FocusNode addressFocusNode = FocusNode();
  FocusNode stateFocusNode = FocusNode();
  FocusNode zipCodeFocusNode = FocusNode();
  FocusNode cityFocusNode = FocusNode();

  bool countryLoading = true;
  List<Countries> countryList = [];
  List<Countries> filteredCountries = [];

  String? countryName;
  String? countryCode;
  String? mobileCode;

  List<Map<String, dynamic>> jsonData = [
    {"country": "United States", "dial_code": "+1", "country_code": "US"},
    {"country": "Canada", "dial_code": "+1", "country_code": "CA"},
    {"country": "United Kingdom", "dial_code": "+44", "country_code": "GB"},
    {"country": "Australia", "dial_code": "+61", "country_code": "AU"},
    {"country": "India", "dial_code": "+91", "country_code": "IN"},
    {"country": "Germany", "dial_code": "+49", "country_code": "DE"},
    {"country": "France", "dial_code": "+33", "country_code": "FR"},
    {"country": "Japan", "dial_code": "+81", "country_code": "JP"},
    {"country": "China", "dial_code": "+86", "country_code": "CN"},
    {"country": "South Africa", "dial_code": "+27", "country_code": "ZA"}
  ];

  void addJsonToCountryList() {
    countryList.clear();
    for (var item in jsonData) {
      countryList.add(Countries.fromJson(item));
    }
    update();
  }

  Future<dynamic> getCountryData() async {
    addJsonToCountryList();
    countryLoading = false;
    update();
  }

  bool isLoading = false;
  bool submitLoading = false;

  void setCountryNameAndCode(String cName, String countryCode, String mobileCode) {
    countryName = cName;
    this.countryCode = countryCode;
    this.mobileCode = mobileCode;
    update();
  }

  void setDefaultCountry() async {
    mobileCode = filteredCountries[0].dialCode;
    update();
  }

  void initData() {
    getCountryData();
  }
}
