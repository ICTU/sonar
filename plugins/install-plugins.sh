#!/bin/bash

cwd="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
plugin_dir=/opt/sonarqube/extensions/plugins

# Download plugins
while read plugin; do
  wget $plugin -P $plugin_dir
done < $cwd/plugin-list

# Check if unzip required
for file in $plugin_dir/*; do
  if [[ $file =~ \.zip$ ]]; then unzip $file -d $plugin_dir && rm -f $file; fi
done
