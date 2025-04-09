# ICTU SonarQube container image

A SonarQube container image with plugins, profiles and configuration used at ICTU.

This project provides the SonarQube Server edition on [Docker Hub](https://hub.docker.com/r/ictu/sonar/tags).


## Creating a new quality profile

When starting the SonarQube image, new quality profiles will be automatically created for [supported languages](https://github.com/ICTU/sonar/blob/master/src/config.json).
These newly created profiles are set to be the default profile, but can also be [extended with your own custom rules](https://docs.sonarsource.com/sonarqube/latest/instance-administration/quality-profiles/#extending-a-quality-profile).

Extending the default can be done by ensuring that the current profile has a name ending with `EXTENDED` (or `extended`).
Alternatively, the automatic overriding of default profile can be avoided by ensuring that the current profile has a name ending with `DEFAULT` (or `default`).

**Warning**: If an adjustment has been made to a rule in an `EXTENDED` profile, where the specific rule was originally disabled in the `Sonar Way` profile, this adjustment will not be retained after a restart of the SonarQube instance.


## Overriding the ICTU standard quality profiles

Add the project code (it will be used as a prefix for the quality profile name) to the environment variable `PROJECT_CODE`.
Add a list of semicolon separated rule ids to be enabled or disabled to the environment variable `PROJECT_RULES`.

Example to explicitly enable (+) a C# rule and disable (-) a TypeScript rule:

    PROJECT_CODE=PROJ1
    PROJECT_RULES=+csharpsquid:S104;-typescript:S1301

It is also possible to adjust individual rule parameter values:

    PROJECT_CODE=PROJ1
    PROJECT_RULES=+csharpsquid:S110|max=6;-typescript:S1301


## Running with PostgreSQL via a Docker-composition

Example docker-compose file:

    version: '3.7'
    services:
      www:
        image: ictu/sonar:10.1.0
        environment:
          - SONAR_JDBC_URL=jdbc:postgresql://db:5432/sonar
          - SONAR_JDBC_USERNAME=sonar
          - SONAR_JDBC_PASSWORD=sonar
        ports:
          - 9000:9000
        depends_on:
          - db
      db:
        image: postgres:15.3
        environment:
          - POSTGRES_USER=sonar
          - POSTGRES_PASSWORD=sonar
          - POSTGRES_HOST_AUTH_METHOD=scram-sha-256
          - POSTGRES_INITDB_ARGS=--auth-host=scram-sha-256
        volumes:
          - /db/postgresql_data:/var/lib/postgresql/data


If the default SonarQube admin password has not yet been changed and `SONARQUBE_PASSWORD` is provided, the startup script will try to change the SonarQube default password to the one provided.
Alternatively, the `SONARQUBE_TOKEN` can be used as admin credential instead of the `SONARQUBE_PASSWORD` with default admin user.

The Sonar start script waits for the database to become available (only when using PostgreSQL).
`DB_START_TIMEOUT` (default: 60 seconds) defines how long the script will wait for the database to become available before exiting.
Similarly `SONAR_START_TIMEOUT` (default: 600 seconds) defines how long the script should wait for Sonar to start up.


## Running on Kubernetes with the Helm chart

The Helm chart can be pulled as [ictu/ictu-sonarqube from Docker hub](https://hub.docker.com/r/ictu/ictu-sonarqube/tags) as OCI artifact:
```
helm pull oci://registry-1.docker.io/ictu/ictu-sonarqube
```

As specified in the [Helm values.yaml](https://github.com/ICTU/sonar/blob/master/helm/values.yaml), two credentials `dbCredential` and `sonarPassword` can be used.
Additional environment variables can be passed to the SonarQube container as a list of key-value pairs in `env_vars`, specified in the Helm values.
Note that the default value specified in `sonarqube.extraConfig.configmaps` assumes the release name `ictu-sonarqube`, which you may need to override.
Alternatively, environment variables can be passed directly through the `sonarqube.env` dict in the Helm values (i.e. for secrets).


## Upgrading PostgreSQL containers

Upgrading to a higher _major_ version of PostgreSQL is a breaking change requiring manual action by the operator, because the database storage format is changed.
Be sure to consult the [PostgreSQL docs regarding upgrading](https://www.postgresql.org/docs/current/upgrading.html) in order to decide your upgrade strategy.
Although these changes are marked as breaking change in the changelog, accidentally upgrading does not harm your data because the database will refuse to start.
Pinning the PostgreSQL version in either Helm or docker-compose will prevent the change, allowing the operator more freedom in choosing when to upgrade. 


## Get in touch

Point of contact for this repository is [Dennie Bouman](https://github.com/denniebouman), who can be reached by [opening a new issue in this repository's issue tracker](https://github.com/ICTU/sonar/issues/new).
