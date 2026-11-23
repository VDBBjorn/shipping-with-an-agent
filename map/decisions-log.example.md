# Decisions log (example)

This is the entry format, with four entries from the invented example app. Replace the entries with your own and keep the format.

## The format

```markdown
**<date>-<short-name>.** <What was chosen, in one sentence.> <Why, in one or two
sentences: what it prevents or what it costs.> <Where it shows up in the code,
if that helps someone find it.>
```

Rules for an entry:

- The ID is the date of the choice and a short name, in lower case with dashes: `2026-03-14-tests-without-ai-key`. Code review, issues and other entries refer to a choice by its ID.
- An entry says what was chosen and why. How it was built is in the code.
- A choice the agent made without asking starts with **Default, owner may overrule.** The owner can then find those entries with one search and change them.
- An entry is never edited to say something else. A later entry replaces it and names the ID it replaces.
- New entries go at the bottom.

## Entries

**2026-03-14-tests-without-ai-key.** Test stacks start without an AI provider key, so the app's assistant runs on a local fake. A test run that calls a real model costs money, is slow, and gives a different answer each time. The start script for the test stack leaves the key out. Don't add it back to make a test pass.

**2026-03-21-reminder-two-days-before.** Default, owner may overrule. The reminder mail for an appointment goes out two days before it, at 09:00. The issue asked for "a reminder in time" and gave no number. Two days leaves a client time to move the appointment. The number is one setting in the Calendar module.

**2026-04-02-invoice-number-at-send.** An invoice gets its number when it is sent, not when it is created. A draft that is thrown away would leave a gap in the numbers, and the bookkeeper needs numbers that follow each other without gaps. Drafts show "Draft" where the number will be.

**2026-04-18-reminder-three-days-before.** Replaces `2026-03-21-reminder-two-days-before`. The owner chose three days: clients asked for more time to find another day. Still 09:00.
