# mac-setup

Makes every Mac (Mac mini, MacBook Pro, MacBook Neo) the same, so it doesn't matter which one I sit down at.

## New or wiped Mac

Open Terminal and run:

```bash
mkdir -p ~/Code
git clone https://github.com/tchetelat5/mac-setup.git ~/Code/mac-setup
bash ~/Code/mac-setup/setup.sh
```

(If git isn't installed yet, macOS will offer to install it — say yes, then run the lines again.)

The script installs Homebrew and everything in the `Brewfile`, asks whether to install Xcode, sets up git, signs in to GitHub, and can clone all my repos into `~/Code`. It's safe to re-run.

## Starting over (clean reset)

One Mac at a time, MacBook Neo or MacBook Pro first, Mac mini last (it runs the homelab).

1. **Rescue anything that's only on that Mac.** Push any code to GitHub, move documents to iCloud Drive or Notion, and note any app settings or license keys you'd hate to lose.
2. **Make a Time Machine backup** as a safety net.
3. **Erase:** System Settings → General → Transfer or Reset → **Erase All Content and Settings**.
4. **Set up as new** — sign into your Apple ID, but **don't** use Migration Assistant (that copies the clutter back).
5. **Run this repo's `setup.sh`** (see above).
6. **Use it for a few days.** Anything you find yourself missing gets added to the `Brewfile`, so the next Mac comes out right the first time.

## Daily habit

- **Sit down at a Mac:** run `code-status` — clones any new GitHub repos this Mac doesn't have yet, then pulls the latest for every project.
- **Before walking away:** commit and push (or ask Claude Code to). Run `code-status` to confirm everything is ✅.

## Adding a tool

Add a line to `Brewfile`, commit, push. On the other Macs: `cd ~/Code/mac-setup && git pull && brew bundle`.

## Which Mac does what

| Mac | Role |
|---|---|
| Mac mini | Home base. Always on. Xcode builds, simulators, App Store work, homelab. |
| MacBook Pro | Main portable workstation. Can do everything the mini can. |
| MacBook Neo | Light work: Claude Code, git, editing. Skip Xcode (8GB RAM) — remote into the Mac mini for builds. |

## Files

- `Brewfile` — tools for every Mac
- `Brewfile.xcode` — Xcode, for the mini and the Pro only
- `setup.sh` — the one-command setup
- `bin/code-status` — sync check across all repos in `~/Code`
