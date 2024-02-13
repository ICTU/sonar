#!/bin/bash

cwd="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
plugin_dir="/opt/sonarqube/extensions/plugins"

# Download plugins
while read -r plugin; do
  wget --no-verbose "${plugin}" -P "${plugin_dir}"
  rtn=$?
  if [ $rtn -ne 0 ]; then
    echo "Error downloading ${plugin}"
    exit $rtn
  fi
done < "${cwd}"/plugin-list

# Check if unzip required
for file in "${plugin_dir}"/*; do
  if [[ $file =~ \.zip$ ]]; then
    unzip "${file}" -d "${plugin_dir}"
    rm -f "${file}"
  fi
done
