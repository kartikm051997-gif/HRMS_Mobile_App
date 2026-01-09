class ApiBase {
  static const String baseUrl = "https://app.draravindsivf.com/hrms/";

  // Auth & HRMS
  static const String loginEndpoint = "${baseUrl}api/mobile_login";
  static const String activeUserList = "${baseUrl}api/get_active_users";
  static const String getAllFilters = "${baseUrl}api/get_all_filters";
  static const String logoutEndpoint = "${baseUrl}api/mobile_logout";

  // 🚀 Tracking API
  static const String trackingBase = "${baseUrl}tracking/";
  static const String saveLocation = "${trackingBase}save_location";
  static const String getLocationHistory =
      "${trackingBase}get_location_history";
}
