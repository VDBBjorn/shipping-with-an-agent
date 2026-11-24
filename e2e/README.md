# e2e: goals, routes, personas and the nightly run

This folder goes with the post [Keep your E2E tests, let an agent carry them](https://bjorntocode.com/posts/20261027_keep_your_e2e_tests). It holds the format I use to describe an end-to-end test as a goal, two example goals, a Playwright script for one of them, the personas that explore the app at night, and the skill that tells an agent how to replay and repair the scripts.

## How to use it

1. Read [goals/README.md](goals/README.md) and write one goal for the flow you can least afford to break. Use [goals/example-invoice-paid.md](goals/example-invoice-paid.md) as a model.
2. Let an agent walk that goal in a real browser and save what it did as a route. A route is a Playwright script with two functions: `act()` does what the user does, `check()` proves the goal's pass lines. [goals/example-invoice-paid.route.mjs](goals/example-invoice-paid.route.mjs) shows the shape.
3. Write a small runner that replays the routes without any AI. The section "What the runner does" below lists what it needs.
4. Copy [skills/journeys/SKILL.md](skills/journeys/SKILL.md) to `.claude/skills/journeys/SKILL.md` and fill in your commands. From then on the agent can replay the routes and repair one that lost its way.
5. Only when the replay is stable, look at [personas.md](personas.md) and [nightly/README.md](nightly/README.md) for the exploring part. Build the judge ([nightly/judge-rules.md](nightly/judge-rules.md)) before you automate the walking.

If you take one file, take [goals/README.md](goals/README.md). A goal is useful on day one, even if a person walks it by hand.

## What's in the folder

| File | What it is |
|---|---|
| [goals/README.md](goals/README.md) | The goal format: who signs in, the goal in plain words, Limits, Pass. |
| [goals/example-invoice-paid.md](goals/example-invoice-paid.md) | A goal for a flow that brings in money. |
| [goals/example-book-online.md](goals/example-book-online.md) | A goal for a visitor who has no account. |
| [goals/example-invoice-paid.route.mjs](goals/example-invoice-paid.route.mjs) | The route for the first goal. |
| [personas.md](personas.md) | The persona format, three personas and a template for the test data sheet. |
| [skills/journeys/SKILL.md](skills/journeys/SKILL.md) | The skill: run the replay, repair a route, the rules for a repair, a new goal. |
| [nightly/README.md](nightly/README.md) | A sketch of the nightly run: focus, walk, judge, report. |
| [nightly/judge-rules.md](nightly/judge-rules.md) | The rules for the agent that judges the findings. |

## What the runner does

The runner is the script that replays the routes. Mine is about 200 lines of Node and tied to my own stack, so it isn't in this repo. This is what it does, and what the example route expects from it.

For each goal that has a route:

1. Open a fresh browser context and record a video.
2. Call `act(page, user)`. The `user` helper has one job: `user.signIn(page, name)` signs in a named person from the seed data and lands on that person's home screen. `act()` returns the things it picked or created, such as an invoice number.
3. Call `check(page, ctx, picked)`. The `ctx` helper reads what the stack did: `ctx.mailsTo(name, subject)` reads the local test mailbox, `ctx.read(path)` reads a value from the app's API.
4. Save `pass.png`, or on a failure `fail.png` and a text dump of the page's accessibility tree. An agent that repairs the route reads both.

Before a replay, the runner lints `act()`. It refuses a route whose `act()` navigates by URL or uses anything other than `getByRole`, `getByLabel`, `getByText` and `getByPlaceholder`. A route that needs a CSS selector to get through the screen has found something a user can't name either.

The runner reports one status per goal:

| Status | Meaning |
|---|---|
| `PASS` | The route replayed and every check passed. |
| `FAIL` | The route got stuck or a check failed. |
| `NEW ROUTE` | The goal had no route. An agent walked it and saved one. |
| `FLOW CHANGED` | An agent repaired `act()` and the route passes again. I read the diff. |
| `CHECK CHANGED` | A repair touched something outside `act()`. It is rejected and the goal stays red. |

## What is a sketch here

The post describes three parts I'm still adding. They are in this folder as templates, and each one says so where it appears:

- **The regression gate.** The post's plan is that the routes for the key flows replay on every ship and before every deploy, and that the gate never repairs anything. Today I run the replay by hand before I ship a change to a screen. The sketch of the gate is in [../shipping/README.md](../shipping/README.md).
- **The deviation report.** A repair that changes the flow should wait for my yes, with the diff and both sets of screenshots. The template is in [skills/journeys/SKILL.md](skills/journeys/SKILL.md).
- **The test data sheet.** A short sheet that tells a persona which oddities in the seed data are on purpose. The template is in [personas.md](personas.md).
