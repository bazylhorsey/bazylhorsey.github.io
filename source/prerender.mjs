// Prerender the page into build/index.html for crawlers and first paint.
//
//   ./build.sh   (runs this as its last step)
//
// It runs the compiled Elm program headless, exactly like run.mjs and like a
// Jorn server component would, takes the tree Jorn sends to mount, and writes
// it out as plain HTML inside <div id="app">. Search engines and link
// unfurlers that never run JavaScript get the full page.
//
// In the browser nothing changes: Jorn still mounts the same tree and owns the
// page from then on (theme toggle, filters, every patch). Mount replaces the
// prerendered children with an identical tree, so there is nothing to see.
// Real hydration, adopting the existing DOM instead, is Jorn stage 7.

import { createRequire } from "node:module";
import { readFileSync, writeFileSync } from "node:fs";

const require = createRequire(import.meta.url);
const { Elm } = require("./build/build/main.js");

const VOID = new Set([
  "area", "base", "br", "col", "embed", "hr", "img", "input",
  "link", "meta", "source", "track", "wbr",
]);

const escText = (s) =>
  s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
const escAttr = (s) => escText(s).replace(/"/g, "&quot;");

function html(node) {
  if (typeof node.text === "string") return escText(node.text);
  const attrs = Object.entries(node.attrs)
    .map(([k, v]) => ` ${k}="${escAttr(String(v))}"`)
    .join("");
  if (VOID.has(node.tag)) return `<${node.tag}${attrs}>`;
  return `<${node.tag}${attrs}>${node.children.map(html).join("")}</${node.tag}>`;
}

const tree = await new Promise((resolve, reject) => {
  const app = Elm.Main.init({ flags: { dark: false } });
  app.ports.toClient.subscribe((message) => {
    if (message.mount) resolve(message.mount);
    else if (message.error) reject(new Error(message.error));
  });
  setTimeout(() => reject(new Error("nothing mounted")), 2000);
});

const file = "build/index.html";
const page = readFileSync(file, "utf8");
const empty = '<div id="app"></div>';
if (!page.includes(empty)) {
  console.error(`expected ${empty} in ${file}`);
  process.exit(1);
}
const body = html(tree);
writeFileSync(file, page.replace(empty, `<div id="app">${body}</div>`));
console.log(`prerendered ${(body.length / 1024).toFixed(0)} KB of HTML into ${file}`);
