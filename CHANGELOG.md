# Changelog

## [Unreleased]

### Changed

- Document the produced container images for Docker Hub (#89).
- Rename TypeScript profile to ts instead of js (#85).

### Fixed

- Fix broken link for sonar-findbugs plugin (#88).

## [10.7.0](https://github.com/ICTU/sonar/releases/tag/10.7.0) - 2024-11-14

### Added

- Kubernetes Helm chart (#74).
- Changelog with backdated changes (#72).

### Changed

- Update to [SonarQube version 10.7.0](https://www.sonarsource.com/products/sonarqube/whats-new/sonarqube-10-7/) (#80).
- Update plugin `checkstyle/sonar-checkstyle` to [version 10.19.0](https://github.com/checkstyle/sonar-checkstyle/releases/tag/10.19.0) (#80).
- Update plugin `spotbugs/sonar-findbugs` to [version 4.3.0](https://github.com/spotbugs/sonar-findbugs/releases/tag/4.3.0) (#80).

## [10.5.1](https://github.com/ICTU/sonar/releases/tag/10.5.1) - 2024-05-23

### Changed

- Update to [SonarQube version 10.5.1](https://www.sonarsource.com/products/sonarqube/whats-new/sonarqube-10-5/) (#76).
- Update plugin `checkstyle/sonar-checkstyle` to [version 10.16.0](https://github.com/checkstyle/sonar-checkstyle/releases/tag/10.16.0) (#76).
- Update plugin `dependency-check/dependency-check-sonar-plugin` to [version 5.0.0](https://github.com/dependency-check/dependency-check-sonar-plugin/releases/tag/5.0.0) (#76).
- Update plugin `spotbugs/sonar-findbugs` to [version 4.2.9](https://github.com/spotbugs/sonar-findbugs/releases/tag/4.2.9) (#76).
- Default maximum number of lines of code for frontend languages (#77).

### Removed

- PMD plugin (#66).
- Possibility to change rule severity (#57).

## [10.3.0](https://github.com/ICTU/sonar/releases/tag/10.3.0) - 2023-12-22

### Added

- Swift quality profile (#50).
- Documentation regarding ICTU GitHub policy (#58).
- Default rules to enable "too many lines" checks (#63).

### Changed

- Update to [SonarQube version 10.3.0](https://www.sonarsource.com/products/sonarqube/whats-new/sonarqube-10-3/) (#55).
- Update plugin `checkstyle/sonar-checkstyle` to [version 10.12.5](https://github.com/checkstyle/sonar-checkstyle/releases/tag/10.12.5) (#55).
- Update plugin `dependency-check/dependency-check-sonar-plugin` to [version 4.0.1](https://github.com/dependency-check/dependency-check-sonar-plugin/releases/tag/4.0.1) (#55).
- Update plugin `sbaudoin/sonar-yaml` to [version 1.9.1](https://github.com/sbaudoin/sonar-yaml/releases/tag/v1.9.1) (#55).
- Update plugin `spotbugs/sonar-findbugs` to [version 4.2.6](https://github.com/spotbugs/sonar-findbugs/releases/tag/4.2.6) (#48).

## [10.1.0](https://github.com/ICTU/sonar/releases/tag/10.1.0) - 2023-09-05

### Added

- Rule versioning to quality profiles (#53).

### Changed

- Update to [SonarQube version 10.1.0](https://www.sonarsource.com/products/sonarqube/whats-new/sonarqube-10-1/) (#52).
- Update plugin `checkstyle/sonar-checkstyle` to [version 10.12.3](https://github.com/checkstyle/sonar-checkstyle/releases/tag/10.12.3) (#52).
- Update plugin `dependency-check/dependency-check-sonar-plugin` to [version 4.0.0](https://github.com/dependency-check/dependency-check-sonar-plugin/releases/tag/4.0.0) (#52).
- Update plugin `sbaudoin/sonar-ansible` to [version 2.5.1](https://github.com/sbaudoin/sonar-ansible/releases/tag/v2.5.1) (#52).
- Reconfigure rules and properties for size, complexity, parameters and suppression (#53).

### Removed

- Separate `Dockerfile` for community and developer editions (#54).

## [9.9.1](https://github.com/ICTU/sonar/releases/tag/9.9.1) - 2023-05-09

### Added

- Default language profile for Kotlin (#48).

### Changed

- Update SonarQube to version 9.9.1 (#48).
- Update plugin `checkstyle/sonar-checkstyle` to [version 10.9.3](https://github.com/checkstyle/sonar-checkstyle/releases/tag/10.9.3) (#48).
- Update plugin `dependency-check/dependency-check-sonar-plugin` to [version 3.1.0](https://github.com/dependency-check/dependency-check-sonar-plugin/releases/tag/3.1.0) (#48).
- Update plugin `spotbugs/sonar-findbugs` to [version 4.2.3](https://github.com/spotbugs/sonar-findbugs/releases/tag/4.2.3) (#48).

## [9.7.1](https://github.com/ICTU/sonar/releases/tag/9.7.1) - 2022-12-02

### Changed

- Update SonarQube to version 9.7.1 (#46).
