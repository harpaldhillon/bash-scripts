#!/bin/bash

json_record_1='{"name": "Alice", "age": 30}'
json_record_2='{"name": "Bob", "age": 25}'

# Creating an array and adding both JSON records
result=$(jq -n --argjson record1 "$json_record_1" --argjson record2 "$json_record_2" '[ $record1, $record2 ]')

echo "$result"

