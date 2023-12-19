# ICTU SonarQube container image

A sonar image containing plugins and quality profiles used at ICTU.


## Creating a new quality profile

When starting the SonarQube image, new quality profiles will be automatically created for [supported languages](https://github.com/ICTU/sonar/blob/master/rules).
These newly created profiles are set to be the default profile, but can also be [extended with your own custom rules](https://docs.sonarsource.com/sonarqube/latest/instance-administration/quality-profiles/#extending-a-quality-profile).

Extending the default can be done by ensuring that the current profile has a name ending with `EXTENDED` (or `extended`).
Alternatively, the automatic overriding of default profile can be avoided by ensuring that the current profile has a name ending with `DEFAULT` (or `default`).


## Overriding the ICTU standard quality profiles

Add the project code (it will be used as a prefix for the quality profile name) to the environment variable PROJECT_CODE.
Add a list of semicolon separated rule ids to be enabled or disabled to the environment variable PROJECT_RULES.

Example:

    PROJECT_CODE=PROJ1
    PROJECT_RULES=+csharpsquid:S104;-ts:S1561

It is also possible to adjust rule parameter values:

    PROJECT_CODE=PROJ1
    PROJECT_RULES=+csharpsquid:S110|max=6;-ts:S1561

And change severity:

    PROJECT_CODE=PROJ1
    PROJECT_RULES=-squid:S4274;+csharpsquid:S110|max=7&severity=INFO;+csharpsquid:S3925&severity=INFO


## Running with PostgreSQL via a docker composition

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
Alternatively, the `SONARQUBE_TOKEN` can be used as admin credential instead of the `SONARQUBE_USERNAME` / `SONARQUBE_PASSWORD` combination.

The Sonar start script waits for the database to become available (only when using PostgreSQL).
`DB_START_TIMEOUT` (default: 60 seconds) defines how long the script will wait for the database to become available before exiting.
Similarly `SONAR_START_TIMEOUT` (default: 600 seconds) defines how long the script should wait for Sonar to start up.


## Get in touch

Point of contact for this repository is [Dennie Bouman](https://github.com/ICTU/sonar/blob/master/@denniebouman).
