import { expect } from '@playwright/test';

export const goal = 'example-invoice-paid';

export async function act(page, user) {
  await user.signIn(page, 'owner');

  await page.getByRole('link', { name: 'Calendar' }).click();
  await page.getByRole('button', { name: 'New appointment' }).click();
  await page.getByLabel('Client').fill('Milo');
  await page.getByRole('option', { name: 'Milo Carter' }).click();
  await page.getByRole('button', { name: 'Save' }).click();

  await page.getByRole('button', { name: /Milo Carter/ }).last().click();
  await page.getByRole('button', { name: 'Mark as attended' }).click();
  await page.getByRole('button', { name: 'Create invoice' }).click();

  const heading = await page.getByRole('heading', { name: /^Invoice \d+/ }).innerText();
  const invoice = heading.replace('Invoice ', '');

  await page.getByRole('button', { name: 'Send to Rosa Carter' }).click();
  await page.getByText('Invoice sent').waitFor();

  await page.getByRole('button', { name: 'Record payment' }).click();
  await page.getByLabel('Method').selectOption('Bank transfer');
  await page.getByRole('button', { name: 'Save payment' }).click();
  await page.getByText('Paid in full').waitFor();

  await user.signIn(page, 'rosa');
  await page.getByRole('link', { name: 'Invoices' }).click();

  return { invoice };
}

export async function check(page, ctx, picked) {
  const mails = await ctx.mailsTo('rosa', new RegExp(`Invoice ${picked.invoice}`));
  expect(mails, 'rosa received the invoice mail').toHaveLength(1);

  const invoice = await ctx.read(`/api/invoices/${picked.invoice}`);
  expect(invoice.openAmount, 'the invoice from this run is fully paid').toBe(0);

  const row = page.getByRole('row', { name: new RegExp(picked.invoice) });
  await expect(row, 'rosa sees that invoice as paid in the portal').toContainText('Paid');
}
