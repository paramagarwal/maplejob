import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  Future<void> logLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
  }

  Future<void> logSignUp(String method) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  Future<void> logJobView(String jobId, String jobTitle) async {
    await _analytics.logEvent(
      name: 'job_view',
      parameters: {
        'job_id': jobId,
        'job_title': jobTitle,
      },
    );
  }

  Future<void> logApplicationSubmitted(String jobId, String jobTitle, String department) async {
    await _analytics.logEvent(
      name: 'application_submitted',
      parameters: {
        'job_id': jobId,
        'job_title': jobTitle,
        'department': department,
      },
    );
  }

  Future<void> logResumeUploaded(String filename) async {
    await _analytics.logEvent(
      name: 'resume_uploaded',
      parameters: {
        'filename': filename,
      },
    );
  }
}
