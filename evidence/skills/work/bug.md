# Playbook: a bug

A bug is fixed when a test that failed because of it passes, and you can show both runs. Don't change the code under test before step 4.

## 1. Reproduce it

Find one command that fails because of the bug. It has to be fast and it has to fail every time. Usually it is a new test in the module the bug is in:

```bash
dotnet test tests/<Module>.Tests --filter "<the name of the new test>"
```

Keep the failing output. You need it in your reply.

If you can't make it fail, stop and say so. A fix for a bug you can't reproduce is a guess.

## 2. Make it small

Remove everything from the reproduction that isn't needed for the failure: the extra data, the extra steps, the second user. Stop when removing one more thing makes the test pass.

## 3. Guess, then rule out

Write down three to five possible causes. For each one, write what you would see if it were **not** the cause.

```markdown
1. <cause> - ruled out if <what the output would show>
2. <cause> - ruled out if <what the output would show>
3. <cause> - ruled out if <what the output would show>
```

Check the cheapest one first. Rule a cause out with output: a log line, a value, a test result. An argument doesn't rule anything out.

If all of them are ruled out, write a new list. Don't start editing to see what happens.

## 4. Commit the failing test on its own

Commit the test before the fix, in its own commit. The history then shows the test failing before the fix, and anyone can check out that commit and watch it fail.

This is the one commit that may have a failing test. It still has to build. Say in its message that the test fails on purpose, and which bug it shows.

## 5. Fix the cause

Before you edit, search for every caller of the function you are about to change.

Fix the bug in the place every caller goes through. A fix at the one spot the report named leaves the other callers broken.

Keep the fix as small as the cause allows. A clean-up you notice on the way is a separate task.

## 6. Ask what let it through

A bug got past the tests, the review and the hooks. Ask which automatic check would have caught it, and propose that check as an issue. The review skill lists the kinds of check, strongest first.

## 7. Finish

Run the module's full tests, then the `verify` skill for the place where the user saw the bug, then the `review` skill.

Your last message follows the done-contract in [SKILL.md](SKILL.md), and quotes two runs:

```markdown
Red, before the fix (<commit of the test>):
<the failing output>

Green, after the fix (<commit of the fix>):
<the passing output>

Cause: <one sentence>
Ruled out: <the other causes, each with the output that ruled it out>
```
