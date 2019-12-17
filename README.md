# ICTU SonarQube Docker image
A sonar image containing plugins and quality profiles used at ICTU

## Running from docker hub

    docker run -it -p 9000:9000 ictu/sonar

## Building and running locally

    docker build -f Dockerfile-community-edition -t ictusonar .
    docker run -it -p 9000:9000 ictusonar
    browse to http://localhost:9000

## Running with PostgreSQL via a docker composition

Use the following docker-compose file:

  www:
      image: ictu/sonar:7.9.1
      environment:
        - SONARQUBE_JDBC_URL=jdbc:postgresql://db:5432/sonar
      links:
        - db

  db:
      image: postgres:10.9
      environment:
        - POSTGRES_USER=sonar
        - POSTGRES_PASSWORD=sonar
      volumes:
        - /db/postgresql:/var/lib/postgresql
        # This needs explicit mapping due to https://github.com/docker-library/postgres/blob/4e48e3228a30763913ece952c611e5e9b95c8759/Dockerfile.template#L52
        - /db/postgresql_data:/var/lib/postgresql/data

> Note: Change the passwords above to your own secret value
> Note: The sonar start script waits for the database to be available only when using PostgreSQL.
> Note: The docker images are built automatically with circleci and pushed to docker hub when a tag is created.

## Adding plugins
Add the url of the plugin to be installed to ```plugins/plugin-list```


## Creating a new quality profile

Modify start-with-profile.sh and add a statement to the end of the script, such as:

    createProfile "ictu-cs-profile-v6.6" "Sonar%20way" "cs"

The parameters are:
Profile name
Base profile name
Language (internal SonarQube language identifier)

**The newly created profile will be set to default unless the current default profile has a name ending with "DEFAULT" (or "default").**

## Activating or deactivating rules in the quality profiles

Modify the corresponding ```rules/(language).txt``` file.
Each line represents a rule to be activated or deactivated and has the following syntax:
```(operation)(ruleId)#(comment)```

Please ensure each file ends with a new line character, otherwise the rule will not be added to the profile!

**operation**:
    + activates a rule; - deactivates a rule

**ruleId**: SonarQube rule identifier

Example:

    +csharpsquid:S104               # NCSS; used by HQ

## Overriding the standard quality profiles

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


## Analysing projects

### Typescript

Create a file named "sonar-project.properties", on the same location as packages.json. Example:

    sonar.host.url=http://mysonarqubeserver:9000
    sonar.projectKey=myproject:master
    sonar.projectName=myproject master
    sonar.projectVersion=master-version
    sonar.sourceEncoding=UTF-8
    sonar.sources=src
    sonar.tests=src
    sonar.exclusions=**/node_modules/**,**/*.spec.ts,**/keycloak.js
    sonar.test.inclusions=**/*.spec.*
    sonar.typescript.lcov.reportPaths=coverage/lcov.info
    sonar.scm.disabled=true

Create the unit tests coverage file on the location specified at *sonar.typescript.lcov.reportPaths*. If you are using a standard Angular CLI project, you  can do that by executing:

    ng test --single-run --code-coverage

Execute:

    npm i typescript
    npm i sonar-scanner
    ./node_modules/sonar-scanner/bin/sonar-scanner -Dproject.settings=sonar-project.properties

## Create rules txt file from SonarQubes quality profile backup (xml)

In order to make import of existing profiles easier, there is an XSLT transformation file provided: profile_backup_transform.xslt

Go to profiles page in your SonarQube, backup a profile to an xml file and transform it.

