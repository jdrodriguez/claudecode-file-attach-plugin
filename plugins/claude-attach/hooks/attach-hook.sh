#!/bin/bash
# Claude Code Hook: File Attach via macOS Finder
# Triggers when user prompt contains "attach:"
# Opens native file picker and returns selected paths as additionalContext

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt')

# Fast path: skip if no attach: in prompt
if [[ "$PROMPT" != *"attach:"* ]]; then
  exit 0
fi

# Strip attach: from the prompt to get the user's actual message
USER_MESSAGE=$(echo "$PROMPT" | sed 's|attach:||g' | xargs)

# Open macOS file picker (multiple selections allowed)
SELECTED=$(osascript <<'EOF'
set selectedFiles to choose file with prompt "Select file(s) to attach" with multiple selections allowed
set filePaths to {}
repeat with aFile in selectedFiles
  set end of filePaths to POSIX path of aFile
end repeat
set AppleScript's text item delimiters to "\n"
return filePaths as text
EOF
2>/dev/null)

# If user cancelled the picker, proceed without attachment
if [ -z "$SELECTED" ]; then
  exit 0
fi

# Build the file list for context
FILE_LIST=""
while IFS= read -r filepath; do
  if [ -n "$filepath" ]; then
    FILE_LIST="${FILE_LIST}\n- ${filepath}"
  fi
done <<< "$SELECTED"

# Build additional context
CONTEXT="The user attached the following file(s) via the file picker. Please use the Read tool to read and analyze each file:"
CONTEXT="${CONTEXT}${FILE_LIST}"

if [ -n "$USER_MESSAGE" ]; then
  CONTEXT="${CONTEXT}\n\nThe user's instruction for these files: ${USER_MESSAGE}"
fi

echo -e "$CONTEXT"
exit 0
