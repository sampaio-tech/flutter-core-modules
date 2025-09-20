class ApplicationEntity {
  final int appId;
  final String appImageUrl;
  final String appVendorName;
  final String appName;
  final String appCategoryName;
  final String appDescription;

  const ApplicationEntity({
    required this.appId,
    required this.appImageUrl,
    required this.appVendorName,
    required this.appName,
    required this.appCategoryName,
    required this.appDescription,
  });
}
