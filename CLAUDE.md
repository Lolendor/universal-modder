@AGENTS.md

## Claude Code specifics
- Installed as a plugin, the skills are namespaced (`/universal-modder:mod-any-game`), and a
  SessionStart hook puts `um` on PATH. No asset-service key or MCP server is required.
- In a clone, `.claude/settings.json` adds the same PATH hook and `.claude/skills` links to `skills/`.
