class DashboardStats {
  final int totalJobs;
  final int activeJobs;
  final int closedJobs;
  final int totalApplicants;
  final int applicationsToday;
  final int applicationsThisMonth;

  const DashboardStats({
    required this.totalJobs,
    required this.activeJobs,
    required this.closedJobs,
    required this.totalApplicants,
    required this.applicationsToday,
    required this.applicationsThisMonth,
  });
}
