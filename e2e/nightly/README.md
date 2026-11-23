# The nightly run (sketch)

This is a sketch of the nightly run from [Keep your E2E tests, let an agent carry them](https://bjorntocode.com/posts/20261124_keep_your_e2e_tests): a scheduled job in which agents explore the app as personas, a separate agent judges what they found, and I get a short list in the morning. My own version is a set of scripts tied to my stack, so this folder describes the steps and the rules. It doesn't ship a job you can run as it is.

## How to use it

1. Get the replay from [the e2e folder](../README.md) working first. The nightly run starts by replaying the routes.
2. Do one walk by hand. Give an agent a browser, one persona from [../personas.md](../personas.md), one goal and the walker brief below. Read what comes back.
3. Judge that walk yourself with [judge-rules.md](judge-rules.md). You'll see how many findings are wrong, and why the judge has to exist before the walks are automated.
4. Let an agent do the judging with the same rules. Compare its verdicts with yours until you trust them.
5. Only then schedule the four steps below.

## The four steps

### 1. Focus

One agent reads the commits since the previous run and writes a focus list:

- which goals those commits touch;
- which screens changed;
- what in the commits might contradict a goal.

The focus list goes to every walker. A walker with a focus list looks at what changed. A walker without one wanders.

When the focus list shows a new feature that no goal covers, this step also drafts a goal for it. The draft goes into the report, and I decide what happens with it.

### 2. Walk

Each walk is one agent, one persona, one goal and one real browser.

- Walk the goals the commits touched.
- Add a few of the other goals, a different few each night, so every goal is explored at least once a week.
- Replay the saved routes first, on the same stack. A red route is a finding of its own, and it tells you the stack works before the walks start.
- Reset the seed data between the replay and the walks.

The walker gets this brief:

```markdown
You are <persona section from personas.md>.

<The lines every persona is told, from personas.md.>
<The test data sheet.>

Your task: reach this goal on the screen, then look around the screens it touched.
<The goal file.>
Sign in as your persona says, also when the goal names someone else. Where the
goal names a client you can't see, use one of your own.
Look closely at: <the focus list for this goal.>

Use the browser the way this person would. Save a screenshot after every step,
named NN-<short-step>.png. Stop after about 40 actions.

Answer with only this JSON:
{
  "reached": true or false,
  "summary": "<two sentences>",
  "steps": ["<what you did, one line per step>"],
  "findings": [{
    "title": "<what a user would say>",
    "kind": "bug | odd | wording | hard to use",
    "screen": "<where>",
    "screenshot": "<file name>",
    "steps": "<how to get there>",
    "actual": "<what happened>",
    "expected": "<what this person expected>"
  }]
}
```

The walker reports what a person would notice on the way: text that is unclear, a step that takes more clicks than it should, something slow, something that contradicts the goal.

### 3. Judge

A separate agent goes through every finding, with the code open. It follows [judge-rules.md](judge-rules.md). Its three main rules:

- it checks earlier verdicts and open issues first;
- it dismisses a finding only when a source says the behaviour is intended;
- it confirms a finding only when it finds the line of code that causes it.

### 4. Report

The judge files each confirmed finding as an issue, with the steps, the screenshot and the cause. What I read in the morning is one page per run:

- the replay result per goal;
- the confirmed findings, by priority, each with its issue;
- the dismissed findings with the source that dismissed them;
- deviations and draft goals that wait for my decision.

The last word is mine. When I close an issue as "not planned" with one sentence, the next night's judge reads that sentence and drops the finding.

## The order of a night

```text
focus     an agent reads the commits since the last run and writes focus.md
start     the test stack, with fresh seed data and no AI provider key
replay    the saved routes, without AI
reseed    back to clean seed data
walk      one agent per goal and persona, a few at a time
stop      the test stack
judge     one agent, with judge-rules.md, the code and the issue list
report    issues for confirmed findings, one page for the run
```

Keep everything a run produces in one folder per night: the focus list, the replay result, and per walk its screenshots and its JSON. The judge of a later night reads the verdicts of earlier nights from there.

## Costs to expect

- **Money.** A night costs me between $20 and $32. Almost all of it goes to the walks. The focus and judge steps are small next to them.
- **Usage limits.** My first nightly run hit the usage limit of my plan, because it ran while I was still working. It now starts at 02:00.
- **A real AI model in the test stack.** My test stack was calling a real model from inside the app until I removed the key. Start the stack without an AI provider key, so the app's own assistant runs on its local fake.
- **Runaway walks.** Give each walk a limit on actions (about 40) and a hard stop on time (30 minutes). Run a few walks at the same time, not all of them.
- **Your morning.** Without the judge, every finding lands on your desk. In one of my nights the judge dismissed 41 false positives before I saw them.

## What is still a sketch

- The scripts for the four steps are not in this repo.
- The test data sheet in the walker brief is a template in [../personas.md](../personas.md).
- The deviation report is a template in [../skills/journeys/SKILL.md](../skills/journeys/SKILL.md).
