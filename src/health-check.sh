#!/bin/bash

# fetch api/system/status because api/system/health requires authentication
if ! status_result=$(curl -sf localhost:9000/api/system/status); then
  exit 1
fi

# attempt to read json output data
if ! status_json=$(echo "${status_result}" | jq -r .status); then
  exit 1
fi

# verify that the status is indeed UP
[[ "${status_json}" == "UP" ]] || exit 1
