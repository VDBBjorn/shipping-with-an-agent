# Shipping with an agent

The skills, hooks, scripts and templates I use to build and ship software with an AI coding agent. They go with my blog series "Shipping with an agent", which starts with [Keep your E2E tests, let an agent carry them](https://bjorntocode.com/posts/20261124_keep_your_e2e_tests). The series has five posts, and each post has a folder here with the files it describes.

The files are small and meant to be changed. Take one, put in your own commands, and delete the rules you don't agree with.

## How to use it

1. **Get the skills.** A skill is a Markdown file with instructions for one kind of task. Pick one of these two ways. If you take both, you have every skill twice.

   As a Claude Code plugin. You get all four skills, and you can't edit them:

   ```bash
   claude plugin install shipping-with-an-agent --marketplace VDBBjorn/shipping-with-an-agent
   ```

   Or as files you own. Copy a skill folder to `.claude/skills/` in your repo:

   ```bash
   git clone https://github.com/VDBBjorn/shipping-with-an-agent
   cp -r shipping-with-an-agent/evidence/skills/work <your repo>/.claude/skills/
   ```

2. **Give the skills your project's values.** A skill asks for a few things in `<angle brackets>`: the start command, a local URL, where the glossary is. In copied files, replace them in the skill. With the plugin, write them in your rules file (`AGENTS.md` or `CLAUDE.md`). The skill looks there and asks you for what is missing.
3. **Copy the hooks, scripts and templates you want.** They aren't in the plugin, because each one has to be changed to fit your repo.
   - a hook goes to `.claude/hooks/`, and is registered in `.claude/settings.json`
   - a script goes to `scripts/`
   - a template goes wherever your repo keeps that kind of document
4. **Start with one file.** Each folder's README says which one I'd pick first.

## Why these files exist

An agent writes most of the code in my side project. Each post is about one thing that got harder because of that, and what I did about it.

### 1. I no longer know what to click through

**The problem.** When I wrote the code myself, I knew which screens I had touched. When an agent writes it, I don't. Checking a change end to end got harder, and every red end-to-end test cost me time to find out whether it was a real bug or a flaky test.

**The fix.** I write what a test has to prove as a goal, in plain words. The agent writes the Playwright script for that goal, and repairs the script when a screen changes. The scripts replay without any AI.

- [The goal format](e2e/goals/README.md), with [an example goal](e2e/goals/example-invoice-paid.md) and [its script](e2e/goals/example-invoice-paid.route.mjs)
- [`journeys`](e2e/skills/journeys/SKILL.md), the skill for replaying and repairing

Post: [Keep your E2E tests, let an agent carry them](https://bjorntocode.com/posts/20261124_keep_your_e2e_tests). Folder: [e2e](e2e/README.md).

### 2. The agent reviews its own work

**The problem.** Asking an agent to check its work at the end of a long session is like reviewing your own pull request. It knows what it meant to write, so that is what it reads.

**The fix.** Two agents that didn't write the change review it. One asks whether it does what was asked, the other whether it follows the rules. A finding that shows up twice becomes a check that runs on its own.

- [`review`](review/skills/review/SKILL.md), the skill that briefs the two reviewers and gives the verdict
- [`guard.mjs`](review/hooks/guard.mjs), a hook that refuses an edit when it breaks a rule

Post: [A review that learns from its own findings](https://bjorntocode.com/posts/20261201_review_that_learns). Folder: [review](review/README.md).

### 3. "Done" means the tests pass

**The problem.** When an agent says a change is done, it usually means that the code compiles and that the tests it wrote pass. Neither tells me the change works.

**The fix.** Every task ends with the same four checks, and the agent's last message shows each one with evidence: a command and its output, a screenshot, or a value read back from the system. When a check can't run, the agent says "inconclusive".

- [`work`](evidence/skills/work/SKILL.md), the skill every code change starts with
- [`verify`](evidence/skills/verify/SKILL.md), the skill that says where to check each kind of change

Post: [Evidence or it didn't happen](https://bjorntocode.com/posts/20261208_evidence_or_it_didnt_happen). Folder: [evidence](evidence/README.md).

### 4. The agent doesn't know its way around

**The problem.** Which module owns what, what a word means in this product, what was decided last month: all of that used to live in my head. The agent can't read it there.

**The fix.** A rules file of under 40 lines that points to everything else: the skills, a glossary, a decisions log and test data with names.

- [`AGENTS.md`](map/AGENTS.md), the rules file as a template
- The formats for [a glossary](map/glossary.example.md), [a decisions log](map/decisions-log.example.md) and [a seed table](map/seed-table.example.md)

Post: [Your agent needs a map, not a manual](https://bjorntocode.com/posts/20261215_your_agent_needs_a_map). Folder: [map](map/README.md).

### 5. The pull request has one job left

**The problem.** A pull request usually does two jobs: people review the change there, and CI checks it there. In my setup both are done before a pull request exists.

**The fix.** One script is the only way to main. It runs the checks on my own machine, and only then pushes. The pull request it opens is the record of what changed, why, and how it was checked.

- [`ship.sh`](shipping/scripts/ship.sh), the script
- [`pr-template.md`](shipping/pr-template.md), the shape of the description

Post: [Pull requests as receipts](https://bjorntocode.com/posts/20261222_pull_requests_as_receipts). Folder: [shipping](shipping/README.md).

## Reference

### Skills

These four are in the plugin.

- **[work](evidence/skills/work/SKILL.md)**: Start here for every task that changes code. Picks the playbook and holds the definition of done. Comes with a [bug playbook](evidence/skills/work/bug.md) and a [feature playbook](evidence/skills/work/feature.md).
- **[verify](evidence/skills/verify/SKILL.md)**: Prove that a change works in the place a user would notice it, and say "inconclusive" when a check can't run.
- **[review](review/skills/review/SKILL.md)**: Let two fresh agents review a finished change, judge their findings, and turn a repeated finding into an automatic check.
- **[journeys](e2e/skills/journeys/SKILL.md)**: Replay the saved end-to-end routes, repair one that lost its way, or add a new goal.

### Hooks

A hook is a small script that runs before the agent uses a tool, and can refuse the call.

- **[guard.mjs](review/hooks/guard.mjs)**: Checks every edit against a list of rules before it lands.
- **[no-push-main.mjs](shipping/hooks/no-push-main.mjs)**: Refuses the agent's own pushes to main.
- **[settings.example.json](review/hooks/settings.example.json)**: How both hooks are registered.

### Scripts

- **[ship.sh](shipping/scripts/ship.sh)**: Rebase, select the checks, run them, push the branch, open the pull request, fast-forward main, sign off.
- **[select-checks.sh](shipping/scripts/select-checks.sh)**: Reads the changed files and prints which checks to run. Anything it doesn't know runs everything.
- **[evidence.sh](evidence/scripts/evidence.sh)**: Pushes screenshots and videos to a branch called `evidence` and prints the Markdown for the pull request.

### Templates and formats

- **[AGENTS.md](map/AGENTS.md)**: A rules file of pointers: one instruction for every task, a map, and a few rules that apply everywhere.
- **[glossary.example.md](map/glossary.example.md)**: One name per concept, each with the words to avoid.
- **[decisions-log.example.md](map/decisions-log.example.md)**: Choices and their reasons, each with an ID to search for.
- **[seed-table.example.md](map/seed-table.example.md)**: Named test data in one table.
- **[goals/README.md](e2e/goals/README.md)**: The goal format: who signs in, the goal in plain words, Limits, Pass.
- **[personas.md](e2e/personas.md)**: The persona format, three personas and a template for the test data sheet.
- **[pr-template.md](shipping/pr-template.md)**: Why, What changed, Scope, Tradeoffs, Blast radius, Verification.

### Sketches

Where a post says I'm still adding something, the file here is a sketch and says so.

- **[nightly/README.md](e2e/nightly/README.md)**: The nightly run: focus, walk, judge, report. With [the judge's rules](e2e/nightly/judge-rules.md).
- **[The regression gate](shipping/README.md#sketch-the-regression-gate)**: Replaying the key routes on every ship.

## What to expect

- **The skills and hooks are written for Claude Code.** The skills are plain Markdown, so they also work as instructions for another agent.
- **The examples use one stack.** Tests are .NET with xUnit, end-to-end scripts are Playwright, and the scripts are bash and Node. The ideas don't depend on that stack. The commands do, so change them.
- **The examples use an invented app.** It's a small app for a practice that books appointments for clients and sends invoices. The people and the data in it are made up.

## Licence

MIT. See [LICENSE](LICENSE).
