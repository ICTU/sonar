#!/bin/bash

# Start Sonar
./bin/run.sh &

function curlAdmin {
    curl -v -u admin:admin $@
}

BASE_URL=http://127.0.0.1:9000

function isUp {
    curl -s -u admin:admin -f "$BASE_URL/api/system/info"
}

# parameters
# $1 = profile name (the filename must match the profile name)
# $2 = parent profile name (restoring a profile loses its previous parent, and this has to be set again)
# $3 = language
function uploadProfile {
    curlAdmin -F "backup=@/tmp/profiles/$1.xml" -X POST "$BASE_URL/api/qualityprofiles/restore"
    curlAdmin -X POST "$BASE_URL/api/qualityprofiles/set_default?profileName=$1&language=$3"
    curlAdmin -X POST --data "qualityProfile=$1&parentQualityProfile=$2&language=$3" "$BASE_URL/api/qualityprofiles/change_parent"
}

# Wait for server to be up
PING=`isUp`
while [ -z "$PING" ]
do
    sleep 5
    PING=`isUp`
done

# Restore qualityprofiles
uploadProfile "ictu-cs-profile-6.5" "Sonar%20way" "cs"
uploadProfile "ictu-java-profile-4.14" "Sonar%20way" "java"
uploadProfile "ictu-py-profile-6.5" "Sonar%20way" "py"
uploadProfile "ictu-js-profile-3.2" "Sonar%20way%20Recommended" "js"
uploadProfile "ictu-ts-profile-1.1" "Sonar%20way%20recommended" "ts"
uploadProfile "ictu-web-profile-2.5" "Sonar%20way" "web"

wait