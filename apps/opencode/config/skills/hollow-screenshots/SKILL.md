---
name: Hollow Screenshots
description: Capture real application screenshots from Hollow multiplexer on Windows via WSL, using hollow-cli to capture panes or tabs directly. Use when adding screenshots to docs or demonstrating terminal UI states.
---

# Hollow screenshots from WSL

Use when target UI runs in Hollow on Windows and agent shell runs in WSL. `hollow-cli` controls tabs and panes and captures their screenshots directly.

1. Resolve screenshot-capable CLI before driving UI:

   ```sh
   command -v hollow-cli
   hollow-cli pane screenshot --help
   ```

   Injected `hollow-cli` may be stale and lack `pane screenshot` / `tab screenshot`. Select CLI once:

   ```sh
   HOLLOW_CLI="$(command -v hollow-cli)"
   if [ -z "$HOLLOW_CLI" ] || ! "$HOLLOW_CLI" pane screenshot --help >/dev/null 2>&1; then
     HOLLOW_CLI="${HOLLOW_SOURCE:-$HOME/Projects/_stuff/hollow}/scripts/hollow-cli"
   fi
   ```

   Run selected CLI as `python3 "$HOLLOW_CLI" ...`. In this environment, source CLI is `/home/francis/Projects/_stuff/hollow/scripts/hollow-cli`.

   If `get mux-tree` reports `/dev/tty` error or socket timeout, shell's `HOLLOW_*` values may not match active Hollow pane. Inspect `ps -ef | grep '[h]ollow-wsl-bypass'`; find target pane by cwd/workspace and use its `--env HOLLOW_COMMAND_ADDR=...`, `--env HOLLOW_PANE_ID=...`, and `--env HOLLOW_WORKSPACE_ID=...` values explicitly for CLI calls. Set/export these before invoking source CLI with `--transport socket`.

2. Inspect `python3 "$HOLLOW_CLI" --transport socket get mux-tree --pretty`. Identify correct workspace, tab index, and pane ID. Existing panes may contain unsaved work; create a disposable tab for demonstrations (`tab new --cmd 'cd /path/to/project && nvim ...'`) instead of overwriting them. Record new tab ID and pane ID for cleanup.
3. Drive UI with `pane send-text --id "$PANE_ID" ':command'` and `send-keys --id "$PANE_ID" '{Enter}'`. `send-keys` uses brace notation for special keys (`{Enter}`, `{Esc}`, `{Up}`, `{Ctrl-s}`); plain `Enter` types letters. For interactive Neovim normal-mode keys, use `send-keys --id "$PANE_ID" 'p'`, etc. Inspect target via `get pane-text --id "$PANE_ID"`.
4. Capture pane or tab directly to PNG. Use pane ID for an individual pane, or tab ID/index for whole tab. Screenshot path is interpreted by Hollow process on Windows. Capture to Windows-accessible path (for example `C:\Users\<user>\AppData\Local\Temp\capture.png`), then read it in WSL through `/mnt/c/Users/<user>/AppData/Local/Temp/capture.png`.

   ```sh
   python3 "$HOLLOW_CLI" --transport socket pane screenshot "$WIN_OUT" --id "$PANE_ID"
   # Or capture selected tab by ID or index:
   python3 "$HOLLOW_CLI" --transport socket tab screenshot "$WIN_OUT" --id "$TAB_ID"
   python3 "$HOLLOW_CLI" --transport socket tab screenshot "$WIN_OUT" --index "$TAB_INDEX"
   ```

   Settle animations/loading before capture. Read WSL-mapped PNG and confirm intended UI appears. If command-line text remains visible, wait and recapture. To capture several UI states, repeat key sends and screenshots.
5. For documentation, crop empty areas with `magick input.png -crop WIDTHxHEIGHT+X+Y +repage -strip output.png`, then inspect result. Preserve UI context and labels. Store PNGs under project's docs assets and use descriptive Markdown alt text. Keep example contents representative; avoid publishing unrelated private pane contents.
6. Close only tabs created for capture (`tab close --id "$TAB_ID"`), restore original tab selection, and verify image files and Markdown links. Do not close existing panes.
