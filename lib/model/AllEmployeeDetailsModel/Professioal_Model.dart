class ProfessionalModel {
  final String employeeId;
  final String name;
  final String branch;
  final String doj;
  final String designation;
  final String monthlyCTC;
  final String annualProfessionalFee;
  final String monthlyProfessionalFee;
  final String monthlyProfessionalTds;
  final String annualTravelAllowance;
  final String monthlyTravelAllowance;
  final String monthlyTravelTds;
  final String? photoUrl;


  ProfessionalModel({
    required this.employeeId,
    required this.name,
    required this.branch,
    required this.doj,
    required this.designation,
    required this.monthlyCTC,
    required this.annualProfessionalFee,
    required this.monthlyProfessionalFee,
    required this.monthlyProfessionalTds,
    required this.annualTravelAllowance,
    required this.monthlyTravelAllowance,
    required this.monthlyTravelTds,
    this.photoUrl,

  });
}
