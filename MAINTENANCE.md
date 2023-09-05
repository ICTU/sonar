# Maintenance related tasks


## Version upgrade workflow

1. Update `Dockerfile`s with the new version of SonarQube
1. Update [external plugins](https://github.com/ICTU/sonar/blob/master/plugins/plugin-list)
1. Create profiles based on the internal plugin versions in [start-with-profile.sh](https://github.com/ICTU/sonar/blob/rules-update/start-with-profile.sh)
    1. Obtain the base version numbers from the vanilla SonarQube image directory `/opt/sonarqube/lib/extensions`, excluding build number
    1. Update the profile version number `RULES_VERSION` if the rules have been changed
1. Create new version tags on github
    1. `MAJOR.MINOR.PATCH`
    1. `MAJOR.MINOR.PATCH-developer`
1. Build and push new images to docker hub with [CircleCI](https://app.circleci.com/pipelines/github/ICTU/sonar)


## Adding plugins

Add the url of the plugin jar-file to be installed to `plugins/plugin-list`.


## Creating a new quality profile

Modify `start-with-profile.sh` and add a statement to the end of the script, such as:

    createProfile "ictu-cs-profile-v6.6" "Sonar%20way" "cs"

The parameters are:
* Profile name
* Base profile name
* Language (internal SonarQube language identifier)


## Create rules txt file from SonarQubes quality profile backup (xml)

In order to make the importing of existing profiles easier, use the transformation `profile_backup_transform.xslt`.
Go to the profiles page in your SonarQube instance, backup a profile to an xml file and transform it.


## Activating or deactivating individual rules in the quality profiles

Modify the corresponding `rules/(language).txt` file.
Each line represents a rule to be activated or deactivated and has the following syntax: `(operation)(ruleId)#(comment)`
Please ensure each file ends with a new line character, otherwise the rule will not be added to the profile

* **operation**: `+` activates a rule; `-` deactivates a rule
* **ruleId**: SonarQube rule identifier

Example:

    +csharpsquid:S104               # NCSS; used by Quality-time


## Activating or deactivating rule types in the quality profiles

To (de)activate groups of rules by type use this syntax:
`(operation)types=(comma,delimited,list,of,types)#(comment)`

The following types are available:
- `CODE_SMELL`
- `BUG`
- `VULNERABILITY`
- `SECURITY_HOTSPOT`

Example:

    +types=SECURITY_HOTSPOT,VULNERABILITY        # Enable these types by default
