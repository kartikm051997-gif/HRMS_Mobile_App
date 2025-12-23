class ApiBase {
  static const String baseUrl = "http://192.168.0.100/hrms/";

  static const String loginEndpoint = "${baseUrl}api/mobile_login";

  static const String activeUserList = "${baseUrl}api/get_active_users";

  static const String getAllFilters =
      "${baseUrl}filters_mobile_dev/get_all_filters";
}
