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
// Real hydration, adopting the existing DOM instead, is still todo on Jorn's
// roadmap.

import { createRequire } from "node:module";
import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname } from "node:path";

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

function render(flags) {
  return new Promise((resolve, reject) => {
    const app = Elm.Main.init({ flags });
    app.ports.toJorn.subscribe((message) => {
      if (message.mount) resolve(message.mount);
      else if (message.error) reject(new Error(message.error));
    });
    setTimeout(() => reject(new Error("nothing mounted")), 2000);
  });
}

// Swap exactly one occurrence, or stop the build. A silent miss here would
// ship the essay with the home page's title and canonical URL.
function swap(page, from, to) {
  const n = page.split(from).length - 1;
  if (n !== 1) throw new Error(`expected 1 of ${JSON.stringify(from.slice(0, 60))}, found ${n}`);
  return page.replace(from, to);
}

const SITE = "https://bazylhorsey.github.io";
const ESSAY = {
  page: "essay",
  path: "/writing/distracted-forward-deployed-officer/",
  title: "The Distracted Forward Deployed Officer",
  // His words, from the essay.
  description:
    "A forward deployed engineer isn't defined by where they sit. They're defined by where their attention goes when nobody is directing it.",
  date: "2026-10-15",
};

const STUDY = {
  page: "study",
  path: "/writing/escapes-multiply/",
  title: "Escapes Multiply",
  description:
    "How to analyze the ROI of computer vision working next to the people who already inspect a warehouse dock. With a model you can push on.",
  date: "2026-08-01",
};

// An article page is the same shell as the home page (same stylesheet, same
// compiled Elm, same patcher and glue), with its own head and flags.
function articleShell(home, article) {
  const url = SITE + article.path;
  const full = `${article.title} | Bazyl Horsey`;
  let page = home;
  page = page.replace(/<title>[^<]*<\/title>/, `<title>${full}</title>`);
  page = page.replace(
    /(<meta\s+name="description"\s+content=")[^"]*(")/,
    `$1${escAttr(article.description)}$2`,
  );
  page = page.replace(
    /(<meta\s+property="og:description"\s+content=")[^"]*(")/,
    `$1${escAttr(article.description)}$2`,
  );
  page = swap(page, '<meta property="og:type" content="website" />', '<meta property="og:type" content="article" />');
  page = page.replace(/(<meta property="og:title" content=")[^"]*(")/, `$1${escAttr(full)}$2`);
  page = swap(page, `<meta property="og:url" content="${SITE}/" />`, `<meta property="og:url" content="${url}" />`);
  page = swap(page, `<link rel="canonical" href="${SITE}/" />`, `<link rel="canonical" href="${url}" />`);
  page = page.replace(/(<meta property="og:image:alt" content=")[^"]*(")/, `$1${escAttr(full)}$2`);
  // Home has WebSite + Person blocks; an article gets one Article block.
  const ld = page.match(/\s*<script type="application\/ld\+json">[\s\S]*?<\/script>/g) || [];
  if (ld.length < 1) throw new Error("no JSON-LD in the shell");
  ld.forEach((block) => (page = page.replace(block, "")));
  const schema = {
    "@context": "https://schema.org",
    "@type": "Article",
    headline: article.title,
    description: article.description,
    datePublished: article.date,
    url,
    mainEntityOfPage: url,
    image: `${SITE}/og.png`,
    author: { "@type": "Person", name: "Bazyl Horsey", url: `${SITE}/` },
  };
  page = swap(
    page,
    "</title>",
    `</title>\n    <script type="application/ld+json">\n${JSON.stringify(schema, null, 2)}\n    </script>`,
  );
  page = swap(
    page,
    'flags: { dark: root.dataset.theme === "night" },',
    `flags: { dark: root.dataset.theme === "night", page: "${article.page}" },`,
  );
  return page;
}

const empty = '<div id="app"></div>';
const homeFile = "build/index.html";
const home = readFileSync(homeFile, "utf8");
if (!home.includes(empty)) {
  console.error(`expected ${empty} in ${homeFile}`);
  process.exit(1);
}

const pages = [
  { file: homeFile, shell: home, flags: { dark: false } },
  ...[ESSAY, STUDY].map((article) => ({
    file: "build" + article.path + "index.html",
    shell: articleShell(home, article),
    flags: { dark: false, page: article.page },
  })),
];

for (const { file, shell, flags } of pages) {
  const body = html(await render(flags));
  mkdirSync(dirname(file), { recursive: true });
  writeFileSync(file, shell.replace(empty, `<div id="app">${body}</div>`));
  console.log(`prerendered ${(body.length / 1024).toFixed(0)} KB of HTML into ${file}`);
}
