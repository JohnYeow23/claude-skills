#!/bin/sh
# Mirrors the driver: tracked files match origin/main, untracked local skills are left alone.

SKILLS_DIR="$HOME/.claude/skills"
LOG_FILE="$HOME/.claude/skills-sync.log"
SETTINGS_FILE="$HOME/.claude/settings.json"
PLUGINS_FILE="$SKILLS_DIR/plugins.json"

_log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') | $1 | sync_pull | $2" >> "$LOG_FILE"
}

cd "$SKILLS_DIR" || { _log ERROR "Skills dir missing"; exit 1; }

before=$(git rev-parse --short HEAD)
if ! git fetch -q origin main 2>>"$LOG_FILE"; then
  _log ERROR "Fetch failed"
  exit 1
fi
after=$(git rev-parse --short origin/main)

if [ "$before" != "$after" ]; then
  git reset -q --hard origin/main
  _log INFO "Updated $before -> $after"
fi

# ── merge plugins.json into settings.json, repo wins on listed keys  ──────────────────
[ -f "$PLUGINS_FILE" ] || exit 0
command -v jq >/dev/null || { _log ERROR "jq missing, plugin merge skipped"; exit 1; }
[ -f "$SETTINGS_FILE" ] || echo '{}' > "$SETTINGS_FILE"

merged=$(jq -s '.[0] * {
  enabledPlugins: ((.[0].enabledPlugins // {}) + (.[1].enabledPlugins // {})),
  extraKnownMarketplaces: ((.[0].extraKnownMarketplaces // {}) + (.[1].extraKnownMarketplaces // {}))
}' "$SETTINGS_FILE" "$PLUGINS_FILE") || { _log ERROR "Plugin merge failed"; exit 1; }

if [ "$merged" != "$(jq . "$SETTINGS_FILE")" ]; then
  printf '%s\n' "$merged" > "$SETTINGS_FILE.tmp" && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
  _log INFO "Plugin settings merged"
fi
