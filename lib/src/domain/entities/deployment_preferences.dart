import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeploymentPreferences {
  static late final SharedPreferencesWithCache sharedPref;

  /// the absolute path where the clone repository should be
  final String lastProjectPath;

  /// The full name/id of the builded image
  final String lastBuildedImage;

  /// Whether we always clone and execute `docker compose up --no-cache`
  /// or just use `docker compose up`
  final bool preferFullBuild;

  /// Force to the steps to use `git clone <repo>` every time
  /// that we start deployments
  final bool cloneFullProyectAlways;

  /// Decide where we should install all the cloned repositories
  final String preferredFolderInstallation;

  final String launchOptions;

  /// The last repo selected by user
  final int? lastSelectedRepository;

  const DeploymentPreferences({
    required this.lastProjectPath,
    required this.lastBuildedImage,
    required this.preferFullBuild,
    required this.preferredFolderInstallation,
    required this.cloneFullProyectAlways,
    this.launchOptions = "",
    this.lastSelectedRepository,
  });

  static const String inAppSelectionPreference = 'in-app-selection';

  static const DeploymentPreferences standardPreferences =
      DeploymentPreferences(
    lastProjectPath: '',
    lastBuildedImage: '',
    preferFullBuild: true,
    cloneFullProyectAlways: true,
    preferredFolderInstallation: inAppSelectionPreference,
    lastSelectedRepository: null,
  );

  /// Setup the shared preferences instance
  /// so, it should be called just at the main function to ensure that we just have one instance
  static Future<void> setup() async {
    sharedPref = await SharedPreferencesWithCache.create(
      cacheOptions: SharedPreferencesWithCacheOptions(
        allowList: <String>{
          'lastProjectPath',
          'lastBuildedImage',
          'cloneFullProyectAlways',
          'preferredFolderInstallation',
          'preferFullBuild',
          'lastSelectedRepository',
          'launchOptions',
        },
      ),
    );

    // checks if the sharedPref is fully empty to fill
    // the data with the standard preferences
    if (sharedPref.getBool('preferFullBuild') == null &&
        sharedPref.getBool('preferredFolderInstallation') == null) {
      if (kDebugMode) {
        debugPrint('Initialized standard preferences for auto-deployments');
      }
      await standardPreferences.saveToPref();
    }
  }

  Future<void> saveToPref() async {
    final bool? savedFullBuild = sharedPref.getBool('preferFullBuild');
    final bool? savedCloneProjectAlways =
        sharedPref.getBool('cloneFullProyectAlways');
    final String? savedLastProjectPath =
        sharedPref.getString('lastProjectPath');
    final String? savedLastImageInstall =
        sharedPref.getString('lastBuildedImage');
    final String? savedPreferredFolderInstallation =
        sharedPref.getString('preferredFolderInstallation');
    final String? savedLaunchOptions = sharedPref.getString('launchOptions');

    if (savedCloneProjectAlways == null ||
        savedCloneProjectAlways != cloneFullProyectAlways) {
      await sharedPref.setBool(
        'cloneFullProyectAlways',
        cloneFullProyectAlways,
      );
    }

    if (savedFullBuild == null || savedFullBuild != preferFullBuild) {
      await sharedPref.setBool(
        'preferFullBuild',
        preferFullBuild,
      );
    }

    if (savedLaunchOptions == null || savedLaunchOptions != launchOptions) {
      await sharedPref.setString(
        'launchOptions',
        launchOptions,
      );
    }

    if (savedPreferredFolderInstallation == null ||
        savedPreferredFolderInstallation != preferredFolderInstallation) {
      await sharedPref.setString(
        'preferredFolderInstallation',
        preferredFolderInstallation,
      );
    }

    if (savedLastProjectPath == null ||
        savedLastProjectPath != lastProjectPath) {
      await sharedPref.setString(
        'lastProjectPath',
        lastProjectPath,
      );
    }
    if (savedLastImageInstall == null ||
        savedLastImageInstall != lastBuildedImage) {
      await sharedPref.setString(
        'lastBuildedImage',
        lastBuildedImage,
      );
    }
    if (lastSelectedRepository != null) {
      await sharedPref.setInt(
        'lastSelectedRepository',
        lastSelectedRepository!,
      );
    }
  }

  static DeploymentPreferences getCachedDeploymentPreferences() {
    return DeploymentPreferences(
      lastProjectPath: sharedPref.getString('lastProjectPath')!,
      lastBuildedImage: sharedPref.getString('lastBuildedImage')!,
      preferFullBuild: sharedPref.getBool('preferFullBuild')!,
      launchOptions: sharedPref.getString('launchOptions')!,
      cloneFullProyectAlways: sharedPref.getBool('cloneFullProyectAlways')!,
      preferredFolderInstallation:
          sharedPref.getString('preferredFolderInstallation')!,
      lastSelectedRepository: sharedPref.getInt('lastSelectedRepository'),
    );
  }

  /// Whether we should just use `getApplicationDocumentsDirectory()` or user selected folder
  bool get useInAppPath =>
      preferredFolderInstallation == inAppSelectionPreference;

  DeploymentPreferences copyWith({
    String? lastProjectPath,
    String? lastBuildedImage,
    bool? preferFullBuild,
    String? preferredFolderInstallation,
    String? launchOptions,
    int? lastSelectedRepository,
    bool? cloneFullProyectAlways,
    bool forceNull = false,
  }) {
    return DeploymentPreferences(
      lastProjectPath: lastProjectPath ?? this.lastProjectPath,
      lastBuildedImage: lastBuildedImage ?? this.lastBuildedImage,
      preferFullBuild: preferFullBuild ?? this.preferFullBuild,
      cloneFullProyectAlways:
          cloneFullProyectAlways ?? this.cloneFullProyectAlways,
      preferredFolderInstallation:
          preferredFolderInstallation ?? this.preferredFolderInstallation,
      launchOptions: launchOptions ?? this.launchOptions,
      lastSelectedRepository: forceNull
          ? lastSelectedRepository
          : lastSelectedRepository ?? this.lastSelectedRepository,
    );
  }

  @override
  String toString() {
    return 'DeploymentPreferences('
        'lastProjectPath: $lastProjectPath, '
        'lastBuildedImage: $lastBuildedImage, '
        'preferFullBuild: $preferFullBuild, '
        'preferredFolderInstallation: $preferredFolderInstallation, '
        'cloneFullProyectAlways: $cloneFullProyectAlways, '
        'lastSelectedRepository: $lastSelectedRepository'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DeploymentPreferences) return false;

    return other.lastProjectPath == lastProjectPath &&
        other.lastBuildedImage == lastBuildedImage &&
        other.cloneFullProyectAlways == cloneFullProyectAlways &&
        other.preferFullBuild == preferFullBuild &&
        other.preferredFolderInstallation == preferredFolderInstallation &&
        other.launchOptions == launchOptions &&
        other.lastSelectedRepository == lastSelectedRepository;
  }

  @override
  int get hashCode {
    return lastProjectPath.hashCode ^
        lastBuildedImage.hashCode ^
        preferFullBuild.hashCode ^
        cloneFullProyectAlways.hashCode ^
        preferredFolderInstallation.hashCode ^
        launchOptions.hashCode ^
        lastSelectedRepository.hashCode;
  }
}
