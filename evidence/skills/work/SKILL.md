---
name: work
description: Start here for every task that changes code. Picks the playbook for the task (bug, feature, refactor, ship) and holds the definition of done. Use before the first edit, and again before you say a task is done.
---

# Work

Every task that changes code goes through three steps: restate it, pick the playbook, run the playbook to the end. The end is the done-contract below.

## 1. Restate

Say in one or two sentences what will be different when the task is done, in words a user of the app would recognise. If you can't, ask before you edit anything.

## 2. Pick the playbook

| The task | Playbook |
|---|---|
| Something works differently from what was intended. | [bug.md](bug.md) |
| Something new, or a change in behaviour. | [feature.md](feature.md) |
| The code changes and the behaviour stays the same. | Refactor: run the tests before the first edit and keep the output. Change the code and leave the tests alone. Run the same tests again and show both outputs. |
| The user says "ship". | Run `scripts/ship.sh`. Only when the user asks, and only for the version that was reviewed. |

A task that is two of these is two tasks. Finish one, then start the other.

## 3. The done-contract

A task is done when your last message shows all four, each with its evidence:

1. **Verified where it shows up.** The change is checked in the place a user would notice it, with the `verify` skill. A test alone covers this only for pure logic.
2. **Reviewed.** The `review` skill gave a pass on the commit you report.
3. **Small commits.** Each commit is one change that builds and passes on its own, with a message that says what changed and why.
4. **Records updated.** A new term is in the glossary. A choice someone could question is in the decisions log. What is left is in the issue.

If one of the four can't be shown, the task is not done. Say which one, and why.

## What counts as evidence

Evidence is one of three things, from a run you watched:

- the command that ran and its output;
- a screenshot;
- a value read back from the system.

These are not evidence:

- "it compiles";
- "the tests should pass";
- a summary from another agent saying it checked.

When a check could not run, write **inconclusive** for it, in that word, and say what would be needed to run it. An inconclusive check keeps the task open. Never round it up to a pass.

## The brief for a sub-agent

A sub-agent starts with nothing but your brief. Give it this, filled in:

```markdown
Goal: <one sentence: what is different when you are done>.
Scope: <the files or the module you may change>. Leave everything else alone.
The bar: <how we will both know it works: a test that passes, a screen that shows X>.
Follow AGENTS.md and the skills that apply to these files.
Return: what you changed, the command you ran to check it with its output,
and anything you left undone.
```

What comes back is a claim. Run the command yourself, or look at the screen yourself, before it goes into your reply as evidence.

## Your last message

```markdown
**Done: <the task in one line>**

1. Verified: <where> - <the evidence, or "inconclusive" and why>
2. Reviewed: <the verdict> on <commit>
3. Commits: <the list, one line each>
4. Records: <glossary / decisions log / issue: what you added, or "nothing new">

Left open: <what you did not do, with the issue it went into>
```
