---
name: journeys
description: Replay the saved end-to-end routes, repair a route that lost its way, or add a new goal. Use when a change touches a screen, when a replay is red, before a ship, or when the user asks for a new goal.
---

# Journeys

A **goal** is a Markdown file in `<goals folder>` that says who does what and what counts as done. A **route** is the Playwright script next to it: `act()` does what the user does, `check()` proves the goal's Pass lines. The goal format is in `<goals folder>/README.md`.

The replay runs the routes as plain scripts, without any AI. You come in when a replay is red or a goal has no route yet.

A value in `<angle brackets>` that names a command, a folder or a URL belongs to the project. If it is still in brackets here, look it up in the project's rules file, and ask the user for one that is missing.

## Run the replay

1. Start the test stack with fresh seed data and without an AI provider key: `<start command>`. Without a key the app's assistant runs on its local fake, so a replay costs nothing and gives the same answer every time.
2. Replay every route with `<replay command>`, or one with `<replay command> <goal>`.
3. Report one line per goal: the goal, its status (`PASS`, `FAIL`, `NEW ROUTE`, `FLOW CHANGED`, `CHECK CHANGED`) and how long it took.
4. For every `FAIL`, look at the failure before you report it. Read the error, `fail.png` and the page dump. Then put it in one of three buckets:
   - **A real bug.** The screen does the wrong thing, or a Pass line is false. Leave the route as it is. Report it with the screenshot and the step it failed on.
   - **A flake.** The same route passes when you replay it and nothing changed in between. Report it as a flake and name the step that was slow or unstable, so it can be counted.
   - **The route lost its way.** The screen still lets a user reach the goal, but a button was renamed or a step moved. Repair the route (next section).

Replay twice before you call something a flake. Call it a bug only after you looked at the screenshot.

## Repair a route

1. Read the goal file, the failing route, the error, `fail.png` and the page dump.
2. Walk the goal in a real browser until you know how a user reaches it now.
3. Change `act()` in the route to follow that path.
4. Replay with `<replay command> <goal>` until it is `PASS` twice in a row.
5. Report what changed, as described under "After a repair".

## The rules for a repair

- A repair may change how the goal is reached. It may never change what counts as reaching it.
- Change only `act()`. A repair that touches `check()`, the goal file or the values `act()` returns is rejected, and the goal stays red.
- In `act()`, find things the way a user would name them: `getByRole`, `getByLabel`, `getByText`, `getByPlaceholder`. No navigation by URL, no CSS selectors, no test ids, no calls to the API.
- No fixed waits. Wait for something the user would see.
- Stay inside the goal's Limits.
- If a user can no longer reach the goal through the screen, there is nothing to repair. Answer `REGRESSION: <what is in the way>` and leave the route alone. A goal that can't be reached is a bug in the app.
- Never repair as part of a ship or a deploy. A red replay there stops the ship. Repairs happen before it, where the user can see them.

## After a repair

Compare the old and the new `act()`:

- **Only names changed.** A button, label or link has new text and the steps are the same. Commit the route with a message that names the old and the new text.
- **The flow changed.** A step was added, removed or moved, or the route goes through another screen. This is a deviation. Don't commit it. Report it and wait for the user's yes.

### Deviation report (template)

This report is a template. Use it in your reply until the project has its own place for deviations.

```markdown
## Deviation: <goal>

**What changed in the flow:** <one sentence, in the user's words>
**Why the old route failed:** <the step and what the screen showed>

**Before:** <path to the last passing screenshots>
**After:** <path to the screenshots of the repaired route>

**Diff of act():**
<the diff>

Waiting for: yes (commit the repaired route) or no (this is a regression).
```

## A new goal

1. Write the goal only when the user asked for it, or as a draft when a feature has no goal. A draft is marked as a draft, and the user corrects the intent.
2. A goal covers one flow from start to finish, for something the business can't do without.
3. Every Pass line is a fact that the route can check, and it only checks what this run did. The route must pass again tomorrow on the same seed data.
4. Walk the goal in a real browser, write the route, and replay it until it is `PASS` twice in a row.
5. Report the goal and the route as new files. The user decides whether the goal joins the regression set.
