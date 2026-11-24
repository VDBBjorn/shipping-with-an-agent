# The goal format

A goal is a short Markdown file that says who does what, and what counts as done. It is the part of an end-to-end test that I write myself, as described in [Keep your E2E tests, let an agent carry them](https://bjorntocode.com/posts/20261027_keep_your_e2e_tests). It has no selectors and no steps. The route next to it holds those, and an agent writes and repairs the route.

## How to use it

1. Create `<short-name>.md` in your goals folder. The file name is the goal's id.
2. Fill in the five parts below.
3. Read it back as someone who has never seen the app. If that person couldn't tell whether the goal was reached, rewrite the Pass lines.
4. Let an agent walk it and save the route as `<short-name>.route.mjs` in the same folder.

## The five parts

```markdown
# <What the user gets done, as a short sentence>

Sign in: <a named person from the seed data, or "none">
Start at: <a path, only when the goal doesn't start on the home screen>

<The goal in plain words. Two to five sentences. Who wants what, and what
happens on the way. No button names, no clicks.>

## Limits
- <What the walker may not use, or must do, to keep the walk honest.>

## Pass
- <One fact that must be true at the end. One per line.>
```

**The title** says what the user gets done. "A session gets invoiced and paid" is a title. "Invoice screen test" is a test name.

**Sign in** names a person from the seed data, such as `owner`. The runner knows how to sign that person in. `none` means the walk starts as a visitor without an account.

**The goal** describes intent. Write what the person wants and the order things happen in. Leave out how the screen does it. When a button gets a new name, the goal should still be true.

**Limits** keep the walk on the path a real user would take. Typical limits: start from the home screen, don't use the search box, don't type a URL.

**Pass** lists the facts that prove the goal was reached. Each line becomes one assertion in the route's `check()`.

## Rules for a good goal

- **A goal covers one flow from start to finish.** It ends where the user would say "done".
- **A Pass line states a fact, and someone other than the actor can see it.** "The mother received the invoice mail" is a fact. "The invoice screen works" is an opinion.
- **A Pass line only checks what this run did.** The route runs again tomorrow on the same seed data. "The invoice from this run is paid" still passes then. "There is one paid invoice" does not.
- **The goal doesn't change when the screen changes.** If you have to edit the goal after a redesign, it described the screen and not the intent.
- **I write the goal.** An agent may draft one for a feature that has none. I correct the intent and decide whether it joins the regression set, which is the small set of goals that must pass before a ship.

## The examples

- [example-invoice-paid.md](example-invoice-paid.md): an owner books, invoices and gets paid. Its route is [example-invoice-paid.route.mjs](example-invoice-paid.route.mjs).
- [example-book-online.md](example-book-online.md): a visitor without an account books a first appointment and confirms it by mail.
