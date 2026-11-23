## Why

<The problem, in two lines. What a user or a developer ran into, and what this change does about it.>

Closes <link to the issue>

## What changed

<One line per module or app, with the commit that did it.>

- **<Module>**: <what changed> (<commit>)
- **<Module>**: <what changed> (<commit>)

## Scope

<What this change leaves out on purpose, each with the issue it went into.>

- Not in this change: <what>. <link to the issue>

## Tradeoffs

<The choices that were made, and what each one costs. Name the decisions log ID where there is one.>

- <choice>: <what it costs>

## Blast radius

<What else could break, and the one fact that makes it safe.>

- Could affect: <the other screens, modules or data that use what changed>
- Safe because: <the fact: behind a feature flag that is off, covered by a test, read-only>

## Verification

<The commands with their output, the measurements, and the screenshots. Say what was not checked.>

- `<command>`: <the result, in one line>
- <where it was checked>: PASS / FAIL / INCONCLUSIVE, <what was seen>
- Not checked: <what, and why>

<The Markdown that scripts/evidence.sh printed.>
