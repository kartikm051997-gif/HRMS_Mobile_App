class JobApplicationModel {
  final String jobId;
  final String? photoUrl;
  final String jobTitle;
  final String name;
  final String phone;
  final String primaryLocation;
  final String interviewDate;
  final String joiningDate;
  final String uploadedBy;
  final String createdDate;

  JobApplicationModel({
    required this.jobId,
    required this.photoUrl,
    required this.jobTitle,
    required this.name,
    required this.phone,
    required this.interviewDate,
    required this.joiningDate,
    required this.uploadedBy,
    required this.createdDate,
    required this.primaryLocation,
  });
}
