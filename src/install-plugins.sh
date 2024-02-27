#!/bin/bash

plugin_list=$(jq -r ".plugins[]?" /src/config.json)
plugin_dir="/opt/sonarqube/extensions/plugins"

# Download plugins
while read -r plugin; do
  wget --no-verbose "${plugin}" -P "${plugin_dir}"
  rtn=$?
  if [ $rtn -ne 0 ]; then
    echo "Error downloading ${plugin}"
    exit $rtn
  fi
done <<< "${plugin_list}"

# Check if unzip required
for file in "${plugin_dir}"/*; do
  if [[ $file =~ \.zip$ ]]; then
    unzip "${file}" -d "${plugin_dir}"
    rm -f "${file}"
  fi
done
