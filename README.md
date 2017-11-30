# ICTU SonarQube Docker image
A sonar image containing plugins and quality profiles used at ICTU

## Running from docker hub

    docker run -it -p 9000:9000 ictu/sonar

## Building and running locally

    docker build . -t ictusonar
    docker run -it -p 9000:9000 ictusonar
    browse to http://localhost:9000

## Running with MySQL via a docker composition

Use the following docker-compose file:

    www:
        image: ictu/sonar:latest
        environment:
            - SONARQUBE_JDBC_USERNAME=sonar
            - SONARQUBE_JDBC_PASSWORD=sonar-password
            - "SONARQUBE_JDBC_URL=jdbc:mysql://db/sonar?useUnicode=true&amp;characterEncoding=utf8"
        links:
            - db
    db:
        image: mysql:5.6
        environment:
            - MYSQL_ROOT_PASSWORD=root-password
            - MYSQL_DATABASE=sonar
            - MYSQL_USER=sonar
            - MYSQL_PASSWORD=sonar-password
        volumes:
            - /db/var/lib/mysql:/var/lib/mysql

> Note: Change the passwords above to your own secret value

> Note: The docker images are built automatically when the code is updated in GitHub. This behaviour is configured at: https://hub.docker.com/r/ictu/sonar/~/settings/automated-builds/

## Adding plugins
Add the url of the plugin to be installed to ```./plugins/plugin-list```

> Note: Starting with SonarQube 6.7, commercial plugins can only be installed on the non-free edition of SonarQube. For this reason, the VB.Net plugin is not installed on this image.

## Creating and modifying quality profiles

Modify start-with-profile.sh and add a call such as

    createProfile "ictu-cs-profile-6.5" "Sonar%20way" "cs" "csharpsquid:S104,csharpsquid:S134"

The parameters are:
- profile name
- parent profile name
- language
- comma separated rules list (keys)

## ICTU quality profiles customizations

### JAVA

Inherits from: Sonar way

Custom added rules: https://github.com/ICTU/sonar/blob/master/rules/java.txt

### C#

Inherits from: Sonar way

Custom added rules: https://github.com/ICTU/sonar/blob/master/rules/csharp.txt

### Python

Inherits from: Sonar way

Custom added rules: https://github.com/ICTU/sonar/blob/master/rules/python.txt

### JavaScript

Inherits from: Sonar way Recommended (upper case r in Recommended)

Custom added rules: https://github.com/ICTU/sonar/blob/master/rules/javascript.txt

### TypeScript

Inherits from: Sonar way recommended (lower case r in recommended)

Custom added rules: https://github.com/ICTU/sonar/blob/master/rules/typescript.txt

### VB.NET

Inherits from: Sonar way

Custom added rules: https://github.com/ICTU/sonar/blob/master/rules/vbnet.txt

### Web

Inherits from: Sonar way

Custom added rules: https://github.com/ICTU/sonar/blob/master/rules/web.txt

## Analysing projects

### Typescript

Create a file named "project.settings", on the same location as packages.json. Example:

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

    ng test --watch false --code-coverage

Execute: 

    npm i typescript
    npm i sonar-scanner
    ./node_modules/sonar-scanner/bin/sonar-scanner -Dproject.settings=sonar-project.properties
