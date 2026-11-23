#!/usr/bin/env node
import { existsSync, readFileSync } from 'node:fs';

const { tool_input: edit = {} } = JSON.parse(readFileSync(0, 'utf8'));
const path = edit.file_path ?? '';

const changes = [
  [edit.content, edit.content !== undefined && existsSync(path) ? readFileSync(path, 'utf8') : ''],
  [edit.new_string, edit.old_string],
  ...(edit.edits ?? []).map(e => [e.new_string, e.old_string]),
].filter(([after]) => after);

const addedLines = changes.flatMap(([after, before]) => {
  const linesBefore = new Set((before ?? '').split('\n'));
  return after.split('\n').filter(line => !linesBefore.has(line));
});

const isCs = path.endsWith('.cs');
const generated = /\/Migrations\/|\.Designer\.cs$|\.g\.cs$/.test(path);
const inTests = isCs && /(^|\/)tests?\/|Tests?\.cs$/.test(path);
const inBrowserTests = /\.(spec|test)\.[cm]?[jt]sx?$/.test(path);
const isProjectFile = path.endsWith('.csproj');

const rules = [
  [inTests, /\bTask\.Delay\(|\bThread\.Sleep\(/,
    'A fixed delay in a test: wait on the condition instead.'],
  [inTests, /\[(Fact|Theory)\([^)]*\bSkip\s*=/,
    'A skipped test: fix it or delete it.'],
  [isCs && !generated, /#pragma\s+warning\s+disable/,
    'A suppressed warning: fix the cause.'],
  [inBrowserTests, /\bwaitForTimeout\(/,
    'A fixed delay in a browser test: wait on what the user would see instead.'],
  [inBrowserTests, /\b(test|it|describe)\.(skip|only)\(/,
    'A skipped or focused test: fix it, delete it, or remove the focus.'],
  [isProjectFile, /Reference\s+Include="[^"]+"\s+Version=/,
    'A dependency version in a project file: set it in the central versions file.'],
  [isCs && !generated, /^\s*\/\/(?!\/)/,
    'A code comment: say it in a name or a test. A reason goes in the decisions log.'],
];

const problems = rules
  .filter(([applies, pattern]) => applies && addedLines.some(line => pattern.test(line)))
  .map(([, , message]) => message);

if (isCs && /catch\s*(\([^)]*\))?\s*\{\s*\}/.test(addedLines.join('\n'))) {
  problems.push('An empty catch block: handle the error or let it through.');
}

if (problems.length) {
  console.error(`guard: ${path}\n- ${problems.join('\n- ')}`);
  process.exit(2);
}
