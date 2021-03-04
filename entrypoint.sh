#!/bin/bash

set -e

PERSONAL_ACCESS_TOKEN=$1
WORKFLOW=$2

output=$(curl \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token $PERSONAL_ACCESS_TOKEN" \
  "https://api.github.com/repos/$GITHUB_REPOSITORY/pulls")
error_message=$(echo "$output" | jq "try .message")

if [[ $error_message ]]; then
  echo "Error response from Github API was $error_message"
  exit 1
else
  PULLS=$(echo "$output" | jq --raw-output '.[] | @base64')

  for pull in $PULLS; do
    json=$(echo -n "$pull" | base64 -d)
    auto_merge=$(echo "$json" | jq -c '.auto_merge')
    ref=$(echo "$json" | jq -c '.head.ref')
    pull_request_number=$(echo "$json" | jq -c '.number')

    if [[ "$auto_merge" != "null" ]]; then
      curl \
        -X POST \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Authorization: token $PERSONAL_ACCESS_TOKEN" \
        "https://api.github.com/repos/$GITHUB_REPOSITORY/actions/workflows/$WORKFLOW/dispatches" \
        -d "{\"ref\": $ref, \"inputs\": { \"pr_number\": \"$pull_request_number\"}}"
    fi
  done
fi

