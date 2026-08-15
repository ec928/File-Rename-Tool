# 📝 File Rename Tool

A bulk file renaming utility for Windows with a live preview, full undo, and a CSV audit trail of
every change.

Single-file: one `.bat` containing an embedded PowerShell/WPF application. No installer, no runtime to
download, nothing written to the registry.

## ✨ Key Features

**Preview before you commit** — every rule shows the resulting filenames before anything is written to
disk, so a bad pattern costs nothing.

**Undo** — reverses the last batch if a rename didn't do what you expected.

**CSV audit log** — each run appends timestamp, original name, new name, and folder, so you always
have a record of what changed.

**Rename rules**

| Rule | Effect |
|---|---|
| Insert at Position | Inserts text at a fixed character offset |
| Insert by Separator | Inserts relative to a separator character, using an anchor and instance |
| Remove | Strips matching text |
| Replace With | Find-and-replace across filenames |
| Date Modified | Applies the file's last-modified timestamp |

**Directory filtering** — a file filter limits which files a rule applies to, and recently-used
directories are remembered between sessions.

## 📦 Usage

1. Download `FileRenameWPS.bat` from the [Releases](https://github.com/ec928/File-Rename-Tool/releases) page.
2. Run it. The batch file re-invokes itself through PowerShell and opens the window.
3. Pick a directory, choose a rule, check the preview, then apply.

Requires Windows PowerShell 5.1 (present on every Windows 10/11 install) and .NET Framework for WPF.
Nothing else.

**If Windows blocks it**: the file may arrive marked as downloaded from the internet. Right-click →
Properties → **Unblock**, or run `Unblock-File .\FileRenameWPS.bat` in PowerShell.

## 🔒 Privacy

The tool writes two files next to itself:

- `FileRenameWPF.json` — your recently-used directories
- `FileRenameWPF_Log.csv` — the rename history, including full source paths

Both stay on your machine and both are gitignored, so they cannot be committed to this repository by
accident. Delete them at any time; the tool recreates them as needed.

## 💬 Feedback

Bugs and feature requests are welcome in the
[Issues](https://github.com/ec928/File-Rename-Tool/issues) tab.
