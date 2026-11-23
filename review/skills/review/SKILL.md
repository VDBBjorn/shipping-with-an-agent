---
name: review
description: Review a finished change with two fresh agents before it ships. One checks that it does what was asked, the other that it follows the project's rules. Use when a change is done, before a ship, or when the user asks for a review.
---

# Review

Two agents that did not write the change review it. You built the change, so you don't review it yourself. Your job is to brief the reviewers, judge what they find and give the verdict.

A value in `<angle brackets>` that names a file of the project, such as the rules file or the glossary, belongs to the project. If it is still in brackets here, look it up in the project's rules file, and ask the user for one that is missing.

## 1. Fix the range

1. Commit everything. A review of uncommitted work can't be repeated.
2. Note the base and the head: `git diff <base>..<head>`. The verdict belongs to that head commit and to no other.
3. Find what was asked: the issue, or the user's request in this session. If neither is written down, write the request in three lines and let the user confirm it first.
4. Search for other places that call the code you changed, and settle the scope now. Every fix after a review costs a full new round.

## 2. Start two reviewers

Start two new agents at the same time. Each one gets its brief, the range and read access to the repo. Neither gets your summary of the work or the history of this session.

**Reviewer 1: does it do what was asked?**

> You review a change you did not write. Read the request in `<issue or request>` and the diff from `git diff <base>..<head>`. Look for three things: work the request asks for that is missing, behaviour that differs from the request, and changes nobody asked for. For every finding give the file and line, what is wrong and why it matters. If you find nothing, say so. Don't edit anything.

**Reviewer 2: does it follow the rules?**

> You review a change you did not write. Read the project's rules in `<rules file>`, the glossary in `<glossary>` and the skills that apply to the changed files. Then read the diff from `git diff <base>..<head>`. Look for broken rules, and name the rule. Also look for what a careful senior would flag: duplicated logic, a misleading name, a long function, an abstraction nobody needs yet. For every finding give the file and line, what is wrong and why it matters. If you find nothing, say so. Don't edit anything.

Keep the two questions with two reviewers. One reviewer who gets both questions answers the easier one.

## 3. Judge each finding

A reviewer's finding is a claim. Check it before you act on it.

1. Open the file at the line.
2. If the code shows the finding is wrong, drop it and write down why in one line.
3. If the finding is right, decide: it must be fixed (something asked for is missing, or a rule is broken), or it is a note (a smaller remark or a judgement call).

A review with no findings is a valid result. Don't ask the reviewers to look harder.

## 4. Give the verdict

| Verdict | When | What happens |
|---|---|---|
| `FAIL` | Something that was asked for is missing, or a rule is broken. | Fix it, commit, and run the full review again on the new head. |
| `PASS with notes` | Only smaller remarks and judgement calls are left. | List them for the user. |
| `PASS` | Nothing is left. | Done. |

Only a pass on the exact commit that ships counts. A new commit after the verdict means a new review. Green CI is not a verdict.

## 5. Turn a repeated finding into a check

Look at the findings you kept. For each one, ask whether this kind of finding has come up before, in an earlier review or as an earlier bug.

If it has, propose an automatic check that would catch it next time. Write the proposal as an issue for the user to approve. Don't build it as part of this change.

Propose the strongest kind of check that can do the job:

1. **An architecture test**: a test that reads the whole codebase and fails the build when the pattern appears anywhere.
2. **A type**: a type that makes the wrong code impossible to compile.
3. **A hook**: a rule that refuses the agent's edit before it lands. It fits when the mistake can be seen in the text of one edit.
4. **A regular test**: for one specific behaviour.
5. **A line in the agent's instructions**: only for a real judgement call that nothing above can check.

The issue says: the finding, where it came up before, the kind of check, and what the check would refuse.

## Reply

End with this, and nothing after it:

```markdown
**Verdict: <FAIL | PASS with notes | PASS>** on <head commit>

Fixed: <findings you fixed, one line each, with the commit>
Notes: <findings left for the user, with file:line>
Dropped: <findings the code showed to be wrong, with the reason>
Proposed checks: <issues you opened for repeated findings>
```
