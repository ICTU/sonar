#!/bin/bash

# Access SonarQube api with admin credentials
function curlAdmin {
    curl -v -u admin:admin "$@"
}

# Check is SonarQube is running
function isUp {
    curl -s -u admin:admin -f "$BASE_URL/api/system/info"
}

# Check if the database is ready for connections
function waitForDatabase {
    until nc -z -v -w30 db 3306
    do
        echo "Waiting for database connection..."
        # wait for 5 seconds before check again
        sleep 5
    done
}

# Wait until SonarQube is operational
function waitForSonarUp {
    # Wait for server to be up
    while [ -z "$PING" ]
    do
        echo "Waiting for sonar to come up"
        sleep 5
        PING=$(isUp)
    done
}

# Wait until SonarQube is operational
function waitForSonarDown {
    # Wait for server to be up
    while [ ! -z "$PING" ]
    do
        echo "Waiting for sonar to come down"
        sleep 5
        PING=$(isUp)
    done
}

# given a profile name, retrieve its key
function getProfileKey {
    local searchProfileName=$1
    local searchLanguage=$2
    local getProfileKeyUrl="$BASE_URL/api/qualityprofiles/search?qualityProfile=$searchProfileName&language=$searchLanguage"
    local json=$(curl "$getProfileKeyUrl")
    local searchResultProfileKey=$(echo "$json" | grep -Eo '"key":"([_A-Z0-9a-z-]*)"' | cut -d: -f2 | sed -r 's/"//g')
    echo "$searchResultProfileKey"
}

function processRule {
    local rule=$1
    local profileKey=$2

    # The first character is the operation
    # + = activate
    # - = deactivate
    local operationType=${rule:0:1}

    # After the operation comes the SonarQube ruleSet which contains ruleId and ruleParams
    local ruleSet=${rule:1}
    IFS='|' read -r ruleId ruleParams <<< "$ruleSet"
    ruleParams=${ruleParams/|/,}

    echo "*** Processing rule ***"
    echo "Rule ${rule}"
    echo "Operation ${operationType}"
    echo "RuleId ${ruleId}"
    echo "RuleParams ${ruleParams}"

    if [ "$operationType" == "+" ]; then
        echo "Activating rule ${ruleId}"
        if [ "$ruleParams" == "" ]; then
            curlAdmin -X POST "$BASE_URL/api/qualityprofiles/activate_rule?key=$profileKey&rule=$ruleId"
        else
            curlAdmin -X POST "$BASE_URL/api/qualityprofiles/activate_rule?key=$profileKey&rule=$ruleId&params=$ruleParams"
        fi
    fi

    if [ "$operationType" == "-" ]; then
        echo "Deactivating rule ${ruleId}"
        curlAdmin -X POST "$BASE_URL/api/qualityprofiles/deactivate_rule?key=$profileKey&rule=$ruleId"
    fi
}

# Create a new SonarQube profile with custom activated rules, inheritance and set as default
# parameters
# $1 = profile name (the filename must match the profile name)
# $2 = parent profile name
# $3 = language (cs | java | py | js | ts | web | ...)
# $4 = comma separated list of rules (keys) to be activated in the profile (apart from the standard parent profile rules)
function createProfile {
    local profileName=$1
    local baseProfileName=$2
    local language=$3
    local rulesFilename="/tmp/rules/${language}.txt"

    # create profile
    # curlAdmin -X POST "$BASE_URL/api/qualityprofiles/create?name=$profileName&language=$language"
    # curlAdmin -X POST --data "qualityProfile=$1&parentQualityProfile=$2&language=$3" "$BASE_URL/api/qualityprofiles/change_parent"
    echo "Copying the profile $baseProfileName $language to $profileName"
    baseProfileKey=$(getProfileKey "$baseProfileName" "$language")
    copyProfileUrl="$BASE_URL/api/qualityprofiles/copy?toName=$profileName&fromKey=$baseProfileKey"
    echo "Posting to $copyProfileUrl"
    curlAdmin -X POST "$copyProfileUrl"

    profileKey=$(getProfileKey "$profileName" "$language")
    echo "The profile $profileName $language has the key $profileKey"

    # activate and deactivate rules in new profile
    while read ruleLine || [ -n "$line" ]; do

        # Each line contains a line with (+|-)ruleId # comment
        # Example: +cs:1032 # somecomment
        IFS='#';ruleSplit=("${ruleLine}");unset IFS;
        rule=${ruleSplit[0]}
        comment=${ruleSplit[1]}

        processRule "$rule" "$profileKey"

    done < "$rulesFilename"

    # if the PROJECT_RULES environment variable is defined and not empty, create a custom project profile
    echo "Project specific rules = $PROJECT_RULES"
    if [[ -n "$PROJECT_RULES" ]]; then
        echo "Creating custom project profile"

        local projectProfileName=$PROJECT_CODE-$profileName
        echo "Project custom profile name is $projectProfileName"

        # create project specific profile
        # curlAdmin -X POST "$BASE_URL/api/qualityprofiles/create?name=$projectProfileName&language=$language"
        # curlAdmin -X POST --data "qualityProfile=$projectProfileName&parentQualityProfile=$profileName&language=$3" "$BASE_URL/api/qualityprofiles/change_parent"
        echo "Copying the profile $baseProfileName $language to $profileName"
        curlAdmin -X POST "$BASE_URL/api/qualityprofiles/copy?fromKey=$profileKey&toName=$projectProfileName"

        # retrieve the new profile key
        profileKey=$(getProfileKey "$projectProfileName" "$language")
        echo "The profile $projectProfileName $language has the key $profileKey"

        IFS=';' read -ra projrules <<< "$PROJECT_RULES"
        for rule in "${projrules[@]}"; do
            echo "Processing project custom rule $rule"
            processRule "$rule" "$profileKey"
        done

        # mark this profile to be activated
        profileName=$projectProfileName
    fi

    # set profile as default
    if [ "$updateDefault" = true ] ; then
        echo "Setting default profile for language $3 to $profileName"
        curlAdmin -X POST "$BASE_URL/api/qualityprofiles/set_default?profileName=$profileName&language=$3"
    fi
}

###########################################################################################################################
# Main
###########################################################################################################################
BASE_URL=http://127.0.0.1:9000

# waitForDatabase

# explicitely set LDAP_REALM to prevent error when starting Sonar without LDAP settings
export LDAP_REALM=${LDAP_REALM}

# Start Sonar
./bin/run.sh &
waitForSonarUp

# (Re-)create the ICTU profiles
createProfile "ictu-cs-profile-v7.10.0" "Sonar%20way" "cs"
createProfile "ictu-java-profile-v5.10.1" "Sonar%20way" "java"
createProfile "ictu-js-profile-v5.0.0" "Sonar%20way%20Recommended" "js"
createProfile "ictu-py-profile-v1.11.0" "Sonar%20way" "py"
createProfile "ictu-ts-profile-v1.8.0" "Sonar%20way%20recommended" "ts"
createProfile "ictu-web-profile-v3.0.1" "Sonar%20way" "web"

# Starting with Sonarqube 6.7, commercial plugins can only be installed on the non-free edition of SonarQube
# # Manually install the vbnet plugin
# # Adding it to plugin-list is not working (causint SQ initilization error "There is already a quality profile with name 'Sonar way' for language 'vb'")
# curlAdmin -X POST "$BASE_URL/api/plugins/install?key=vbnet"
# curlAdmin -X POST "$BASE_URL/api/system/restart"
# echo "Restarting Sonarqube after installing vb plugin"
# waitForSonarDown
# waitForSonarUp
# createProfile "ictu-vb-profile-4.1" "Sonar%20way" "vbnet" "common-vbnet:DuplicatedBlocks;vbnet:S104;vbnet:S1067;vbnet:S134;vbnet:S1541"

wait
