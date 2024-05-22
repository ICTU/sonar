#!/bin/bash

if [[ -n "${SONARQUBE_TOKEN}" ]]; then
    BASIC_AUTH="${SONARQUBE_TOKEN}:"
else
    BASIC_AUTH="${SONARQUBE_USERNAME:-admin}:${SONARQUBE_PASSWORD:-admin}"
fi

# Access SonarQube api with admin credentials
function curlAdmin {
    curl -s -u "${BASIC_AUTH}" "$@" | awk 1
}

# Check if the database is ready for connections
function waitForDatabase {
    # get HOST:PORT from JDBC URL
    if [[ "${SONAR_JDBC_URL}" =~ postgresql://([^:/]+)(:([0-9]+))?/ ]]; then
        local host=${BASH_REMATCH[1]}
        local port=${BASH_REMATCH[3]:-5432}
    else
        echo "Only PostgreSQL databases are supported"
        return
    fi
    local pg_connect_params
    pg_connect_params="-h ${host} -p ${port} ${SONAR_JDBC_USERNAME:+-U "$SONAR_JDBC_USERNAME"} -d $(basename "${SONAR_JDBC_URL%%\?*}")"
    echo "Waiting for database connection with pg connect params '${pg_connect_params}'"
    local count=0
    local sleep=5
    local timeout=${DB_START_TIMEOUT:-60}
    until pg_isready ${pg_connect_params} ; do
        if [[ count -gt timeout ]]; then
            echo "ERROR: Failed to start database within ${timeout} seconds"
            exit 1
        fi
        echo "Waiting for database connection..."
        # wait for 5 seconds before check again
        sleep $sleep
        count=$((count+sleep))
    done
    echo "Database listening on ${host}:${port}"

    # Reset all plugin hashes to trigger a full reindex of ElasticSearch data, so coding_rules are indexed correctly
    # Underlying bug should be fixed in 10.8 release, see also:
    #     - https://community.sonarsource.com/t/rules-not-registered-and-index-correctly-after-upgrade-to-10-7/128030
    #     - https://sonarsource.atlassian.net/browse/SONAR-23466
    echo "Forcing ElasticSearch full reindex of rules, due to bug in version 10.7.0"
    PGPASSWORD=${SONAR_JDBC_PASSWORD} psql ${pg_connect_params} -c "UPDATE PLUGINS SET FILE_HASH = ''"
}

# Wait until SonarQube is operational
function waitForSonarUp {
    local count=0
    local sleep=5
    local timeout=${SONAR_START_TIMEOUT:-600}
    # Wait for server status to be UP
    until [[ "${status}" == "UP" ]]; do
        if [[ count -gt timeout ]]; then
            echo "ERROR: Failed to start Sonar within ${timeout} seconds"
            exit 1
        fi

        status=$(curl -sf "${BASE_URL}/api/system/status" | jq -r ".status")
        if [[ "${status}" == "DB_MIGRATION_NEEDED" ]]; then
          echo "Posting signal to migrate_db: ${status}"
          curl -sf -XPOST "${BASE_URL}/api/system/migrate_db"
        else
          echo "Waiting for sonar to come up: ${status}"
        fi

        sleep $sleep
        count=$((count+sleep))
    done
    echo "Sonar is started"
}

# Try to change the default admin password to the one provided in SONARQUBE_PASSWORD
function changeDefaultAdminPassword {
    if [ -n "${SONARQUBE_PASSWORD}" ]; then
        echo "Trying to change the default admin password"
        curl -s -X POST -u "admin:admin" -f "${BASE_URL}/api/users/change_password?login=admin&password=${SONARQUBE_PASSWORD}&previousPassword=admin"
    fi
}

# Test admin credentials
function testAdminCredentials {
    authenticated=$(curl -s -u "${BASIC_AUTH}" -f "${BASE_URL}/api/system/info")
    if [ -z "${authenticated}" ]; then
        echo "################################################################################"
        echo "No or incorrect admin credentials provided. Shutting down SonarQube..."
        echo "################################################################################"
        exit 1
    fi
}

# Given a profile name, retrieve its key
function getProfileKey {
    local searchProfileName=$1
    local searchLanguage=$2
    local getProfileKeyUrl json searchResultProfileKey

    getProfileKeyUrl="${BASE_URL}/api/qualityprofiles/search?qualityProfile=${searchProfileName}&language=${searchLanguage}"
    json=$(curl -s -u "${BASIC_AUTH}" "${getProfileKeyUrl}")
    searchResultProfileKey=$(echo "${json}" | grep -Eo '"key":"([_A-Z0-9a-z-]*)"' | cut -d: -f2 | sed -r 's/"//g')
    echo "${searchResultProfileKey}"
}

# Perform a language quality profile operation on a single rule entry
function processRule {
    local rule=$1
    local profileKey=$2
    local language=$3

    rule=$(echo "${rule}" |tr -d ' ' | cut -d "#" -f 1)
    # The first character is the operation; + or - to activate or deactivate, respectively
    local operationType="${rule:0:1}"
    # After the operation comes the SonarQube ruleSet which contains ruleId and ruleParams
    IFS='|' read -r ruleId ruleParams <<< "${rule:1}"
    ruleParams="${ruleParams/|/,}"

    echo "Processing Rule: '${rule}', Operation: '${operationType}', RuleId: '${ruleId}', RuleParams: '${ruleParams}'"
    if [ "${operationType}" == "+" ]; then
        if [ "${ruleParams}" == "" ]; then
            # Use the activate_rules if we don't need to supply params, because it allows for filtering by language only
            curlAdmin -X POST "${BASE_URL}/api/qualityprofiles/activate_rules?targetKey=${profileKey}&languages=${language}&rule_key=${ruleId}"
        else
            curlAdmin -X POST "${BASE_URL}/api/qualityprofiles/activate_rule?key=${profileKey}&rule=${ruleId}&params=${ruleParams}"
        fi
    elif [ "${operationType}" == "-" ]; then
        curlAdmin -X POST "${BASE_URL}/api/qualityprofiles/deactivate_rule?key=${profileKey}&rule=${ruleId}"
    fi
}

# Create a new SonarQube profile with custom activated rules, inheritance and set as default
# parameters:
# $1 = profile name (the filename must match the profile name)
# $2 = parent profile name
# $3 = language (cs | java | py | js | ts | web | ...)
# $4 = comma separated list of rules (keys) to be activated in the profile (apart from the standard parent profile rules)
function createProfile {
    local profileName=$1
    local baseProfileName=$2
    local language=$3
    rules_list=$(jq -r ".rules.${language}[]?" /src/config.json)

    # Create new profile by copying base profile
    echo "Copying the profile ${baseProfileName} ${language} to ${profileName}"
    baseProfileKey=$(getProfileKey "${baseProfileName}" "${language}")
    copyProfileUrl="${BASE_URL}/api/qualityprofiles/copy?toName=${profileName}&fromKey=${baseProfileKey}"
    curlAdmin -X POST "${copyProfileUrl}"
    profileKey=$(getProfileKey "${profileName}" "${language}")

    # All ICTU sonar instances should run in Multi-Quality Rule (MQR) Mode (https://github.com/ICTU/sonar/issues/91)
    # Therefore, add impactSoftwareQualities SECURITY to all profiles (https://github.com/ICTU/sonar/issues/60)
    curlAdmin -X POST "${BASE_URL}/api/qualityprofiles/activate_rules?targetKey=${profileKey}&languages=${language}&impactSoftwareQualities=SECURITY"
    # Deactivate deprecated rules, including the ones marked as security software quality, before processing rule config
    curlAdmin -X POST "${BASE_URL}/api/qualityprofiles/deactivate_rules?targetKey=${profileKey}&languages=${language}&statuses=DEPRECATED"

    # Activate and deactivate rules as defined by config.json
    while read -r ruleLine ; do
        IFS='#';ruleSplit=("${ruleLine}");unset IFS;
        rule="${ruleSplit[0]}"

        processRule "${rule}" "${profileKey}" "${language}"
    done <<< "${rules_list}"

    # If the PROJECT_RULES environment variable is defined and not empty, create a custom project profile
    echo "Project specific rules = ${PROJECT_RULES}"
    if [[ -n "${PROJECT_RULES}" ]]; then
        local projectProfileName="${PROJECT_CODE}-${profileName}"
        echo "Creating custom project profile for language '${language}', with name '${projectProfileName}'"
        curlAdmin -X POST "${BASE_URL}/api/qualityprofiles/copy?fromKey=${profileKey}&toName=${projectProfileName}"
        profileKey=$(getProfileKey "${projectProfileName}" "${language}")

        # Process the custom profile rules as a single line, with rules split by semicolon
        IFS=';' read -ra projrules <<< "${PROJECT_RULES}"
        for rule in "${projrules[@]}"; do
            processRule "${rule}" "${profileKey}" "${language}"
        done

        # Mark this profile to be activated
        profileName="${projectProfileName}"
    fi

    # Set profile as default only when name does not end in DEFAULT or default
    currentProfileName=$(curl -s -u "${BASIC_AUTH}" "${BASE_URL}/api/qualityprofiles/search?defaults=true" | jq -r --arg LANGUAGE "$3" '.profiles[] | select(.language==$LANGUAGE) | .name')
    echo "Current profile for language '$3' is '${currentProfileName}'"
    shopt -s nocasematch
    if [[ "${currentProfileName}" =~ .*DEFAULT$ ]]; then
        echo "Keeping current default profile '${currentProfileName}' for language '$3'"
    else
        if [[ "${currentProfileName}" =~ .*EXTENDED$ ]]; then
            echo "Changing parent of extended profile '${currentProfileName}' for language '$3' to '${profileName}'"
            curlAdmin -X POST "${BASE_URL}/api/qualityprofiles/change_parent?qualityProfile=${currentProfileName}&parentQualityProfile=${profileName}&language=$3"
        else
            echo "Setting profile '${profileName}' for language '$3' as default"
            curlAdmin -X POST "${BASE_URL}/api/qualityprofiles/set_default?qualityProfile=${profileName}&language=$3"
        fi
    fi
}

##################################
#              Main              #
##################################
BASE_URL="http://127.0.0.1:9000"

if [ "${SONAR_JDBC_URL}" ]; then
  waitForDatabase
fi

# Add shutdown hook
function shutdown {
    echo "Shutdown"
    if [[ -n $PID ]]; then
        kill "${PID}"
        wait "${PID}"
    fi
}
trap "shutdown" EXIT

# Start Sonar
./docker/entrypoint.sh &
PID=$!

waitForSonarUp

changeDefaultAdminPassword

testAdminCredentials

# (Re-)create the ICTU profiles
rules_version=$(jq -r ".rules_version" /src/config.json)
echo "*** Start processing rules for version ${rules_version} ***"
language_profiles=$(jq -r ".profiles | keys[]?" /src/config.json)
for language_name in ${language_profiles}; do
  profile_version=$(jq -r ".profiles.${language_name}.version" /src/config.json)
  profile_name="ictu-${profile_version}-${rules_version}"
  copy_profile=$(jq -r ".profiles.${language_name}.language_profile // \"Sonar way\" | @uri" /src/config.json)
  createProfile "${profile_name}" "${copy_profile}" "${language_name}"
done
echo "*** Finished processing rules ***"

echo ""
echo ""
echo "SonarQube started with ICTU profiles"
echo ""

wait $PID
