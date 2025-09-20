import '../../domain/entities/application_entity.dart';

class ApplicationModel extends ApplicationEntity {
  const ApplicationModel({
    required super.appId,
    required super.appImageUrl,
    required super.appVendorName,
    required super.appName,
    required super.appCategoryName,
    required super.appDescription,
  });

  factory ApplicationModel.fromJson(
    dynamic json,
  ) =>
      ApplicationModel(
        appId: json['appId'],
        appImageUrl: json['appImageUrl'],
        appVendorName: json['appVendorName'],
        appName: json['appName'],
        appCategoryName: json['appCategoryName'],
        appDescription: json['appDescription'],
      );

  factory ApplicationModel.fromApplicationEntity(
    ApplicationEntity entity,
  ) =>
      ApplicationModel(
        appId: entity.appId,
        appImageUrl: entity.appImageUrl,
        appVendorName: entity.appVendorName,
        appName: entity.appName,
        appCategoryName: entity.appCategoryName,
        appDescription: entity.appDescription,
      );

  dynamic toJson() => {
        'appId': appId,
        'appImageUrl': appImageUrl,
        'appVendorName': appVendorName,
        'appName': appName,
        'appCategoryName': appCategoryName,
        'appDescription': appDescription,
      };
}
