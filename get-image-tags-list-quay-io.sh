#!/bin/bash

# Script Usage
# ./get-image-tags-list-quay-io.sh coreos/etcd

# To print all unique names
# ./get-image-tags-list-quay-io.sh coreos/etcd | jq -r '.tags | [.[] | {name: .name, last_modified: .last_modified}]'|grep name|sort|uniq

base_url="https://quay.io/api/v1/repository/${1}/tag"
page=1
max_page=10
data=""

# while true ; do     //use this for infinite loop  
while [ "$page" -le "$max_page" ] ; do
  response=$(curl -L -s "${base_url}?page=${page}")
  response_subset=$(echo $response|jq -r '.tags | [.[] | {name: .name, last_modified: .last_modified}]')
  data=$(jq -n --argjson old "$(jq -n "${data}")" --argjson new "${response_subset}" '$old + $new') # Concatenate data

  # Check if the response is empty or doesn't have more data
  if [ -z "$response" ] || [ "$(jq '.has_additional' <<< "$response")" == "false" ]; then
      break
  fi

  ((page++))
done

echo "$data"
