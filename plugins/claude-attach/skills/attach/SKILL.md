---
description: Open macOS Finder file picker to attach files to this conversation
allowed-tools: Bash, Read
---

# Attach Files

Open the macOS Finder file picker to select files for this conversation.

## Steps

1. Run this bash command to open the file picker:

```bash
osascript -e 'set selectedFiles to choose file with prompt "Select file(s) to attach" with multiple selections allowed
set filePaths to {}
repeat with aFile in selectedFiles
set end of filePaths to POSIX path of aFile
end repeat
set AppleScript'"'"'s text item delimiters to "\n"
return filePaths as text'
```

2. Read the output to get the selected file path(s)
3. Use the Read tool to read each selected file
4. If the user provided additional instructions (via $ARGUMENTS), follow those instructions with the attached files
5. If no instructions were provided, summarize what was attached and ask how the user wants to proceed
