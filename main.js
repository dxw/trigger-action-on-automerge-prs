const github = require('@actions/github');
const core = require('@actions/core');

module.exports = async function() {
  const token = core.getInput('personal_access_token');
  const workflowID = core.getInput('workflow');
  const octokit = github.getOctokit(token);
  const [owner, repo] = process.env.GITHUB_REPOSITORY.split('/')

  const pulls = await octokit.pulls.list({
    owner,
    repo
  })

  for await (const pull of pulls.data) {
    if (pull.auto_merge) {
      await octokit.request("post /repos/{owner}/{repo}/actions/workflows/{workflow_id}/dispatches", {
        owner: owner,
        repo: repo,
        ref: pull.head.ref,
        workflow_id: workflowID,
        inputs: { pr_number: String(pull.number) }
      })
    }
  }
}
