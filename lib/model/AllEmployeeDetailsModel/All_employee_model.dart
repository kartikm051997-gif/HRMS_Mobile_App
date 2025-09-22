class AllEmployeeModel {
  final String employeeId;
  final String name;
  final String branch;
  final String doj;
  final String department;
  final String designation;
  final String monthlyCTC;
  final String annualCTC;
  final String basic;
  final String hra;
  final String allowance;
  final String payrollCategory;
  final String pf;
  final String esi;
  final String monthlyTakeHome;
  final String status;
  final String? photoUrl;
  final String? recruiterName;
  final String? recruiterPhotoUrl;
  final String? createdByName;
  final String? createdByPhotoUrl;

  AllEmployeeModel({
    required this.employeeId,
    required this.name,
    required this.branch,
    required this.doj,
    required this.department,
    required this.designation,
    required this.monthlyCTC,
    required this.annualCTC,
    required this.allowance,
    required this.pf,
    required this.esi,
    required this.hra,
    required this.basic,
    required this.monthlyTakeHome,
    required this.payrollCategory,
    required this.status,
    this.photoUrl,
    this.recruiterName,
    this.recruiterPhotoUrl,
    this.createdByName,
    this.createdByPhotoUrl,
  });
}
