# ICTU SonarQube Docker image
A sonar image containing plugins and quality profiles used at ICTU

## Building and running

    docker build . -t ictusonar
    docker run -it -p 9000:9000 ictusonar
    browse to http://localhost:9000

## Adding plugins
Add the url of the plugin to be installed to ```./plugins/plugin-list```

## Quality profiles

### Naming convention

    Profile name: ictu-(languagecode)-profile-(plugin version major.minor)
    Profile backup file: (Profile name).xml

    Example: ictu-cs-profile-6.5
    (languagecode) = cs (the language codes are the SonarQube used language code, such as js, ts, cs, java, py, web)
    (plugin version) = 2.5 (extracted via the admin page / installed plugins)

### Adding quality profiles

Modify profiles/start-with-profile.sh and add a call such as 

    uploadProfile "ictu-cs-profile-6.5" "Sonar%20way" "cs"


### ICTU quality profiles customizations

#### JAVA

Inherits from : Sonar way

Custom activated rules:
- squid:MethodCyclomaticComplexity - Methods should not be too complex - MAJOR
- squid:NoSonar - Track uses of "NOSONAR" comments - MAJOR
- squid:ParsingError - Java parser failure - MAJOR
- squid:S1067 - Expressions should not be too complex - CRITICAL
- squid:S109 - Magic numbers should not be used	- MAJOR
- squid:S1244 - Floating point numbers should not be tested for equality - MAJOR
- squid:S1699 - Constructors should only call non-overridable methods - CRITICAL

#### C#

Inherits from : Sonar way

Custom activated rules:
- common-cs:DuplicatedBlocks - Source files should not have any duplicated blocks - MAJOR
- csharpsquid:S104 - Files should not have too many lines of code - MAJOR
- csharpsquid:S105 - Tabulation characters should not be used - MINOR
- csharpsquid:S134 - Control flow statements "if", "switch", "for", "foreach", "while", "do" and "try" should not be nested too deeply - CRITICAL
- csharpsquid:S1067 - Expressions should not be too complex - CRITICAL
- csharpsquid:S1244 - Floating point numbers should not be tested for equality - MAJOR
- csharpsquid:S1449 - Culture should be specified for "string" operations - MINOR
- csharpsquid:S1541 - Methods and properties should not be too complex - CRITICAL
- csharpsquid:S1699 - Constructors should only call non-overridable methods - CRITICAL
- csharpsquid:S2357	Fields should be private - MAJOR
- csharpsquid:S2737 - "catch" clauses should do more than rethrow - MINOR

#### Python

Inherits from : Sonar way

Custom activated rules:
- common-py:DuplicatedBlocks - Source files should not have any duplicated blocks - MAJOR
- python:ParsingError - Python parser failure - MAJOR
- python:S104 - Files should not have too many lines of code - MAJOR
- python:S134 - Control flow statements "if", "for", "while", "try" and "with" should not be nested too deeply - CRITICAL

#### JS

Inherits from : Sonar way Recommended (upper case r in Recommended)

Custom activated rules:
- javascript:FunctionComplexity - Functions should not be too complex - CRITICAL
- javascript:NestedIfDepth - Control flow statements "if", "for", "while", "switch" and "try" should not be nested too deeply - CRITICAL
- javascript:ParsingError - JavaScript parser failure - MAJOR
- javascript:S100 - Function and method names should comply with a naming convention - MINOR
- javascript:S1067 - Expressions should not be too complex - CRITICAL
- javascript:S2228 - Console logging should not be used - MINOR

#### Web

Inherits from : Sonar way

Custom activated rules:
- common-web:DuplicatedBlocks - Source files should not have any duplicated blocks - MAJOR
- Web:ComplexityCheck - Files should not be too complex - MAJOR
- Web:DoubleQuotesCheck - Attributes should be quoted using double quotes rather than single ones - MINOR
- Web:InlineStyleCheck - The "style" attribute should not be used - MAJOR
- Web:LongJavaScriptCheck - Javascript scriptlets should not have too many lines of code - MAJOR
- Web:NonConsecutiveHeadingCheck - Heading tags should be used consecutively from "H1" to "H6" - MINOR
- Web:RequiredAttributeCheck - Track lack of required attributes - MAJOR
- Web:S1443 - "autocomplete" should be set to "off" on input elements of type "password" - BLOCKER

#### TS

Inherits from : Sonar way recommended (lower case r in recommended)

Custom activated rules:
- typescript:S104 - Files should not have too many lines of code - MAJOR
- typescript:S109 - Magic numbers should not be used - MAJOR
- common-ts:DuplicatedBlocks - Source files should not have any duplicated blocks - MAJOR
- typescript:S105 - Tabulation characters should not be used - MINOR
- typescript:S117 - Variable names should comply with a naming convention - MINOR
- typescript:S1441 - Quotes for string literals should be used consistently - MINOR
- typescript:S1541 - Functions should not be too complex - CRITICAL
- typescript:S2228 - Console logging should not be used - MINOR

#### VB

Inherits from : Sonar way

Custom activated rules: