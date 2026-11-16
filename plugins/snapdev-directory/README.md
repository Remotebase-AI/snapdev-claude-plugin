# SnapDev (directory edition)

This folder is the copy of the SnapDev plugin submitted to Anthropic's plugin directory.
It is `plugins/snapdev` without the "stuck" hook and its script: the directory runs
command hooks only from Verified organizations, and ours is not one yet.

It carries the same skill, the `/jobs` command and the remote MCP server
(`https://api.snapdev.ai/mcp`). Do not edit files here by hand: they are copies of
`plugins/snapdev`, checked by the sync commands in `rules/README.md`. People who install
from this repo's own marketplace still get `plugins/snapdev`, hook included.

Get a human expert, a SnapDev software engineer, without leaving Claude: Claude writes the
brief, shows an estimate in hours before you confirm, and tells you what changed when the
work is done. Support: team@snapdev.ai.
