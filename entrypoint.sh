#!/bin/bash

set -e

PULLS=$(curl \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token $PERSONAL_ACCESS_TOKEN" \
  "https://api.github.com/repos/$REPO/pulls" | jq --raw-output '.[] | @base64')

for pull in $PULLS; do
  json=$(echo -n "$pull" | base64 --decode)
  auto_merge=$(echo "$json" | jq -c '.auto_merge')
  ref=$(echo "$json" | jq -c '.head.ref')
  pull_request_number=$(echo "$json" | jq -c '.number')

  if [[ "$auto_merge" != "null" ]]; then
    curl \
      -X POST \
      -H "Accept: application/vnd.github.v3+json" \
      -H "Authorization: token $PERSONAL_ACCESS_TOKEN" \
      "https://api.github.com/repos/$REPO/actions/workflows/$WORKFLOW/dispatches" \
      -d "{\"ref\": $ref, \"inputs\": { \"pr_number\": \"$pull_request_number\"}}"
  fi
done
