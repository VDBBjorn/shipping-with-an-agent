# evidence: a definition of done, and proof for it

This folder goes with the post [Evidence or it didn't happen](https://bjorntocode.com/posts/20261208_evidence_or_it_didnt_happen). It holds the skill every code change starts with, its two playbooks for a bug and a feature, the skill that says where to check a change, and a script that puts screenshots and videos in a pull request.

## How to use it

1. Copy [skills/work](skills/work/SKILL.md) to `.claude/skills/work/` and [skills/verify](skills/verify/SKILL.md) to `.claude/skills/verify/`. The `work` folder has three files: the skill and its two playbooks. Or install the plugin from the [root README](../README.md), which holds the same skills. With the plugin you can't change the done-contract in step 2, and the values of step 3 go into your rules file.
2. Open `work/SKILL.md` and read the done-contract. It is four lines. Change them until they say what "done" means in your project.
3. Open `verify/SKILL.md` and fill in the "where to check" table: your start command, your local test mailbox, your languages, your seeded users.
4. Add one line to your rules file: every task that changes code starts with the `work` skill. [../map/AGENTS.md](../map/AGENTS.md) has that line.
5. Copy [scripts/evidence.sh](scripts/evidence.sh) to `scripts/evidence.sh`. It needs `git` and the GitHub CLI (`gh`), signed in.
6. Give the agent a task and read its last message. It should show each of the four lines with a command and its output, a screenshot or a value read back.

If you take one thing, take the done-contract in [skills/work/SKILL.md](skills/work/SKILL.md). It is four lines, and it changes what the agent's "done" means.

## What's in the folder

| File | What it is |
|---|---|
| [skills/work/SKILL.md](skills/work/SKILL.md) | Picks a playbook, holds the done-contract, says what counts as evidence, and has the brief for a sub-agent. |
| [skills/work/bug.md](skills/work/bug.md) | The bug playbook: a failing test first, three to five possible causes, the failing test committed on its own, red then green in the reply. |
| [skills/work/feature.md](skills/work/feature.md) | The feature playbook: the intent and a goal first, thin slices behind a feature flag, then verify and review. |
| [skills/verify/SKILL.md](skills/verify/SKILL.md) | Where to check each kind of change, how to set the check up, and what to do when a check fails or can't run. |
| [scripts/evidence.sh](scripts/evidence.sh) | Pushes screenshots and videos to a branch called `evidence` and prints the Markdown for the pull request. |

## How the skills fit together

`work` is the entry point. It restates the task, picks a playbook and holds the contract. The playbooks call `verify` for the first line of the contract and the review skill from [../review](../review/README.md) for the second.

The post lists four playbooks: feature, bug, refactor and ship. This folder has files for the first two. A refactor is three lines in `work/SKILL.md`. Shipping is a script, and it is in [../shipping](../shipping/README.md).

A sub-agent is a second agent that the first one starts for a part of the work. It starts with no knowledge of the task, so `work` has a short brief for it. The brief asks for the command that was run and its output. The first agent doesn't pass a sub-agent's "I checked it" on as evidence.

## The evidence script

A code branch is the wrong place for screenshots. The script puts them on a separate branch that is never merged.

```bash
scripts/evidence.sh <folder with screenshots and videos>
```

What it does:

1. It makes a temporary checkout of the `evidence` branch. The first time, it creates that branch empty.
2. It copies the images and videos from your folder into `<your branch>/<date and time>/`.
3. It commits, and pushes to `evidence` on GitHub.
4. It prints one line of Markdown per file, and removes the temporary checkout.

The output looks like this:

```markdown
![01-invoice-list](https://github.com/<owner>/<repo>/blob/<commit>/fix-invoice-total/20260314-101500/01-invoice-list.png?raw=true)
[02-open-invoice (video)](https://github.com/<owner>/<repo>/blob/<commit>/fix-invoice-total/20260314-101500/02-open-invoice.webm?raw=true)
```

Paste those lines under the "Verification" heading of the pull request description. The template for that description is in [../shipping/pr-template.md](../shipping/pr-template.md).

Three things to know:

- The links point at a commit, so they keep working when the `evidence` branch gets more commits.
- On a private repository the images only show for people who can read the repository.
- It picks up `png`, `jpg`, `jpeg`, `gif`, `webm` and `mp4` files from the top level of the folder. GitHub shows the images inside the description and the videos as links.
