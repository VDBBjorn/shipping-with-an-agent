# Seed table (example)

This is the table that describes the named test data, filled in for the invented example app. Replace the rows with your own and keep the columns.

## The format

One row per named item. The key is how tests, screenshots, goals and personas refer to it.

```markdown
| Key | What it is | Why it is there |
|---|---|---|
| <key> | <who or what, with the facts a test may rely on> | <which situation it exists to show> |
```

Rules for the table:

- A key is one lower-case word. Tests say "milo's appointment", and anyone can look up what that means.
- A row lists only facts that tests may rely on. If a fact isn't in the row, a test doesn't depend on it.
- Dates are relative to the day the seed runs: "today at 16:00", "30 days overdue". The seed works out the real dates.
- New data a feature needs goes into the seed and into this table in the same commit. Never only into one test.
- Email addresses end in `example.test`, so no mail can reach a real person.

## People who sign in

| Key | What it is | Why it is there |
|---|---|---|
| `owner` | Dana Whitfield, owner of the practice. Sees every client and every invoice. `dana@example.test` | The default login for goals about the practice. |
| `colleague` | Tomas Reyes, an employee. Sees only his own clients. Uses the app in its second language. `tomas@example.test` | Shows what an employee may and may not see, and every screen in the second language. |
| `rosa` | Rosa Carter, contact for `milo` (his mother). Signs in to the portal and receives his invoices. `rosa@example.test` | The login for goals about the portal and about mail to a contact. |

## Clients

| Key | What it is | Why it is there |
|---|---|---|
| `milo` | Milo Carter, a client of `owner`. Has an appointment today at 16:00, and `rosa` as his contact. | The client for goals that go from an appointment to a paid invoice. |
| `priya` | Priya Nair, a client of `owner`. Has one sent invoice that is 30 days overdue. `priya@example.test` | Shows reminders and the "overdue" state on every list. |
| `ellen` | Ellen Brooks, a client of `colleague`. Has no email address and no appointments. | Shows empty screens, and what the app does when it can't send a mail. |

## What a reset does

The seed can run again at any time. It puts every row above back in the state the table describes and removes what tests added: appointments, invoices and mail in the local test mailbox.
