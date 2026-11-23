#!/usr/bin/env node
import { execFileSync } from 'node:child_process';
import { readFileSync } from 'node:fs';

const { tool_input: call = {}, cwd = '.' } = JSON.parse(readFileSync(0, 'utf8'));

const targetsMain = refspec => /(^|:)\+?(refs\/heads\/)?main$/.test(refspec);
const meansCurrentBranch = refspec => refspec === 'HEAD' || refspec === '@';

function currentBranch(folder) {
  try {
    return execFileSync('git', ['-C', folder, 'branch', '--show-current'], { encoding: 'utf8' }).trim();
  } catch {
    return '';
  }
}

function pushesToMain(command) {
  const words = command.trim().split(/\s+/).map(word => word.replace(/^['"]|['"]$/g, ''));
  while (/^\w+=/.test(words[0] ?? '')) words.shift();
  if (words[0] !== 'git') return false;

  let folder = cwd;
  let at = 1;
  while (words[at]?.startsWith('-')) {
    if (words[at] === '-C') folder = words[++at];
    if (words[at] === '-c') at++;
    at++;
  }
  if (words[at] !== 'push') return false;

  const options = words.slice(at + 1).filter(word => word.startsWith('-'));
  if (options.includes('--all') || options.includes('--mirror')) return true;

  const [, ...refspecs] = words.slice(at + 1).filter(word => !word.startsWith('-'));
  const onMain = () => currentBranch(folder) === 'main';
  if (!refspecs.length) return onMain();
  return refspecs.some(refspec => targetsMain(refspec) || (meansCurrentBranch(refspec) && onMain()));
}

const commands = (call.command ?? '').split(/&&|\|\||[;|\n]/);

if (commands.some(pushesToMain)) {
  console.error('no-push-main: main only moves through scripts/ship.sh. Run that script when the user asks to ship.');
  process.exit(2);
}
