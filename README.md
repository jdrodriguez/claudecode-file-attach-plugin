# claude-attach

A file attachment plugin for [Claude Code](https://claude.ai/claude-code) CLI. Opens a native macOS Finder file picker to attach files to your conversation — similar to the attach button in the VS Code extension.

## Demo

```
> /claude-attach:attach
[Finder file picker opens]
[Select one or more files]
[Claude reads and analyzes the files]
```

## Features

- **`/claude-attach:attach`** — Slash command with autocomplete support
- **`attach:`** — Inline hook for instant file picker (no LLM delay)
- Native macOS Finder file picker dialog
- Multiple file selection (Cmd+Click)
- Works in both terminal CLI and VS Code extension

## Requirements

- macOS (uses `osascript` for native file picker)
- [Claude Code](https://claude.ai/claude-code) CLI
- `jq` (`brew install jq`)

## Install

### Marketplace (recommended)

In Claude Code, run:

```
/plugin → Add Marketplace → jdrodriguez/claudecode-file-attach-plugin
```

Then enable the `claude-attach` plugin when prompted. Both the slash command and the `attach:` hook are installed automatically.

### Manual

```bash
git clone https://github.com/jdrodriguez/claudecode-file-attach-plugin.git
cd claudecode-file-attach-plugin
bash install.sh
```

Then restart your Claude Code session.

## Usage

### Slash Command

```
> /claude-attach:attach
> /claude-attach:attach analyze this code
> /claude-attach:attach summarize these docs
```

Type `/claude-attach` and select `attach` from the autocomplete menu. Claude opens the file picker, reads the selected files, and follows your instructions.

### Inline Hook (instant)

```
> attach: review this file
> attach:
```

Type `attach:` anywhere in your prompt for an instant file picker — no LLM processing delay. The hook runs before Claude sees your prompt.

### Comparison

| Method | Speed | Autocomplete |
|--------|-------|-------------|
| `/claude-attach:attach` | ~2-3s (LLM processes skill first) | Yes |
| `attach:` | Instant (hook runs pre-prompt) | No |

## How It Works

### Slash Command (Skill)

1. Registers as a Claude Code plugin skill via the marketplace
2. When invoked, instructs Claude to run `osascript` to open Finder
3. Claude reads the selected file(s) with the Read tool
4. Claude responds based on file contents and your instructions

### `attach:` (Hook)

1. Registered automatically via the plugin's `hooks.json`
2. Runs before Claude processes your prompt
3. Opens Finder file picker via `osascript`
4. Injects selected file paths as additional context
5. Claude sees the paths and reads the files

## Uninstall

### Marketplace install

In Claude Code, run `/plugin` and remove the `claude-attach` plugin.

### Manual install

```bash
cd claudecode-file-attach-plugin
bash uninstall.sh
```

## File Structure

```
claudecode-file-attach-plugin/
├── .claude-plugin/
│   └── marketplace.json              # Marketplace manifest
├── plugins/
│   └── claude-attach/
│       ├── .claude-plugin/
│       │   └── plugin.json           # Plugin manifest
│       ├── skills/
│       │   └── attach/
│       │       └── SKILL.md          # /claude-attach:attach command
│       └── hooks/
│           ├── hooks.json            # Hook configuration
│           └── attach-hook.sh        # attach: instant hook script
├── skill/
│   └── SKILL.md                      # Standalone skill (manual install)
├── hooks/
│   └── attach-hook.sh                # Standalone hook (manual install)
├── install.sh                        # Manual installer
├── uninstall.sh                      # Manual uninstaller
├── LICENSE
└── README.md
```

## Limitations

- **macOS only** — uses `osascript` / AppleScript for the native file picker
- Linux/Windows support would require platform-specific file picker alternatives (PRs welcome!)
- The slash command has a ~2-3s delay due to LLM processing; use `attach:` for instant response

## Contributing

PRs welcome! Some ideas:

- Linux support via `zenity` or `kdialog`
- Windows support via PowerShell `OpenFileDialog`
- File type filtering (images, code, documents)
- Drag-and-drop integration

## License

MIT
