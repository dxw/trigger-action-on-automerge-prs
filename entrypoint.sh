#!/bin/bash

set -e

PERSONAL_ACCESS_TOKEN=$1
WORKFLOW=$2

echo "$WORKFLOW"
echo "$GITHUB_REPOSITORY"
echo "$PERSONAL_ACCESS_TOKEN"

PULLS=$(curl \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token $PERSONAL_ACCESS_TOKEN" \
  "https://api.github.com/repos/$GITHUB_REPOSITORY/pulls" | jq --raw-output '.[] | @base64')

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
