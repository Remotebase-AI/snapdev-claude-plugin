// The skill ships in four places, one per install route. They must not drift. Run: node --test tests/
import { test } from "node:test";
import assert from "node:assert/strict";
import { readFileSync, readdirSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = join(dirname(fileURLToPath(import.meta.url)), "..");
const MASTER = join(ROOT, "plugins", "snapdev", "skills", "snapdev");
const COPIES = [
  join(ROOT, "skills", "snapdev"),
  join(ROOT, "plugins", "snapdev-directory", "skills", "snapdev"),
  join(ROOT, "plugins", "snapdev-cursor", "skills", "snapdev"),
];

function files(dir, prefix = "") {
  return readdirSync(join(dir, prefix), { withFileTypes: true }).flatMap((entry) => {
    const path = join(prefix, entry.name);
    return entry.isDirectory() ? files(dir, path) : [path];
  }).sort();
}

for (const copy of COPIES) {
  test(`${copy.slice(ROOT.length + 1)} matches plugins/snapdev/skills/snapdev`, () => {
    assert.deepEqual(files(copy), files(MASTER));
    for (const file of files(MASTER)) {
      assert.equal(readFileSync(join(copy, file), "utf8"), readFileSync(join(MASTER, file), "utf8"), file);
    }
  });
}

test("the Agent Plugins manifests agree on the server and the version", () => {
  const plugin = JSON.parse(readFileSync(join(ROOT, "plugin.json"), "utf8"));
  const mcp = JSON.parse(readFileSync(join(ROOT, "mcp.json"), "utf8"));
  const claude = JSON.parse(readFileSync(join(ROOT, "plugins", "snapdev", ".claude-plugin", "plugin.json"), "utf8"));
  assert.equal(mcp.mcpServers.snapdev.url, "https://api.snapdev.ai/mcp");
  assert.equal(plugin.version, claude.version);
});
