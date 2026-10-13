#!/bin/sh
# Mirrors the driver: tracked files match origin/main, untracked local skills are left alone.

SKILLS_DIR="$HOME/.claude/skills"
LOG_FILE="$HOME/.claude/skills-sync.log"

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
