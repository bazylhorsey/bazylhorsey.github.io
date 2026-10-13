// Headless check that the portfolio actually works, the same way a server
// component would run it: no DOM, no browser, just the program.
//
//   ./build.sh && node run.mjs
//
// It mounts the view, works out the path of each filter button the way the
// browser patcher does, fires a click at it, and then reads the patches Jorn
// sends back. If a path is wrong or the diff is wrong, this says so instead of
// the page quietly doing nothing.

import { createRequire } from "node:module";

const require = createRequire(import.meta.url);
const { Elm } = require("./build/build/main.js");

const app = Elm.Main.init();

const tick = () => new Promise((resolve) => setTimeout(resolve, 10));

let mounted = null;
let lastPatches = [];
let problems = 0;

app.ports.toClient.subscribe((message) => {
  if (message.mount) mounted = message.mount;
  else if (message.patches) lastPatches = message.patches;
  else if (message.error) {
    console.error("  FAIL app reported:", message.error);
    problems++;
  }
});

await tick();

if (!mounted) {
  console.error("nothing mounted");
  process.exit(1);
}

function textOf(node) {
  if (typeof node.text === "string") return node.text;
  return (node.children || []).map(textOf).join("");
}

// Walk the encoded tree the way client/jorn.js walks the DOM: indices into
// childNodes, text nodes included, starting at the root node itself.
function pathTo(predicate, node = mounted, path = []) {
  if (predicate(node)) return path;
  for (const [i, child] of (node.children || []).entries()) {
    const found = pathTo(predicate, child, [...path, i]);
    if (found) return found;
  }
  return null;
}

function nodeAt(path) {
  let node = mounted;
  for (const i of path) node = (node.children || [])[i];
  return node;
}

const filterButton = (text) => (node) =>
  node.tag === "button" && (node.children || []).some((c) => c.text === text);

console.log("mounted ok");
console.log(`  ${textOf(mounted).length} characters of text on the page`);

const steps = ["upstream", "tools", "everything", "experiments"];

for (const label of steps) {
  const path = pathTo(filterButton(label));
  if (!path) {
    console.error(`  FAIL no button labelled "${label}" in the mounted tree`);
    problems++;
    continue;
  }

  lastPatches = [];
  app.ports.fromClient.send({ path, name: "click", event: {} });
  await tick();

  // Which button did the patches mark active?
  const nowActive = lastPatches
    .filter(
      (p) => p.op === "set-attr" && p.name === "class" && /is-on/.test(p.value)
    )
    .map((p) => textOf(nodeAt(p.path)));

  const listChanged = lastPatches.some(
    (p) => p.op === "truncate" || p.op === "append"
  );

  const ok = nowActive.length === 1 && nowActive[0] === label;
  if (!ok) problems++;

  console.log(
    `  ${ok ? "ok  " : "FAIL"} click "${label}" at [${path}] ` +
      `-> ${String(lastPatches.length).padStart(2)} patches, ` +
      `active: ${nowActive.join(", ") || "none"}, ` +
      `work list ${listChanged ? "re-rendered" : "unchanged"}`
  );
}

// Re-selecting the current filter should be a no-op: nothing changed, so
// there is nothing to send.
lastPatches = [];
app.ports.fromClient.send({
  path: pathTo(filterButton("experiments")),
  name: "click",
  event: {},
});
await tick();

const quiet = lastPatches.length === 0;
if (!quiet) problems++;
console.log(
  `  ${quiet ? "ok  " : "FAIL"} clicking the active filter again -> ` +
    `${lastPatches.length} patches`
);

// The theme toggle is different: it patches a class on the root node itself,
// which every other selector on the page hangs off.
const themeButton = pathTo(
  (node) => node.tag === "button" && /^(night|day)$/.test(textOf(node))
);

if (!themeButton) {
  console.error("  FAIL no theme toggle in the mounted tree");
  problems++;
} else {
  const before = (mounted.attrs || {}).class;
  lastPatches = [];
  app.ports.fromClient.send({ path: themeButton, name: "click", event: {} });
  await tick();

  const rootPatch = lastPatches.find(
    (p) => p.op === "set-attr" && p.name === "class" && p.path.length === 0
  );
  const flipped = rootPatch && rootPatch.value !== before;
  if (!flipped) problems++;

  console.log(
    `  ${flipped ? "ok  " : "FAIL"} theme toggle at [${themeButton}] -> root class ` +
      `"${before}" became "${rootPatch ? rootPatch.value : "unchanged"}"`
  );
}

console.log(problems ? `\n${problems} check(s) failed` : "\nall checks passed");
process.exit(problems ? 1 : 0);