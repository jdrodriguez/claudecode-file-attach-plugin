#!/bin/bash
# claude-attach uninstaller

set -e

CLAUDE_DIR="$HOME/.claude"
SKILL_DIR="$CLAUDE_DIR/skills/attach"
HOOKS_DIR="$CLAUDE_DIR/hooks"
SETTINGS="$CLAUDE_DIR/settings.json"

echo "Uninstalling claude-attach..."

# 1. Remove skill
if [ -d "$SKILL_DIR" ]; then
  echo "  Removing /attach skill..."
  rm -rf "$SKILL_DIR"
fi

# 2. Remove hook script
if [ -f "$HOOKS_DIR/attach-hook.sh" ]; then
  echo "  Removing hook script..."
  rm "$HOOKS_DIR/attach-hook.sh"
fi

# 3. Note about settings.json
if [ -f "$SETTINGS" ] && grep -q "attach-hook.sh" "$SETTINGS"; then
  echo ""
  echo "  NOTE: The hook entry in ~/.claude/settings.json was not removed automatically."
  echo "  Please manually remove the attach-hook reference from the hooks section."
fi

echo ""
echo "Done! Restart your Claude Code session for changes to take effect."
