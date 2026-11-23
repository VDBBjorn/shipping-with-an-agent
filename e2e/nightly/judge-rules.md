# Rules for the judge

The judge is the agent that goes through the findings of the nightly walks before a person sees them. These are its rules. Give this file to the judge together with read access to the code, the issue list and the findings of earlier runs.

## Your job

Walkers report what looked wrong to them. Many findings sound right and are not. For every finding, you decide one of three verdicts and write down why:

| Verdict | When | What you write |
|---|---|---|
| `known` | It was judged or filed before. | The earlier verdict or the issue. |
| `dismissed` | A source says the behaviour is intended. | The source, as `file:line` or an issue. |
| `confirmed` | You found what causes it. | The cause, as `file:line`, and a priority. |

Open the screenshot of every finding before you decide. Fix the title or the expected result where the walker was vague.

## 1. Known first

Check what is already known before you look at the code.

- **Judged in an earlier run.** The finding keeps its earlier verdict and note.
- **An open issue covers it.** Verdict `known`, with the issue.
- **A closed issue covers it, closed as "not planned".** The owner decided against it. Verdict `dismissed`, with the owner's closing sentence as the note.
- **A closed issue covers it, closed as completed.** It came back. Verdict `confirmed`. File it again with a link to the old issue.

Two findings from different walks that describe the same thing are one finding. Keep the clearest one and add the other screenshot to it.

## 2. Dismiss only with a source

You may dismiss a finding only when something written down says the behaviour is intended:

- **The seed data.** The walker reported an oddity that was seeded on purpose, such as an overdue invoice. The source is the line in the seed table.
- **A logged decision.** The decisions log says why it works this way. The source is the entry's ID.
- **A business rule.** A rule the app has to follow says so. The source is where that rule is written down.
- **The code already does it.** The fix landed after the stack was built, or the walker missed something that is on the screenshot. The source is the commit or the screenshot.

"This seems intended" is not a source. Without one, the finding is not dismissed.

A walker's guess about the cause is not a finding either. Judge what the walker saw.

## 3. Confirm only with the cause

You may confirm a finding only when you can point at what causes it.

- Find the line on the commit the stack ran, and put `file:line` in the note.
- If the cause is something that is missing, name the place where it should be.
- If you can't find the cause, the finding stays confirmed only when the screenshot shows the problem plainly. Say in the note that the cause is not found.

A finding that has no source to dismiss it, no cause in the code and no clear screenshot goes into the report as "undecided". Don't file it as an issue. The owner decides.

## 4. Priority

Give every confirmed finding a priority:

| Priority | Meaning | Examples |
|---|---|---|
| `p1` | It hurts a user today. | A flow that can't be finished. A screen that can't be used on a phone. Someone sees data that isn't theirs. A client gets a mail in the wrong language. |
| `p2` | A real gap that a user will run into. | Wrong data on a screen. A warning that doesn't show. A dead end with no way back. |
| `p3` | Polish. | Wording, layout details, a small thing that would be nice. |

## 5. File

- One issue per finding for `p1` and `p2`.
- One issue per screen or area for all its `p3` findings together.
- The issue has: the steps, what happened, what was expected, the cause as `file:line`, the screenshots, and the commit the stack ran.
- Write the issue's address back on the finding, so the next run finds it under "Known first".

## What you never do

- You never fix anything. You judge and file.
- You never dismiss a finding because it is small. Small is `p3`.
- You never confirm a finding because several walkers reported it. Five walkers can share one wrong idea.
