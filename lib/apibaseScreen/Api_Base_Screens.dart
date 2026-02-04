  class ApiBase {
  static const String baseUrl = "https://app.draravindsivf.com/hrms/";

  // Auth & HRMS
  static const String loginEndpoint = "${baseUrl}api/mobile_login";
  static const String activeUserList = "${baseUrl}api/get_active_users";
  static const String inActiveUserList = "${baseUrl}api/inactiveuserList_api";
  static const String managementApprovalList =
      "${baseUrl}api/approvePendingList_api";
  static const String abscondUserList = "${baseUrl}api/abscondUserList_api";
  static const String noticePeriodUserList =
      "${baseUrl}api/noticePeriodUserList_api";
  static const String allEmployeeList = "${baseUrl}api/allemployee_api";
  static const String employeeDetailsById =
      "${baseUrl}api/employee_details_by_id";
  static const String getEmployeeDetails = "${baseUrl}api/get_employee_details";
  static const String getAllFilters = "${baseUrl}api/get_all_filters";
  static const String logoutEndpoint = "${baseUrl}api/mobile_logout";

  // 🚀 Tracking API
  static const String trackingBase = "${baseUrl}tracking/";
  static const String saveLocation = "${trackingBase}save_location";
  static const String getLocationHistory =
      "${trackingBase}get_location_history";

  static const String saveLocationBatch = "${trackingBase}save_location_batch";

  // Note: If refresh token endpoint doesn't exist, user will need to login again
  // Update this URL if backend provides a refresh token endpoint
  static const String refreshToken = "${baseUrl}api/refresh_token";
}
