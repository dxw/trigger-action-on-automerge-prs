const main = require("./main.js");
const nock = require('nock')

process.env['GITHUB_REPOSITORY'] = "foo/bar"
process.env['INPUT_PERSONAL_ACCESS_TOKEN'] = "some-fake-token";
process.env['INPUT_WORKFLOW'] = "workflow.yml";

const githubAPIMock = nock('https://api.github.com', {
  reqheaders: {
    authorization: "token some-fake-token"
  }
})

test('it runs successfully when there are no Pull Requests', async function(done) {
  const pullRequests = githubAPIMock.get('/repos/foo/bar/pulls').reply(200, [])

  await main();
  expect(pullRequests.isDone()).toBe(true);

  done();
})

test('it triggers a workflow dispatch on Pull Requests with auto merge set', async function(done) {
  const pullRequests = githubAPIMock.get('/repos/foo/bar/pulls')
    .reply(200, [
      {
        auto_merge: "true",
        head: {
          ref: "abc"
        },
        number: 1
      },
      {
        head: {
          ref: "def"
        },
        number: 2
      }
    ])

  const workflowDispatch = githubAPIMock.post(
      "/repos/foo/bar/actions/workflows/workflow.yml/dispatches",
      JSON.stringify({
        ref: "abc",
        inputs: {
          pr_number: "1"
        }
      })
    )
    .reply(200)

  await main();

  expect(pullRequests.isDone()).toBe(true);
  expect(workflowDispatch.isDone()).toBe(true);

  done();
})
