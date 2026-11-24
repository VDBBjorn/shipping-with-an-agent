# shipping: one script to main, and the pull request as the record

This folder goes with the post [Pull requests as receipts](https://bjorntocode.com/posts/20261124_pull_requests_as_receipts). It holds a skeleton of the script that is my only way to main, the script that picks which checks a change needs, a hook that stops the agent from pushing to main any other way, and the template for the pull request description.

## How to use it

1. Copy [scripts/ship.sh](scripts/ship.sh) and [scripts/select-checks.sh](scripts/select-checks.sh) to `scripts/` in your repo and make them executable (`chmod +x`).
2. Open `ship.sh` and replace the three functions at the top (`run_web_checks`, `run_dotnet_checks`, `run_e2e_checks`) with the commands that check your project.
3. Open `select-checks.sh` and change the file patterns to match your folders. Keep the last pattern: anything unknown runs everything.
4. Install the GitHub CLI (`gh`) and sign in. The script uses it for the pull request and for the status on the commit.
5. Try it without pushing: `NO_PUSH=1 scripts/ship.sh`. It rebases, selects and runs the checks, and stops there.
6. Copy [hooks/no-push-main.mjs](hooks/no-push-main.mjs) to `.claude/hooks/` and register it. The entry is in [../review/hooks/settings.example.json](../review/hooks/settings.example.json).
7. Copy [pr-template.md](pr-template.md) to where the agent can find it, and tell it to write the description in that shape. To ship, the agent writes the description to a file and runs `scripts/ship.sh <that file>`.

If you take one file, take [scripts/ship.sh](scripts/ship.sh). Even a version that only runs the tests and pushes gives every later improvement a place to go.

## What's in the folder

| File | What it is |
|---|---|
| [scripts/ship.sh](scripts/ship.sh) | The ship script: rebase, select, check, push the branch, open the pull request, fast-forward main, sign off. |
| [scripts/select-checks.sh](scripts/select-checks.sh) | Reads the changed files and prints which checks to run. |
| [hooks/no-push-main.mjs](hooks/no-push-main.mjs) | A hook that refuses the agent's own pushes to main. |
| [pr-template.md](pr-template.md) | The description: Why, What changed, Scope, Tradeoffs, Blast radius, Verification. |

## Where the idea comes from

Running the checks on the developer's machine and recording the result on the commit is not my idea.

- In 2024 DHH wrote that 37signals was [moving continuous integration back to developer machines](https://world.hey.com/dhh/we-re-moving-continuous-integration-back-to-developer-machines-3ac6c611).
- Basecamp's [gh-signoff](https://github.com/basecamp/gh-signoff) turns that into one command: run the tests locally, and when they pass, post a green status called `signoff` on the commit.

`ship.sh` uses the same pattern and posts the same kind of status. If the sign-off is all you need, use gh-signoff itself. My script adds the steps around it: the rebase, the selection, the pull request and the fast-forward.

## What the ship script does

```bash
scripts/ship.sh <file with the pull request description>
TITLE='Round the invoice total' scripts/ship.sh pr-body.md
NO_PUSH=1 scripts/ship.sh
```

In order:

1. **It refuses a bad start.** It stops when you are on main, when HEAD is detached, or when the working tree has uncommitted changes.
2. **It rebases on main**, unless the branch already contains main. On a conflict it aborts the rebase and stops.
3. **It works out which checks the change needs**, by giving the changed files to `select-checks.sh`.
4. **It runs those checks locally**: the web build and tests, the .NET build and tests, and the end-to-end run.
5. **It pushes the branch and opens or updates its pull request**, with your file as the description. The title is `TITLE`, or the subject of the branch's first commit.
6. **It records a sign-off**: a status on the commit that says which checks passed, and on which machine.
7. **It fast-forwards main** to that exact commit.

If a step fails, the script stops and nothing reaches main.

If main moved while the checks ran, the push in step 7 is refused, because it is not a force push. Run the script again: it rebases and checks the new combination.

Three things you should know before you use it:

- **The push of the branch is a force push.** After a rebase the branch has new commits, so step 5 overwrites the branch on GitHub. Main is never force pushed.
- **GitHub marks the pull request as merged by itself**, because main now contains the pull request's commit. No CI runs on the pull request.
- **The script is the gate.** Nothing on GitHub's side blocks a push to main unless you turn on branch protection. So main only moves once the checks are green and the sign-off is on the commit. If the sign-off can't be recorded, nothing ships.

## What the script assumes

The skeleton is written for this layout. Change the patterns in `select-checks.sh` if yours is different.

```text
web/                     the web app (npm)
src/<Module>/            one .NET project per module
tests/<Module>.Tests/    the tests of one module
tests/Shared/            test helpers used by every test project
e2e/                     Playwright tests
scripts/                 ship.sh and select-checks.sh
```

## How the checks are selected

`select-checks.sh` prints four lines, and `ship.sh` reads them:

```text
web=false
e2e=true
dotnet=some
tests=tests/Billing.Tests/Billing.Tests.csproj tests/Calendar.Tests/Calendar.Tests.csproj
```

That is the output for a change to `src/Calendar/Slot.cs`, in a repo where the Billing module refers to the Calendar module.

| A change to | Runs |
|---|---|
| `docs/`, any `.md` file, `LICENSE` | Nothing. |
| `web/` | The web build and tests, and the end-to-end run. |
| `e2e/` | The end-to-end run. |
| `src/<Module>/` | The tests of that module, the tests of every module that depends on it, and the end-to-end run. |
| `tests/<Module>.Tests/` | That test project. |
| `tests/Shared/`, `scripts/`, `.github/`, the solution file, the shared build settings | Everything. |
| Anything else | Everything. |

The last row matters most. A mistake in the selection costs time, never a skipped check.

"Depends on" is read from the project files: a project that has a `ProjectReference` to a changed project is affected too, and so on up the chain.

A change can still break a test the selection skipped. So run everything once a night on main, and look at the result in the morning.

`ALL=1` makes the selection script select every check:

```bash
ALL=1 scripts/select-checks.sh
ALL=1 NO_PUSH=1 scripts/ship.sh
```

The second line runs every check on the current branch without pushing. The nightly run on main is not in this folder. It is the same three check functions on a fresh checkout of main, and how you schedule it is up to you.

## The hook

The hook runs before every shell command the agent wants to run. It refuses a `git push` that would move main, and tells the agent to use the ship script.

Try it from the root of this repo. The first command passes with exit code 0, the second is refused with exit code 2:

```bash
echo '{"tool_input":{"command":"git push -u origin fix-invoice-total"},"cwd":"."}' \
  | node shipping/hooks/no-push-main.mjs; echo "exit code $?"

echo '{"tool_input":{"command":"git push origin HEAD:main"},"cwd":"."}' \
  | node shipping/hooks/no-push-main.mjs; echo "exit code $?"
```

The second command prints:

```text
no-push-main: main only moves through scripts/ship.sh. Run that script when the user asks to ship.
exit code 2
```

What it refuses:

- a push that names main as the target, in any spelling: `main`, `HEAD:main`, `<branch>:main`, `refs/heads/main`;
- a push without a target, or of `HEAD`, while the current branch is main;
- `git push --all` and `git push --mirror`.

What it does not stop:

- **A person.** The hook only sees the agent's commands. Someone who types `git push` in a terminal isn't stopped.
- **The ship script.** The agent runs `scripts/ship.sh`, and the hook sees that command and not the pushes inside it. That is how the script stays the one way through.
- **A push that is hidden.** The hook reads the command as text. A push inside another script, or inside `sh -c "..."`, gets past it.

For a project with one developer I can live with that. With more people, turn on branch protection as well.

## The pull request description

The script opens the pull request after the checks pass, so nobody reviews on it and no CI runs on it. What makes it worth keeping is the description.

[pr-template.md](pr-template.md) has the six headings from the post. The agent fills them in and passes the file to `ship.sh`. The "Verification" part comes from the evidence step: the commands, the measurements, and the Markdown that [../evidence/scripts/evidence.sh](../evidence/scripts/evidence.sh) prints for the screenshots.

## What it costs

- **Time.** With the end-to-end run, a ship takes me more than twenty minutes. Let the agent run the script in the background and report when it is done.
- **One ship at a time.** Two ships on one machine compete for the same ports. Wait for the first one.
- **A second run on main.** If CI still runs on main before a deploy, it repeats checks the script already ran. I keep mine: it is the last check before production, and it runs on another machine.

## The regression gate

The skeleton leaves this part out, because replaying the routes depends on your test stack. This is how it fits in.

The idea: the saved routes for the flows that bring in the money (see [../e2e](../e2e/README.md)) are replayed on every ship, after the other checks and before the push. A red route stops the ship. The gate never repairs a route. A repair is a separate task with its own review.

In `ship.sh` it would be one more function, called after `run_e2e_checks`:

```bash
# SKETCH, not in ship.sh. Replace both commands with your own.
run_regression_gate() {
  <start the test stack with fresh seed data, without an AI provider key>
  <replay the routes marked as regression, without AI and without repair>
}

run_regression_gate
passed+=" regression"
```

Three rules for the real thing:

1. It replays only routes that passed the last time. A goal without a route is not a gate.
2. It runs for every change that touches code, also when `select-checks.sh` selects a single test project. A change to the docs alone skips it.
3. The same replay runs once more before a deploy, against the build that is about to go out.
