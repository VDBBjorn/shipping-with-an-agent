# <Product name>: agent rules

<One sentence: what the product is and who uses it.> How to run and test it: `README.md`.

## Working

Every task that changes code starts with the `work` skill. It picks the playbook (feature, bug, refactor, ship) and holds the definition of done. Done means evidence from a run you watched, quoted in your reply.

A branch reaches main only through `scripts/ship.sh`, and only when the user says "ship".

## Map

- `web/`: the web app that customers use.
- `src/<Module>/`: one module each. `Contracts/` is the part other modules may use. The rest is private to the module.
- `tests/<Module>.Tests/`: the tests of one module. `tests/Shared/`: test helpers. `e2e/`: goals and their routes.
- `.claude/skills/`: how to do one kind of task: `tests`, `module`, `screen`, `verify`, `review`. Read the one that fits before you start.
- `docs/glossary.md`: the terms. Use them, and avoid the words each entry lists.
- `docs/decisions-log.md`: why things are as they are. Search it before you reopen a choice.
- `docs/seed-table.md`: the named test data, used by tests, screenshots and personas.
- Open work lives in the issue tracker and nowhere else.

## Rules that apply everywhere

- **Modules talk through contracts.** A module reads another module through its `Contracts/`, never through its tables.
- **Every string in both languages.** Text a user can see exists in each language the app supports.
- **English in code.** Names, routes, events and config keys are English. Other languages live only in translations.
- **New work ships behind a feature flag**, off until someone switches it on for a customer.
- **Test data has a name.** New data a feature needs goes into the seed and into the seed table, never only into one test.
- **A choice you make yourself goes in the decisions log**, marked "default, owner may overrule".
