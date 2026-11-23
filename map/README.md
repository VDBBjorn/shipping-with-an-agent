# map: a short rules file and the documents it points to

This folder goes with the post [Your agent needs a map, not a manual](https://bjorntocode.com/posts/20261215_your_agent_needs_a_map). It holds a template for the rules file an agent reads at the start of every session, and example formats for the three documents that file points to: a glossary, a decisions log and a table of named test data.

## How to use it

1. Copy [AGENTS.md](AGENTS.md) to the root of your repo and fill in the `<angle brackets>`. Change the map section until every path in it exists in your repo.
2. Go through your current rules file line by line, and move each line to where it belongs (see "Where a line belongs" below). What is left goes into the new file.
3. Start a glossary from [glossary.example.md](glossary.example.md). Begin with the five words your agent mixes up most, each with an avoid line.
4. Start a decisions log from [decisions-log.example.md](decisions-log.example.md). Write the first entry for the last choice you had to explain twice.
5. Describe your test data in a table like [seed-table.example.md](seed-table.example.md). Give everything a test relies on a name.
6. Put the three documents where the map section says they are. In the template that is `docs/`.

If you take one file, take [glossary.example.md](glossary.example.md). A glossary is the cheapest of the four, and it shows up in the code, on the screens and in every conversation with the agent.

## What's in the folder

| File | What it is |
|---|---|
| [AGENTS.md](AGENTS.md) | A rules file of pointers: one instruction for every task, a map, and a few rules that apply everywhere. It is under 40 lines. |
| [glossary.example.md](glossary.example.md) | The entry format with `_Avoid_` lines, and three terms. |
| [decisions-log.example.md](decisions-log.example.md) | The entry format with date-and-name IDs, and four entries. One is a "default, owner may overrule" entry and one replaces an earlier entry. |
| [seed-table.example.md](seed-table.example.md) | Named test data in one table, used by tests, screenshots and personas. |

## The rules file

`AGENTS.md` is the file name many coding agents read on their own. Claude Code reads `CLAUDE.md`. I keep one file and let the other point to it: my `CLAUDE.md` holds the single line `@AGENTS.md`.

The template holds three things, like the file in the post:

- **One instruction for every task**: start with the `work` skill. That skill is in [../evidence/skills/work/SKILL.md](../evidence/skills/work/SKILL.md).
- **A map**: where the apps, the modules, the tests and the documents live.
- **A few rules that apply everywhere.** The template has six. Three are the ones the post names: modules talk through their public contracts, every string exists in both languages, and new work ships behind a feature flag.

It doesn't say how to do anything. How to write a test, a screen or a module goes into a skill: a Markdown file in `.claude/skills/<name>/` that the agent reads when a task needs it. The skills from this series are in the other folders of this repo. The template also names `tests`, `module` and `screen` skills. Those hold the patterns of one codebase, so you write them yourself.

## Where a line belongs

Before a line goes into the rules file, ask where it really belongs:

| The line is about | It goes in |
|---|---|
| How to do one kind of task | A skill. |
| Something that can be checked automatically | A check, such as the hook in [../review/hooks/guard.mjs](../review/hooks/guard.mjs). |
| What a word means | The glossary. |
| A choice and its reason | The decisions log. |

What is left after that is usually nothing.

## How the three documents are used

- **The glossary** gives one name per concept. The agent uses the term in class names, routes, test names and on screen. The second reviewer in [../review/skills/review/SKILL.md](../review/skills/review/SKILL.md) reads the glossary and checks the diff against it.
- **The decisions log** is searched, not read. The rules file tells the agent to search it before reopening a choice. The agent also writes entries: a choice it made itself is logged as "default, owner may overrule", so I can find those entries with one search.
- **The seed table** gives the test data names. A test, a screenshot, a goal in [../e2e/goals](../e2e/goals/README.md) and a persona in [../e2e/personas.md](../e2e/personas.md) all say `milo` and mean the same client.

## What to expect from the decisions log

The post lists what is wrong with the log: it grows fast, later entries replace earlier ones, and nobody reads it front to back. It works because the agent searches it.

Two habits keep it usable for me:

- An entry is never rewritten. A new entry replaces it and names the old ID. The example file shows one.
- A search for an ID has to find every place that refers to it. So an ID is written the same way everywhere, in backticks.

Folding settled entries into the glossary or into a longer decision record is something I still want to do. This folder has no tool for it.

## The names in the examples

The people in these files belong to the invented example app this repo uses, so their names differ from the two the post mentions. Here `milo` has the appointment today at 16:00, and `priya` has the overdue invoice. The IDs in the example log are invented too.
