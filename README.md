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
        image: ictu/sonar:6.6
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

## Adding plugins
Add the url of the plugin to be installed to ```./plugins/plugin-list```

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

Inherits from : Sonar way

Custom activated rules:
- squid:MethodCyclomaticComplexity - Methods should not be too complex - MAJOR
- squid:NoSonar - Track uses of "NOSONAR" comments - MAJOR
- squid:S1067 - Expressions should not be too complex - CRITICAL
- squid:S109 - Magic numbers should not be used	- MAJOR

### C#

Inherits from : Sonar way

Custom activated rules:
- common-cs:DuplicatedBlocks - Source files should not have any duplicated blocks - MAJOR
- csharpsquid:S104 - Files should not have too many lines of code - MAJOR
- csharpsquid:S134 - Control flow statements "if", "switch", "for", "foreach", "while", "do" and "try" should not be nested too deeply - CRITICAL
- csharpsquid:S1067 - Expressions should not be too complex - CRITICAL
- csharpsquid:S1541 - Methods and properties should not be too complex - CRITICAL

### Python

Inherits from : Sonar way

Custom activated rules:
- common-py:DuplicatedBlocks - Source files should not have any duplicated blocks - MAJOR
- python:S104 - Files should not have too many lines of code - MAJOR
- python:S134 - Control flow statements "if", "for", "while", "try" and "with" should not be nested too deeply - CRITICAL

### JS

Inherits from : Sonar way Recommended (upper case r in Recommended)

Custom activated rules:
- javascript:FunctionComplexity - Functions should not be too complex - CRITICAL
- javascript:NestedIfDepth - Control flow statements "if", "for", "while", "switch" and "try" should not be nested too deeply - CRITICAL
- javascript:S1067 - Expressions should not be too complex - CRITICAL
- javascript:S2228 - Console logging should not be used - MINOR

### TS

Inherits from : Sonar way recommended (lower case r in recommended)

Custom activated rules:
- common-ts:DuplicatedBlocks - Source files should not have any duplicated blocks - MAJOR
- typescript:S109 - Magic numbers should not be used - MAJOR
- typescript:S2228 - Console logging should not be used - MINOR

### Web

Inherits from : Sonar way

Custom activated rules:
- common-web:DuplicatedBlocks - Source files should not have any duplicated blocks - MAJOR
- Web:ComplexityCheck - Files should not be too complex - MAJOR
- Web:LongJavaScriptCheck - Javascript scriptlets should not have too many lines of code - MAJOR
- Web:S1443 - "autocomplete" should be set to "off" on input elements of type "password" - BLOCKER

### VB

Inherits from : Sonar way

Custom activated rules: