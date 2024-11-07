# Maintenance related tasks


## Version upgrade workflow

1. Update version spec in `Dockerfile`, `helm/Chart.yaml` and `helm/values.yaml` with the new version of SonarQube
1. Update external plugins in the [config.json](https://github.com/ICTU/sonar/blob/master/src/config.json) with latest versions listed in their respective repository `/releases/` url
1. Update profile versions based on the internal plugin versions in the [config.json](https://github.com/ICTU/sonar/blob/master/src/config.json)
    1. Obtain the base version numbers from the vanilla SonarQube image directory `/opt/sonarqube/lib/extensions`, excluding build number
    1. Update the configuration rules version number `rules_version` if the rules have been changed
1. Create new version tags on GitHub
    1. `MAJOR.MINOR.PATCH`
    1. `MAJOR.MINOR.PATCH-developer`
1. Build and push new images to docker hub with [CircleCI](https://app.circleci.com/pipelines/github/ICTU/sonar)
1. Update helm `Chart.yaml` with the new chart versions, corresponding with the new `appVersion`
1. Update the helm `values.yaml` with the new `ictu/sonar` image tag
1. Push the new chart as OCI artifact to docker hub `ictu/ictu-sonarqube`, with the GitHub action


## Adding plugins

Add the url of the plugin jar-file to be installed to the [config.json](https://github.com/ICTU/sonar/blob/master/src/config.json) value of `plugins`.


## Creating a new quality profile

Modify the [config.json](https://github.com/ICTU/sonar/blob/master/src/config.json) value of `profiles` and add a key (language as profile name) with value dictionary, such as:

    "yaml": {
      "plugin_name": "sonar-ansible-plugin",
      "plugin_external": true,
      "version": "ansible-profile-v2.5.1"
    },

The parameters are:
* `(key)`: language (internal SonarQube language identifier) 
* `plugin_name`: name of the plugin to be used for this profile
* `plugin_external`: true for external plugin, false (default) when it is contained in the base container image
* `version`: profile version string (based on the plugin version)


## Create rule entries from SonarQubes quality profile backup (xml)

In order to make the importing of existing profiles easier, use the transformation `profile_backup_transform.xslt`.
Go to the profiles page in your SonarQube instance, backup a profile to an xml file and transform it.


## Activating or deactivating individual rules in the quality profiles

Modify the corresponding [config.json](https://github.com/ICTU/sonar/blob/master/src/config.json) value of `rules[language]`.
Each entry represents a rule to be activated or deactivated and has the following syntax: `(operation)(ruleId)#(comment)`

* `operation`: `+` activates a rule; `-` deactivates a rule
* `ruleId`: SonarQube rule identifier

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
