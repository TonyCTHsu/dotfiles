# Migrating from rcm to chezmoi

This repo used to be managed with [`rcm`](https://github.com/thoughtbot/rcm) (`rcup` +
`rcrc`). It now uses [`chezmoi`](https://www.chezmoi.io/). This document explains the new
structure and the reasoning behind it, for anyone (human or otherwise) trying to
understand why a given file is named or organized the way it is.

## Naming convention replaces symlink-list config

rcm's `rcrc` declared *what* to manage via `EXCLUDES`/`DOTFILES_DIRS` — a central config
file that had to be kept in sync with the repo's contents. chezmoi instead reads the
*filename itself* as the instruction, so there's nothing separate to keep in sync:

| Prefix | Meaning | Example |
|---|---|---|
| `dot_` | deploy as `~/.foo` | `dot_zshrc` → `~/.zshrc` |
| `private_` | deploy with `0600`/`0700` perms | `private_dot_ssh/private_config` → `~/.ssh/config` (0600) |
| `symlink_` | deploy as a symlink; file content is the target path | `symlink_dot_claude.tmpl` → `~/.claude` → `~/dotfiles/claude` |
| `run_once_*` | shell script, runs once per unique content (tracked in chezmoi's state) | `run_once_install-vim-plug.sh.tmpl` |
| `run_onchange_*` | shell script, re-runs whenever its rendered content changes | `run_onchange_update-vim-plugins.sh.tmpl` (keyed off a `sha256sum` of `dot_vimrc.bundles`) |
| (no prefix) | left alone, not deployed to `$HOME` at all | `Brewfile`, and anything matched by `.chezmoiignore` |

## Why `private_` had to go on individual files, not just the directory

`private_dot_ssh/` alone only gives the *directory* 0700 perms — files inside still come
out 0644 unless they also carry their own `private_` prefix. That's why `ssh/config`
became `private_dot_ssh/private_config`, not just `private_dot_ssh/config`.

## Why the run scripts have `|| true` on the risky commands

chezmoi aborts the entire `apply` if any script exits non-zero — unlike rcm's
`hooks/post-up`, which had no `set -e` and silently tolerated failures. Two commands had
pre-existing flaky/non-TTY failure modes that never mattered under rcm's tolerant hook but
would now block every `apply`:

- `vim -E -s +PlugUpgrade +qa` in `run_once_install-vim-plug.sh.tmpl` can exit 1 even when
  run standalone, for unclear reasons unrelated to this migration.
- `reset -Q` in `run_onchange_update-vim-plugins.sh.tmpl` fails with
  `inappropriate ioctl for device` when run outside a real TTY.

Appending `|| true` to both restores the old "best effort, don't block" behavior rather
than papering over an unrelated bug.

## Why `hooks/post-up` split into three scripts

chezmoi's `run_once_`/`run_onchange_` semantics let each step declare its own re-run
condition — something a single monolithic hook script couldn't express:

- **vim-plug install** (`run_once_install-vim-plug.sh.tmpl`) — only needs to run once
  ever.
- **vim plugin update** (`run_onchange_update-vim-plugins.sh.tmpl`) — should re-run
  whenever `dot_vimrc.bundles` changes, so it's keyed to that file's hash.
- **doctor checks** (`run_once_doctor-checks.sh.tmpl`) — one-time sanity checks
  (`git_template/HEAD` cleanup, `/etc/zshenv` `path_helper` warning).

rcm just ran the whole `hooks/post-up` script on every `rcup`, with no way to scope a part
of it to "only when this file changes."

## Why `.chezmoiignore` gained `*.md`, `LICENSE`, `install.sh`

These are repo-only artifacts (docs, the bootstrap script itself) that should never land
in `$HOME`. rcm handled the equivalent via `EXCLUDES="*.md LICENSE CODEOWNERS"` in `rcrc`;
`.chezmoiignore` is the direct replacement. `claude` and `obsidian` are also listed there,
since those directories are reached only via `symlink_dot_claude.tmpl` or the explicit
`link-obsidian` script, not by chezmoi managing them directly.

## Why `dot_gitconfig` stayed a plain rename, not a `.tmpl`

Early planning considered adding a chezmoi `profile` template variable to switch git
identity per machine. It turned out `gitconfig` already does this via git's own
`includeIf "gitdir:~/datadog/"` mechanism, pulling in `~/.gitconfig.datadog` for
work-tree paths. That's a cleaner, git-native solution than layering chezmoi templating on
top, so it was left alone.

## Why `~/dotfiles-local`-style overrides were retired

rcm's convention was per-machine override files living outside the repo. chezmoi's
untracked `.local`-suffixed files (`~/.gitconfig.local`, `~/.zshrc.local`,
`~/.aliases.local`, `~/.vimrc.local`) achieve the same thing more simply — no separate
directory to remember to check, and each tracked config file already has an
`include`/source-guard pointing at its `.local` counterpart.

## Migrating another machine

See the "Migrating an Existing Machine from rcm" section in [SETUP.md](SETUP.md).
