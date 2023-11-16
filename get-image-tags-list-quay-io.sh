#!/bin/bash

# Script Usage
# ./get-image-tags-list-quay-io.sh coreos/etcd

# To print all unique names
# ./get-image-tags-list-quay-io.sh coreos/etcd | jq -r '.tags | [.[] | {name: .name, last_modified: .last_modified}]'|grep name|sort|uniq

base_url="https://quay.io/api/v1/repository/${1}/tag"
page=1
data=""

while true; do
  response=$(curl -L -s "${base_url}?page=${page}")
  data=$(jq -n --argjson old "$(jq -n "${data}")" --argjson new "${response}" '$old + $new') # Concatenate data

  # Check if the response is empty or doesn't have more data
  if [ -z "$response" ] || [ "$(jq '.has_additional' <<< "$response")" == "false" ]; then
      break
  fi

  ((page++))
done

echo "$data"
