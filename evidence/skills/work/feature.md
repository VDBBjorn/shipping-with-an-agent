# Playbook: a feature

A feature is built in thin slices behind a feature flag. A slice is the smallest piece that a user could notice. A feature flag is a switch that turns the new behaviour on for one customer at a time, and it is off until someone turns it on.

## 1. Get the facts first

Before you ask the user anything, read:

- the issue;
- the glossary, for the terms the issue uses;
- the decisions log, searched for those terms;
- the code and the screens the feature will touch.

A question the repo can answer is not a question for the user.

## 2. Ask what is still open

Put the open questions in one numbered list. Give each one the answer you recommend and the reason, so the user can reply with "yes to all" or "2: no".

## 3. Write the intent and a goal

Write both into the issue before you write code.

- **The intent**: who this is for, what they can do afterwards, and what is left out on purpose. Five lines at most.
- **A goal**: the same thing as a test in plain words. Who signs in, what they want to reach, and the lines that prove they reached it. The format is in the `journeys` skill, if your project has one.

The goal is what the feature is checked against at the end. Writing it first stops the feature from growing while you build it.

## 4. Name the flag

Pick a name for the feature flag and add it where your project keeps its flags. From here on, everything new is behind it: the screens, the commands and the background jobs.

With the flag off, the app behaves exactly as it did before. That is a line you will have to prove in step 7.

## 5. Build one slice at a time

For each slice, in this order:

1. Write a test for the slice.
2. Run it and watch it fail, for the reason you expect.
3. Write the code that makes it pass.
4. Run the tests of the module.
5. If the slice needs new test data, add it to the seed and to the seed table. Never only to one test.
6. Commit. One slice, one commit, with a message that says what changed and why.

If a slice takes more than one commit to explain, it was two slices.

## 6. Run the full checks

Run every test of the modules you touched, and of the modules that depend on them. Fix what fails before you go on.

## 7. Verify

Use the `verify` skill, with the goal from step 3 as the list of what to check.

- Check with the flag **on**: every pass line of the goal, where a user would see it.
- Check with the flag **off**: the new behaviour is not reachable, on the screen or through the API.
- Check in every language the app supports.

## 8. Review

Run the `review` skill on the final commit. A fix after the review means a new review.

## 9. Close out

- New terms go into the glossary, with their avoid line.
- Choices someone could question go into the decisions log.
- The issue gets what is left: the slices you didn't build, and a separate issue for removing the flag once the feature is on for everyone.

Your last message follows the done-contract in [SKILL.md](SKILL.md).
