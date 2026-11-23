# review: two fresh reviewers and a hook

This folder goes with the post [A review that learns from its own findings](https://bjorntocode.com/posts/20261201_review_that_learns). It holds the skill that lets two agents review a change they didn't write, and a hook that refuses an edit when it breaks a rule I've already decided on.

## How to use it

1. Copy [hooks/guard.mjs](hooks/guard.mjs) to `.claude/hooks/guard.mjs` in your repo.
2. Register it in `.claude/settings.json`. [hooks/settings.example.json](hooks/settings.example.json) shows the entry. It also registers the second hook from the post, the one that blocks pushes to main. That hook is in [../shipping/hooks/no-push-main.mjs](../shipping/hooks/no-push-main.mjs). Remove its entry if you don't use it.
3. Open `guard.mjs` and go through the `rules` list. Delete the rules you don't agree with and change the file patterns to match your repo. Each rule is one line: where it applies, what it looks for, and the message the agent gets.
4. Test the hook from a terminal with the commands under "Try the hook" below.
5. Copy [skills/review/SKILL.md](skills/review/SKILL.md) to `.claude/skills/review/SKILL.md`. Fill in where your issues and your rules live.
6. Ask the agent for a review when a change is done. The skill takes it from there.

If you take one file, take the hook. It's small, it runs on every edit, and it works from the first day.

## What's in the folder

| File | What it is |
|---|---|
| [skills/review/SKILL.md](skills/review/SKILL.md) | The review: fix the range, start two reviewers, judge their findings, give a verdict, turn a repeated finding into an automatic check. |
| [hooks/guard.mjs](hooks/guard.mjs) | A hook that checks every edit before it lands. |
| [hooks/settings.example.json](hooks/settings.example.json) | How both hooks are registered. |

## How the hook works

A hook is a script that Claude Code runs before the agent uses a tool. This one runs before `Edit`, `Write` and `MultiEdit`. It gets the tool call as JSON on its standard input. When it exits with code 2, the edit is refused, and the agent reads what the script wrote to standard error.

`guard.mjs` only looks at the lines an edit adds. A line that was already in the file is never checked, so old code doesn't block new work.

The rules it ships with:

| Where | What it refuses | Why |
|---|---|---|
| xUnit tests | `Task.Delay(` or `Thread.Sleep(` | A fixed delay makes a test slow and unreliable. Wait on the condition. |
| xUnit tests | `[Fact(Skip = ...)]` or `[Theory(Skip = ...)]` | A skipped test checks nothing. Fix it or delete it. |
| C# files | `#pragma warning disable` | A suppressed warning hides the cause. |
| C# files | An empty `catch` block | An error that is swallowed can't be found later. |
| C# files | A `//` comment | My own rule: say it in a name or a test. Delete this rule first if you keep comments. |
| Project files | A dependency with its own `Version=` | Versions live in one central file. |
| Playwright tests | `waitForTimeout(` | The same as a fixed delay. |
| Playwright tests | `.skip(` or `.only(` | The same as a skipped test, and `.only` hides all the others. |

Generated files, such as database migrations, are left alone.

The first three rules are the ones shown in the post. I added the two Playwright rules for this repo, because the end-to-end examples here use Playwright.

## Try the hook

Run these from the root of this repo. The first edit passes: no output, exit code 0. The second is refused with exit code 2.

```bash
echo '{"tool_name":"Write","tool_input":{"file_path":"tests/Billing.Tests/InvoiceTests.cs","content":"[Fact]\npublic async Task Sends_the_invoice() { await WaitUntil(() => sent); }\n"}}' \
  | node review/hooks/guard.mjs; echo "exit code $?"

echo '{"tool_name":"Write","tool_input":{"file_path":"tests/Billing.Tests/InvoiceTests.cs","content":"[Fact(Skip = \"flaky\")]\npublic async Task Sends_the_invoice() { await Task.Delay(500); }\n"}}' \
  | node review/hooks/guard.mjs; echo "exit code $?"
```

The second command prints:

```text
guard: tests/Billing.Tests/InvoiceTests.cs
- A fixed delay in a test: wait on the condition instead.
- A skipped test: fix it or delete it.
exit code 2
```

## When to add a rule

The review skill ends with a step for findings that come back. It proposes the strongest kind of check that can catch the finding: an architecture test, a type, a hook, a regular test, or a line in the agent's instructions. A hook fits when the mistake can be seen in the text of a single edit.

A good hook message says what is wrong and what to do about it. The agent reads it, fixes the code and carries on.

## What is not here

The post also mentions a counter that may only go down: a check that fails the build when a file has more comments than before. That check is specific to how my build is set up, so it isn't in this repo. The idea fits in a few lines of any script: count, compare with a number stored in the repo, fail when the count is higher, and lower the stored number when it drops.
