# claude-attach

A file attachment plugin for [Claude Code](https://claude.ai/claude-code) CLI. Opens a native macOS Finder file picker to attach files to your conversation — similar to the attach button in the VS Code extension.

## Demo

```
> /attach
[Finder file picker opens]
[Select one or more files]
[Claude reads and analyzes the files]
```

## Features

- **`/attach`** — Slash command with autocomplete support
- **`attach:`** — Inline hook for instant file picker (no LLM delay)
- Native macOS Finder file picker dialog
- Multiple file selection (Cmd+Click)
- Works in both terminal CLI and VS Code extension

## Requirements

- macOS (uses `osascript` for native file picker)
- [Claude Code](https://claude.ai/claude-code) CLI
- `jq` (`brew install jq`)

## Install

```bash
git clone https://github.com/YOUR_USERNAME/claude-attach.git
cd claude-attach
bash install.sh
```

Then restart your Claude Code session.

## Usage

### Slash Command (recommended)

```
> /attach
> /attach analyze this code
> /attach summarize these docs
```

Type `/attach` and it appears in the autocomplete menu. Claude opens the file picker, reads the selected files, and follows your instructions.

### Inline Hook (instant)

```
> attach: review this file
> attach:
```

Type `attach:` anywhere in your prompt for an instant file picker — no LLM processing delay. The hook runs before Claude sees your prompt.

### Comparison

| Method | Speed | Autocomplete |
|--------|-------|-------------|
| `/attach` | ~2-3s (LLM processes skill first) | Yes |
| `attach:` | Instant (hook runs pre-prompt) | No |

## How It Works

### `/attach` (Skill)

1. Registers as a Claude Code skill at `~/.claude/skills/attach/SKILL.md`
2. When invoked, instructs Claude to run `osascript` to open Finder
3. Claude reads the selected file(s) with the Read tool
4. Claude responds based on file contents and your instructions

### `attach:` (Hook)

1. Registers as a `UserPromptSubmit` hook in `~/.claude/settings.json`
2. Runs before Claude processes your prompt
3. Opens Finder file picker via `osascript`
4. Injects selected file paths as additional context
5. Claude sees the paths and reads the files

## Uninstall

```bash
cd claude-attach
bash uninstall.sh
```

Then manually remove the hook entry from `~/.claude/settings.json` if present.

## File Structure

```
claude-attach/
├── skill/
│   └── SKILL.md           # /attach slash command
├── hooks/
│   └── attach-hook.sh     # attach: instant hook
├── install.sh             # Installer
├── uninstall.sh           # Uninstaller
├── LICENSE
└── README.md
```

## Limitations

- **macOS only** — uses `osascript` / AppleScript for the native file picker
- Linux/Windows support would require platform-specific file picker alternatives (PRs welcome!)
- The `/attach` skill has a ~2-3s delay due to LLM processing; use `attach:` for instant response

## Contributing

PRs welcome! Some ideas:

- Linux support via `zenity` or `kdialog`
- Windows support via PowerShell `OpenFileDialog`
- File type filtering (images, code, documents)
- Drag-and-drop integration

## License

MIT
