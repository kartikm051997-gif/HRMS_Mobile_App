class Employee {
  final String employeeId;
  final String name;
  final String branch;
  final String doj;
  final String department;
  final String designation;
  final String monthlyCTC;
  final String payrollCategory;
  final String status;
  final String? photoUrl;
  final String? recruiterName;
  final String? recruiterPhotoUrl;
  final String? createdByName;
  final String? createdByPhotoUrl;

  Employee({
    required this.employeeId,
    required this.name,
    required this.branch,
    required this.doj,
    required this.department,
    required this.designation,
    required this.monthlyCTC,
    required this.payrollCategory,
    required this.status,
    this.photoUrl,
    this.recruiterName,
    this.recruiterPhotoUrl,
    this.createdByName,
    this.createdByPhotoUrl,
  });
}
