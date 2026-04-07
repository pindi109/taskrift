class AppConstants {
  // App Info
  static const String appName = 'Taskrift';
  static const String appVersion = '1.0.0';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String tasksCollection = 'tasks';
  static const String projectsCollection = 'projects';

  // Task Priorities
  static const String priorityLow = 'low';
  static const String priorityMedium = 'medium';
  static const String priorityHigh = 'high';
  static const String priorityUrgent = 'urgent';

  // Task Status
  static const String statusTodo = 'todo';
  static const String statusInProgress = 'in_progress';
  static const String statusDone = 'done';

  // Default Project
  static const String defaultProjectId = 'inbox';
  static const String defaultProjectName = 'Inbox';

  // Date Formats
  static const String dateFormat = 'MMM d, yyyy';
  static const String timeFormat = 'h:mm a';
  static const String dateTimeFormat = 'MMM d, yyyy h:mm a';

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Shared Prefs Keys
  static const String prefThemeMode = 'theme_mode';
  static const String prefOnboarded = 'onboarded';

  // Error Messages
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork = 'Network error. Please check your connection.';
  static const String errorAuthFailed = 'Authentication failed. Please try again.';
  static const String errorEmailInUse = 'This email is already in use.';
  static const String errorWeakPassword = 'Password must be at least 6 characters.';
  static const String errorInvalidEmail = 'Please enter a valid email address.';
  static const String errorUserNotFound = 'No account found with this email.';
  static const String errorWrongPassword = 'Incorrect password. Please try again.';

  // Limits
  static const int maxProjectsPerUser = 50;
  static const int maxTasksPerProject = 500;
  static const int maxTaskTitleLength = 200;
  static const int maxTaskNoteLength = 2000;
  static const int maxProjectNameLength = 100;
}
