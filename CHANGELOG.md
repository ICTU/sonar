# Changelog

## [Unreleased]

### Added

- Dart language profile (#108).
- CSS language profile (#109).
- XML language profile (#110).
- Docker language profile (#111).

### Changed

- Disable autodetect AI-generated code (#116).

## [2025.3.0](https://github.com/ICTU/sonar/releases/tag/2025.3.0) - 2025-06-13

### Added

- Re-add plugin `vaulttec/sonar-auth-oidc` [version 3.0.0](https://github.com/vaulttec/sonar-auth-oidc/releases/tag/3.0.0) (#106).
- Add language profile rules not explicitly defined, but used by Quality-time (#106).

### Changed

- Update to [SonarQube version 2025.3](https://www.sonarsource.com/products/sonarqube/whats-new/2025-3/) (#106).
- Update plugin `spotbugs/sonar-findbugs` to [version 4.5.1](https://github.com/spotbugs/sonar-findbugs/releases/tag/4.5.1) (#106).

### Removed

- Remove plugin `C4tWithShell/community-rust` due to native SonarQube support (#106).

## [2025.2.0](https://github.com/ICTU/sonar/releases/tag/2025.2.0) - 2025-05-23

### Added

- Job hooks to automatically configure settings in Helm chart (#86).

### Changed

- **BREAKING**: Update default db containers to PostgreSQL version 17.4 (#99).
- Update to [SonarQube version 2025.2](https://www.sonarsource.com/products/sonarqube/whats-new/2025-2/) (#103).
- Update plugin `checkstyle/sonar-checkstyle` to [version 10.23.0](https://github.com/checkstyle/sonar-checkstyle/releases/tag/10.23.0) (#103).
- Update plugin `spotbugs/sonar-findbugs` to [version 4.4.2](https://github.com/spotbugs/sonar-findbugs/releases/tag/4.4.2) (#103).

### Removed

- Remove option to override default admin credential with `SONARQUBE_USERNAME` (#83).
- **BREAKING**: Remove plugin `vaulttec/sonar-auth-oidc` due to blocking bug, disabling OpenID support (#103). _NOTE: Plugin was re-added in version 2025.3.0_.

## [10.8.1](https://github.com/ICTU/sonar/releases/tag/10.8.1) - 2025-02-07

### Added

- Rust plugin `C4tWithShell/community-rust` and language profile (#90).
- PL/SQL language profile (#67).

### Changed

- Document the produced container images for Docker Hub (#89).
- Rename TypeScript profile to ts instead of js (#85).
- Update to [SonarQube version 10.8.1](https://www.sonarsource.com/products/sonarqube/whats-new/sonarqube-10-7/) (#91).
- Update plugin `checkstyle/sonar-checkstyle` to [version 10.21.1](https://github.com/checkstyle/sonar-checkstyle/releases/tag/10.21.1) (#91).

### Fixed

- Fix broken link for plugin `spotbugs/sonar-findbugs` (#88).

### Removed

- Remove plugin `sbaudoin/sonar-ansible` and language rules due to clash with built-in IaC (#91).
- Remove community edition build due to uncoupled release cycle (#91).
- Remove deprecated types classification from rule sets in favour of software qualities (#60).

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
