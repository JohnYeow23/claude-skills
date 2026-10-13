#!/bin/sh
# Run once on each non-driver Mac (after 'gh auth login'):
#   gh api repos/JohnYeow23/claude-skills/contents/install-receiver.sh -H 'Accept: application/vnd.github.raw' | sh
set -e

REPO="JohnYeow23/claude-skills"
PULL_INTERVAL_SECONDS=600

CLAUDE_DIR="$HOME/.claude"
SKILLS_DIR="$CLAUDE_DIR/skills"
LABEL="com.$(whoami).claude-skills-sync"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"

command -v gh >/dev/null || { echo "Install GitHub CLI first: brew install gh"; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "Run 'gh auth login' first"; exit 1; }
gh auth setup-git

mkdir -p "$CLAUDE_DIR"

# ── back up existing skills, keep the account-managed synced/ folder  ──────────────────
if [ -d "$SKILLS_DIR" ] && [ ! -d "$SKILLS_DIR/.git" ]; then
  backup="$CLAUDE_DIR/skills.backup-$(date +%Y%m%d-%H%M%S)"
  mv "$SKILLS_DIR" "$backup"
  echo "Existing skills moved to $backup"
fi

if [ ! -d "$SKILLS_DIR/.git" ]; then
  gh repo clone "$REPO" "$SKILLS_DIR"
fi

if [ -n "$backup" ] && [ -d "$backup/synced" ]; then
  mv "$backup/synced" "$SKILLS_DIR/synced"
fi

chmod +x "$SKILLS_DIR/_sync-pull.sh"

# ── launchd agent: pull on login and every PULL_INTERVAL_SECONDS  ──────────────────
mkdir -p "$HOME/Library/LaunchAgents"
cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>$LABEL</string>
  <key>ProgramArguments</key>
  <array><string>/bin/sh</string><string>$SKILLS_DIR/_sync-pull.sh</string></array>
  <key>EnvironmentVariables</key>
  <dict><key>PATH</key><string>/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin</string></dict>
  <key>StartInterval</key><integer>$PULL_INTERVAL_SECONDS</integer>
  <key>RunAtLoad</key><true/>
</dict>
</plist>
EOF

launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$PLIST"

echo "Done. Skills sync from $REPO every $((PULL_INTERVAL_SECONDS / 60)) min. Log: $CLAUDE_DIR/skills-sync.log"
