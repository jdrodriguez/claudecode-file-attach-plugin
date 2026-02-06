#!/bin/bash
# claude-attach installer
# Installs the /attach skill and attach: hook for Claude Code

set -e

CLAUDE_DIR="$HOME/.claude"
SKILL_DIR="$CLAUDE_DIR/skills/attach"
HOOKS_DIR="$CLAUDE_DIR/hooks"
SETTINGS="$CLAUDE_DIR/settings.json"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing claude-attach..."

# Check for jq (required by hook)
if ! command -v jq &>/dev/null; then
  echo "Error: jq is required but not installed."
  echo "  brew install jq"
  exit 1
fi

# Check for osascript (macOS only)
if ! command -v osascript &>/dev/null; then
  echo "Error: osascript not found. This plugin requires macOS."
  exit 1
fi

# 1. Install skill (/attach slash command)
echo "  Installing /attach skill..."
mkdir -p "$SKILL_DIR"
cp "$SCRIPT_DIR/skill/SKILL.md" "$SKILL_DIR/SKILL.md"

# 2. Install hook (attach: instant trigger)
echo "  Installing attach: hook..."
mkdir -p "$HOOKS_DIR"
cp "$SCRIPT_DIR/hooks/attach-hook.sh" "$HOOKS_DIR/attach-hook.sh"
chmod +x "$HOOKS_DIR/attach-hook.sh"

# 3. Add hook to settings.json
HOOK_COMMAND="bash $HOOKS_DIR/attach-hook.sh"

if [ ! -f "$SETTINGS" ]; then
  echo "  Creating settings.json..."
  cat > "$SETTINGS" <<EOJSON
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$HOOK_COMMAND",
            "timeout": 120
          }
        ]
      }
    ]
  }
}
EOJSON
elif ! grep -q "attach-hook.sh" "$SETTINGS"; then
  echo "  Adding hook to settings.json..."

  if grep -q '"hooks"' "$SETTINGS"; then
    # hooks key exists — check if UserPromptSubmit exists
    if grep -q '"UserPromptSubmit"' "$SETTINGS"; then
      echo "  WARNING: UserPromptSubmit hooks already exist in settings.json."
      echo "  Please manually add the following hook entry:"
      echo ""
      echo "    {\"type\": \"command\", \"command\": \"$HOOK_COMMAND\", \"timeout\": 120}"
      echo ""
    else
      echo "  WARNING: hooks key exists but no UserPromptSubmit."
      echo "  Please manually add the attach hook to your settings.json."
    fi
  else
    # No hooks key — add it before the closing brace
    # Use a temp file for safe editing
    TMPFILE=$(mktemp)
    # Remove trailing closing brace, add hooks, close
    sed '$ d' "$SETTINGS" > "$TMPFILE"
    # Check if we need a comma after the last property
    if tail -1 "$TMPFILE" | grep -q '}$'; then
      sed -i '' '$ s/}$/},/' "$TMPFILE"
    elif ! tail -1 "$TMPFILE" | grep -q ',$'; then
      sed -i '' '$ s/$/,/' "$TMPFILE"
    fi
    cat >> "$TMPFILE" <<EOJSON
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$HOOK_COMMAND",
            "timeout": 120
          }
        ]
      }
    ]
  }
}
EOJSON
    mv "$TMPFILE" "$SETTINGS"
  fi
else
  echo "  Hook already configured in settings.json"
fi

echo ""
echo "Done! Restart your Claude Code session to use:"
echo "  /attach        Slash command (opens Finder file picker)"
echo "  attach:        Inline hook (instant, type in any prompt)"
echo ""
echo "To uninstall: bash $(dirname "$0")/uninstall.sh"
