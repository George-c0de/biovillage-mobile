import 'package:flutter/foundation.dart';
import 'package:biovillage/widgets/map.dart';

class CompanyInfo {
  String founderPhoto;
  String founderName;
  String aboutPurposes;
  String aboutAdvantage1;
  String aboutAdvantage2;
  String aboutAdvantage3;
  String aboutAdvantage4;
  Point officeCoords;
  String officeAddress;
  String officePhoneClient;
  String officePhonePartners;
  String officeEmail;
  String socialVk;
  String socialInstagram;
  String supportTelegram;
  String aboutOrgDetails;

  CompanyInfo({
    @required this.founderPhoto,
    @required this.founderName,
    this.aboutPurposes,
    this.aboutAdvantage1,
    this.aboutAdvantage2,
    this.aboutAdvantage3,
    this.aboutAdvantage4,
    @required this.officeCoords,
    @required this.officeAddress,
    @required this.officePhoneClient,
    @required this.officePhonePartners,
    @required this.officeEmail,
    @required this.supportTelegram,
    this.socialVk,
    this.socialInstagram,
    this.aboutOrgDetails,
  });

  factory CompanyInfo.fromJson(Map<String, dynamic> json) => CompanyInfo(
        founderPhoto: json["founderPhoto"],
        founderName: json["founderName"],
        aboutPurposes: json["aboutPurposes"],
        aboutAdvantage1: json["aboutAdvantage1"],
        aboutAdvantage2: json["aboutAdvantage2"],
        aboutAdvantage3: json["aboutAdvantage3"],
        aboutAdvantage4: json["aboutAdvantage4"],
        officeCoords: Point(latitude: json["officeLat"], longitude: json["officeLon"]),
        officeAddress: json["officeAddress"],
        officePhoneClient: json["officePhoneClient"],
        officePhonePartners: json["officePhonePartners"],
        officeEmail: json["officeEmail"],
        supportTelegram: json["supportTelegram"],
        socialVk: json["socialVk"],
        socialInstagram: json["socialInstagram"],
        aboutOrgDetails: json["aboutOrgDetails"],
      );
}

CompanyInfo parseJsonCompanyInfo(json) {
  return CompanyInfo.fromJson(json);
}
