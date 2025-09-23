class F11EmployeeModel {
  final String employeeId;
  final String name;
  final String branch;
  final String doj;
  final String department;
  final String designation;
  final String monthlyCTC;
  final String annualProfessionalFee;
  final String monthlyProfessionalFee;
  final String monthlyProfessionalTds;
  final String annualTravelAllowance;
  final String monthlyTravelAllowance;
  final String monthlyTravelTds;
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
  final String? annualStudentStipend;
  final String? monthlyStudentStipend;

  F11EmployeeModel({
    required this.employeeId,
    required this.name,
    required this.branch,
    required this.doj,
    required this.department,
    required this.designation,
    required this.monthlyCTC,
    required this.annualProfessionalFee,
    required this.monthlyProfessionalFee,
    required this.monthlyProfessionalTds,
    required this.annualTravelAllowance,
    required this.monthlyTravelAllowance,
    required this.monthlyTravelTds,
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
    this.annualStudentStipend,
    this.monthlyStudentStipend,
  });
}
