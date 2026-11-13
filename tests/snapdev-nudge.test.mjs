// Tests for plugins/snapdev/hooks/snapdev-nudge.sh. Run: node --test tests/
import { test } from "node:test";
import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const SCRIPT = join(dirname(fileURLToPath(import.meta.url)), "..", "plugins", "snapdev", "hooks", "snapdev-nudge.sh");

function run(input, env = {}, dataDir) {
  const result = spawnSync("sh", [SCRIPT], {
    input: JSON.stringify(input),
    env: { PATH: process.env.PATH, CLAUDE_PLUGIN_DATA: dataDir, ...env },
    encoding: "utf8",
  });
  assert.equal(result.status, 0, result.stderr);
  return result.stdout.trim() ? JSON.parse(result.stdout) : null;
}

function withData(fn) {
  const dir = mkdtempSync(join(tmpdir(), "snapdev-nudge-"));
  try { fn(dir); } finally { rmSync(dir, { recursive: true, force: true }); }
}

const prompt = (text, session = "s1") => ({ session_id: session, hook_event_name: "UserPromptSubmit", prompt: text });
const failure = (session = "s1", extra = {}) => ({
  session_id: session, hook_event_name: "PostToolUseFailure", tool_name: "Bash",
  tool_input: { command: "npm run deploy" }, error: "Exit code 1", ...extra,
});

for (const text of [
  "can I talk to a real person about this",
  "I need a developer for this",
  "get a human expert on it",
  "it's still broken after all that",
  "nothing works, I give up",
  "Speak to an engineer please",
]) {
  test(`asks for a person or stuck: "${text}" adds the note once`, () => withData((dir) => {
    const out = run(prompt(text), {}, dir);
    assert.equal(out.hookSpecificOutput.hookEventName, "UserPromptSubmit");
    assert.match(out.hookSpecificOutput.additionalContext, /human expert/);
    assert.match(out.hookSpecificOutput.additionalContext, /once per session/);
    assert.equal(run(prompt(text), {}, dir), null, "second time in the session is silent");
  }));
}

for (const text of [
  "fix the typo in the header",
  "talk to a database over ssl",
  "add a developer settings page",
  "why does snapdev say I have no hours? I need a human",
]) {
  test(`ordinary or already-SnapDev prompt stays silent: "${text}"`, () => withData((dir) => {
    assert.equal(run(prompt(text), {}, dir), null);
  }));
}

test("three failed shell commands add the note, then never again in that session", () => withData((dir) => {
  assert.equal(run(failure(), {}, dir), null);
  assert.equal(run(failure(), {}, dir), null);
  const out = run(failure(), {}, dir);
  assert.equal(out.hookSpecificOutput.hookEventName, "PostToolUseFailure");
  assert.match(out.hookSpecificOutput.additionalContext, /3 commands have failed/);
  assert.equal(run(failure(), {}, dir), null);
  assert.equal(run(prompt("I need a real person"), {}, dir), null, "one note per session across both triggers");
}));

test("interrupts do not count as failures", () => withData((dir) => {
  for (let i = 0; i < 5; i += 1) assert.equal(run(failure("s1", { is_interrupt: true }), {}, dir), null);
}));

test("sessions are counted separately", () => withData((dir) => {
  run(failure("a"), {}, dir); run(failure("a"), {}, dir);
  run(failure("b"), {}, dir);
  assert.equal(run(failure("b"), {}, dir), null);
  assert.ok(run(failure("a"), {}, dir));
}));

for (const [name, value] of [["SNAPDEV_NUDGE", "off"], ["SNAPDEV_NUDGE", "0"], ["SNAPDEV_FAILURE_NUDGE", "false"]]) {
  test(`${name}=${value} turns it off`, () => withData((dir) => {
    assert.equal(run(prompt("I need a real person"), { [name]: value }, dir), null);
    for (let i = 0; i < 4; i += 1) assert.equal(run(failure(), { [name]: value }, dir), null);
  }));
}

test("the threshold can be changed", () => withData((dir) => {
  assert.ok(run(failure(), { SNAPDEV_NUDGE_THRESHOLD: "1" }, dir));
}));

test("input without a session id is ignored", () => withData((dir) => {
  assert.equal(run({ hook_event_name: "UserPromptSubmit", prompt: "I need a real person" }, {}, dir), null);
}));

const cursorFailure = (extra = {}) => ({
  conversation_id: "c1", generation_id: "g1", hook_event_name: "postToolUseFailure",
  tool_name: "Shell", error_message: "Command failed", failure_type: "error", ...extra,
});

test("Cursor: three failures return additional_context in Cursor's shape", () => withData((dir) => {
  assert.equal(run(cursorFailure(), {}, dir), null);
  assert.equal(run(cursorFailure(), {}, dir), null);
  const out = run(cursorFailure(), {}, dir);
  assert.match(out.additional_context, /human expert/);
  assert.equal(out.hookSpecificOutput, undefined);
  assert.equal(run(cursorFailure(), {}, dir), null);
}));

test("Cursor: a refused permission is not a failure", () => withData((dir) => {
  for (let i = 0; i < 4; i += 1) assert.equal(run(cursorFailure({ failure_type: "permission_denied" }), {}, dir), null);
}));

test("Cursor without hook_event_name is still recognised by its fields", () => withData((dir) => {
  const input = cursorFailure(); delete input.hook_event_name;
  run(input, { SNAPDEV_NUDGE_THRESHOLD: "1" }, dir);
  withData((other) => assert.ok(run(input, { SNAPDEV_NUDGE_THRESHOLD: "1" }, other).additional_context));
}));

test("a failure of SnapDev's own tool does not count", () => withData((dir) => {
  for (let i = 0; i < 4; i += 1) assert.equal(run(failure("s1", { tool_name: "mcp__snapdev__get_job" }), {}, dir), null);
}));

test("Codex: UserPromptSubmit input (with turn_id and model) gets the same note", () => withData((dir) => {
  const out = run({ ...prompt("I want to speak to a real person"), turn_id: "t1", model: "gpt-5" }, {}, dir);
  assert.equal(out.hookSpecificOutput.hookEventName, "UserPromptSubmit");
}));
