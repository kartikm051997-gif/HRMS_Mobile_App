class ResumeManagementModel {
  final String cvId;
  final String name;
  final String phone;
  final String jobTitle;
  final String primaryLocation;
  final String uploadedBy;
  final String createdDate;

  ResumeManagementModel({
    required this.cvId,
    required this.name,
    required this.phone,
    required this.jobTitle,
    required this.uploadedBy,
    required this.createdDate,
    required this.primaryLocation,
  });
}
