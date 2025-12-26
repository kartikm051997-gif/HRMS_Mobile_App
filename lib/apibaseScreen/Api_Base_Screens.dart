class ApiBase {
  static const String baseUrl = "http://192.168.0.100/hrms/";

  // Auth & HRMS
  static const String loginEndpoint = "${baseUrl}api/mobile_login";
  static const String activeUserList = "${baseUrl}api/get_active_users";
  static const String getAllFilters =
      "${baseUrl}filters_mobile_dev/get_all_filters";

  // 🚀 Tracking API
  static const String trackingBase = "${baseUrl}tracking/";
  static const String saveLocation = "${trackingBase}save_location";
  static const String getLocationHistory =
      "${trackingBase}get_location_history";

  // Logout API
  static const String logoutEndpoint =
      "${baseUrl}api/mobile_logout"; // Added the logout endpoint
}
