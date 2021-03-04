# Trigger an action on all open Automerge PRs

This action triggers a specified action on all open PRs that have been set to
automerge on a given repo

## Inputs

### `personal-access-token`

**Required** A Github Personal Access Token with Repo access

### `workflow`

**Required** The action to trigger. This action must be setup to respond to a `workflow_dispatch` trigger (see below)

## Example usage

Assuming you have an action called `run.yml` with the following triggers:

```YAML
name: Run

on:
  workflow_dispatch:
    inputs:
      pr_number:
        description: "PR Number"
        required: true
...
```

You can then setup a new action with the following:

```YAML
uses: dxw/trigger-action-on-automerge-prs@v1
with:
  personal-access-token: ${{ secrets.PERSONAL_ACCESS_TOKEN }}
  workflow: "run.yml"
```

An example action could look like this:

```YAML
name: Trigger run.yml

on:
  push:
    branches:
      - main

jobs:
  run:
    runs-on: ubuntu-latest
    steps:
      - name: Run the action
        uses: dxw/trigger-action-on-automerge-prs@v1
        with:
          personal-access-token: ${{ secrets.PERSONAL_ACCESS_TOKEN }}
          workflow: "run.yml"
```

Now, every time you push to `main`, the `run.yml` action will run against every PR
with automerge set!
