---
name: verify
description: Prove that a change works in the place a user would notice it. Says where to check each kind of change, what counts as evidence, and what to report when a check fails or can't run. Use after the code is written and before a task is called done.
---

# Verify

A passing test proves the code it covers. This skill proves the change: you check the real thing, on a running app, and you bring back evidence.

A value in `<angle brackets>` that names a command, a folder or a URL belongs to the project. If it is still in brackets here, look it up in the project's rules file, and ask the user for one that is missing.

## 1. Find where to check

Look at what the change touches. One change often has more than one row.

| The change | Where you check it | The evidence |
|---|---|---|
| A screen | The screen itself, signed in as a seeded user. | Screenshots in every language the app supports, before and after the action. |
| An email | The local test mailbox the app sends to. | The received mail: who it went to, its language and where its links lead. |
| An assistant tool | A direct call to the tool. | Its output. For a tool that changes data, also the state afterwards. |
| Stored data | A query after the action. | The value read back. |
| A background job | Trigger the job, then read back. | The state after the run, and the job's log line. |
| Pure logic | Its test. | The test output. |

This table is a template. Replace the rows with the places a change can show up in your app, and add how to reach each one:

- Start the app: `<start command>`
- The app: `<local URL>`
- The local test mailbox: `<local URL>`
- Seeded users and how to sign in as one: `<link to the seed table>`
- Trigger a background job: `<command>`

## 2. Check that the setup is sound

Before you look at the change, make sure you are looking at the right thing. Do one read-only check:

- Is this the app from your branch? Check the port, and the commit if the app shows it.
- Is the page fresh? Reload it. An old tab shows old code.
- Has the app finished starting, and have the background jobs caught up?

## 3. Set up through the user's path

Get to the state you need the way a user would: sign in, click, type, save.

- Don't call an endpoint that only exists for tests.
- Don't write to the database.
- Use the named test data from the seed table. If the check needs data that isn't there, add it to the seed and say so.

A shortcut only proves that the shortcut works.

## 4. Do the check and keep the evidence

1. Take a screenshot, or copy the output, before the action.
2. Do the action.
3. Take the screenshot or the output again.
4. For a screen, repeat it in every language the app supports.
5. Save screenshots and videos in one folder, with names that sort in order: `01-invoice-list.png`, `02-invoice-sent.png`.

Push the folder with `scripts/evidence.sh <folder>` and keep the Markdown it prints. It goes into the pull request description under "Verification".

## 5. When a check fails

Suspect the check before the change. These are more common than a broken feature:

- the wrong port, or an app started from another branch;
- a browser tab that was open before the change;
- a background job that has not caught up yet;
- test data that an earlier check changed.

Rule each one out with output. Then, and only then, go back to the code.

## 6. When a check can't run

Sometimes a check can't be done: the app won't start, a job can't be triggered locally, or the screen needs data the seed doesn't have.

Write **inconclusive** for that check, in that word. Say what you tried and what would be needed to run it. The task stays open.

Never round an inconclusive check up to a pass because the other checks looked fine.

## 7. Clean up

Stop what you started. Remove the data you created, or reset the seed, so the next check starts from the known state.

## Reply

One line per place you checked:

```markdown
**Verification**

- PASS - <where>: <what you saw>, <the evidence>
- FAIL - <where>: <what you saw>, <what you expected>
- INCONCLUSIVE - <where>: <why it could not run>, <what covers it for now>

Not checked: <what is outside this check, such as production>
```

An example of the third line, from a fix that added a nightly clean-up job:

```markdown
- PASS - the uploads screen, in both languages: the stuck upload is gone (01-before.png, 02-after.png)
- INCONCLUSIVE - the nightly job: it can't be triggered on the local stack. Covered by its component tests only.
```
