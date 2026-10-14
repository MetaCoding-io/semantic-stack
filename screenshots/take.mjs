#!/usr/bin/env node
// Screenshot every UI in the stack with a headless Chromium.
//
//   node take.mjs [group ...] [--only a,b] [--timeout 120] [--out out] [--strict]
//   node take.mjs plan <group>          # print the group's compose profiles/services/load/index as JSON
//   node take.mjs gallery [--out out]   # (re)build out/index.html and out/summary.md from existing PNGs
//
// Groups and targets live in targets.json. Each target is awaited until it answers HTTP (< 500),
// opened at 1440x900, given `settle` ms to render, then captured. Failures are recorded, not fatal,
// unless --strict (used for the default group in CI).
import { readFileSync, writeFileSync, mkdirSync, readdirSync, existsSync, statSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));
const config = JSON.parse(readFileSync(join(here, "targets.json"), "utf8"));

const args = process.argv.slice(2);
const opt = (name, def) => { const i = args.indexOf(`--${name}`); return i >= 0 ? args[i + 1] : def; };
const flag = (name) => args.includes(`--${name}`);
const outDir = opt("out", join(here, "out"));
const timeoutS = Number(opt("timeout", 120));
const only = opt("only", "")?.split(",").filter(Boolean) ?? [];
const positional = args.filter((a, i) => !a.startsWith("--") && !(i > 0 && args[i - 1].startsWith("--") && !["--strict"].includes(args[i - 1])));

if (positional[0] === "plan") {
  const g = config.groups[positional[1]];
  if (!g) { console.error(`unknown group ${positional[1]}`); process.exit(2); }
  console.log(JSON.stringify({ profiles: g.profiles, profileFlags: g.profiles.map(p => `--profile ${p}`).join(" "), services: g.services, load: !!g.load, index: !!g.index }));
  process.exit(0);
}
if (positional[0] === "gallery") { writeGallery(outDir); process.exit(0); }

const groups = positional.length ? positional : ["default"];
for (const g of groups) if (!config.groups[g]) { console.error(`unknown group ${g}; known: ${Object.keys(config.groups).join(", ")}`); process.exit(2); }

const { chromium } = await import("playwright");

async function waitForHttp(url, seconds) {
  const deadline = Date.now() + seconds * 1000;
  let last = "";
  while (Date.now() < deadline) {
    try {
      const r = await fetch(url, { redirect: "follow", signal: AbortSignal.timeout(10000) });
      if (r.status < 500) return { ok: true, status: r.status };
      last = `HTTP ${r.status}`;
    } catch (e) { last = e.cause?.code || e.name || String(e); }
    await new Promise(r => setTimeout(r, 3000));
  }
  return { ok: false, status: last };
}

// CHROMIUM_PATH points at a system or pre-installed Chromium when Playwright's own download is unavailable.
const browser = await chromium.launch(process.env.CHROMIUM_PATH ? { executablePath: process.env.CHROMIUM_PATH } : {});
const results = [];
for (const groupName of groups) {
  const group = config.groups[groupName];
  const dir = join(outDir, groupName);
  mkdirSync(dir, { recursive: true });
  for (const t of group.targets) {
    if (only.length && !only.includes(t.name)) continue;
    const started = Date.now();
    const file = join(dir, `${t.name}.png`);
    const row = { group: groupName, name: t.name, url: t.url, file: `${groupName}/${t.name}.png` };
    process.stdout.write(`${groupName}/${t.name.padEnd(22)} ${t.url}\n`);
    const up = await waitForHttp(t.url, timeoutS);
    if (!up.ok) { row.error = `not reachable within ${timeoutS}s (${up.status})`; results.push(row); console.log(`  ✗ ${row.error}`); continue; }
    const context = await browser.newContext({ viewport: { width: 1440, height: 900 }, ignoreHTTPSErrors: true });
    const page = await context.newPage();
    try {
      await page.goto(t.url, { waitUntil: "domcontentloaded", timeout: 60000 });
      await page.waitForLoadState("networkidle", { timeout: 20000 }).catch(() => {});
      if (t.waitFor) await page.waitForSelector(t.waitFor, { timeout: 20000 }).catch(() => {});
      if (t.settle) await page.waitForTimeout(t.settle);
      await page.screenshot({ path: file, fullPage: !t.clip });
      row.title = (await page.title()) || "";
      row.status = up.status;
      row.ms = Date.now() - started;
      console.log(`  ✓ ${row.title || "(no title)"} (${row.ms} ms)`);
    } catch (e) {
      row.error = e.message.split("\n")[0];
      console.log(`  ✗ ${row.error}`);
    } finally {
      await context.close();
    }
    results.push(row);
  }
}
await browser.close();

mkdirSync(outDir, { recursive: true });
const resultsFile = join(outDir, "results.json");
const previous = existsSync(resultsFile) ? JSON.parse(readFileSync(resultsFile, "utf8")) : [];
const merged = [...previous.filter(p => !results.some(r => r.group === p.group && r.name === p.name)), ...results];
writeFileSync(resultsFile, JSON.stringify(merged, null, 2));
writeGallery(outDir);

const failed = results.filter(r => r.error);
console.log(`\n${results.length - failed.length} captured, ${failed.length} failed -> ${outDir}`);
if (failed.length) console.log("failed: " + failed.map(f => `${f.group}/${f.name}`).join(", "));
process.exit(flag("strict") && failed.length ? 1 : 0);

function writeGallery(dir) {
  const resultsPath = join(dir, "results.json");
  let rows = existsSync(resultsPath) ? JSON.parse(readFileSync(resultsPath, "utf8")) : [];
  if (!rows.length) { // rebuild from files alone
    for (const g of readdirSync(dir)) {
      const gd = join(dir, g);
      if (!statSync(gd).isDirectory()) continue;
      for (const f of readdirSync(gd).filter(f => f.endsWith(".png"))) rows.push({ group: g, name: f.replace(/\.png$/, ""), file: `${g}/${f}` });
    }
  }
  const esc = s => String(s ?? "").replace(/[&<>"]/g, c => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c]));
  const byGroup = {};
  for (const r of rows) (byGroup[r.group] ??= []).push(r);
  const sections = Object.entries(byGroup).map(([g, rs]) => `
  <h2>${esc(g)}</h2>
  <div class="grid">${rs.map(r => r.error
    ? `<figure class="fail"><div class="ph">not captured</div><figcaption><strong>${esc(r.name)}</strong><br><a href="${esc(r.url)}">${esc(r.url)}</a><br><em>${esc(r.error)}</em></figcaption></figure>`
    : `<figure><a href="${esc(r.file)}"><img src="${esc(r.file)}" alt="${esc(r.name)}" loading="lazy"></a><figcaption><strong>${esc(r.name)}</strong> ${esc(r.title)}<br><a href="${esc(r.url)}">${esc(r.url)}</a></figcaption></figure>`).join("\n")}
  </div>`).join("\n");
  writeFileSync(join(dir, "index.html"), `<!doctype html><html lang="en"><head><meta charset="utf-8"><title>semantic-stack screenshots</title>
<style>body{font:15px/1.5 system-ui,sans-serif;margin:24px;background:#f6f8fa;color:#1b1f23}h1{margin:0 0 4px}h2{margin:28px 0 10px;text-transform:uppercase;font-size:13px;letter-spacing:.08em;color:#57606a}
.grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(420px,1fr));gap:16px}figure{margin:0;background:#fff;border:1px solid #d0d7de;border-radius:8px;overflow:hidden}
img{display:block;width:100%;height:260px;object-fit:cover;object-position:top;border-bottom:1px solid #d0d7de}.ph{height:260px;display:grid;place-items:center;color:#cf222e;background:#fff5f5}
figcaption{padding:10px 12px;font-size:13px;color:#57606a}figcaption strong{color:#1b1f23}figcaption a{color:#0969da;word-break:break-all}.fail{border-color:#cf222e}</style></head>
<body><h1>semantic-stack screenshots</h1><p>Generated ${new Date().toISOString()} by screenshots/take.mjs. Click an image for full size.</p>${sections}</body></html>`);
  const md = ["| group | target | result |", "|---|---|---|", ...rows.map(r => `| ${r.group} | ${r.name} | ${r.error ? "❌ " + r.error : "✅ " + (r.title || "captured")} |`)].join("\n");
  writeFileSync(join(dir, "summary.md"), md + "\n");
}
