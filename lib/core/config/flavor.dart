enum Flavor {
  development,
  staging,
  production;

  String get name {
    switch (this) {
      case Flavor.development:
        return 'Development';
      case Flavor.staging:
        return 'Staging';
      case Flavor.production:
        return 'Production';
    }
  }

  String get bundleSuffix {
    switch (this) {
      case Flavor.development:
        return '.dev';
      case Flavor.staging:
        return '.staging';
      case Flavor.production:
        return '';
    }
  }
}
