# Migrating from rcm to chezmoi

This repo used to be managed with [`rcm`](https://github.com/thoughtbot/rcm) (`rcup` +
`rcrc`). It now uses [`chezmoi`](https://www.chezmoi.io/). This document explains the
new structure and the reasoning behind it. It is for anyone, human or otherwise, who
wants to know why a file is named or organized the way it is.

## Naming convention replaces symlink-list config

rcm's `rcrc` declared *what* to manage via `EXCLUDES`/`DOTFILES_DIRS`. That central
config file had to be kept in sync with the repo's contents. chezmoi instead reads the
*filename itself* as the instruction, so nothing separate exists to keep in sync:

| Prefix | Meaning | Example |
|---|---|---|
| `dot_` | deploy as `~/.foo` | `dot_zshrc` → `~/.zshrc` |
| `private_` | deploy with `0600`/`0700` perms | `private_dot_ssh/private_config` → `~/.ssh/config` (0600) |
| `symlink_` | deploy as a symlink whose file content is the target path | `symlink_dot_claude.tmpl` → `~/.claude` → `~/dotfiles/claude` |
| `run_once_*` | shell script that runs once per unique content, tracked in chezmoi's state | `run_once_install-vim-plug.sh.tmpl` |
| `run_onchange_*` | shell script that re-runs whenever its rendered content changes | `run_onchange_update-vim-plugins.sh.tmpl` (keyed off a `sha256sum` of `dot_vimrc.bundles`) |
| (no prefix) | left alone, not deployed to `$HOME` at all | `Brewfile`, and anything matched by `.chezmoiignore` |

## Why `private_` had to go on individual files, not only the directory

`private_dot_ssh/` alone gives the *directory* 0700 permissions. Files inside still
come out 0644 unless they also carry their own `private_` prefix. That is why
`ssh/config` became `private_dot_ssh/private_config`, not `private_dot_ssh/config`.

## Why the run scripts have `|| true` on the risky commands

chezmoi aborts the entire `apply` if any script exits non-zero. rcm's
`hooks/post-up` had no `set -e` and silently tolerated failures instead. Two commands
had pre-existing flaky/non-TTY failure modes that never mattered under rcm's tolerant
hook but now block every `apply`:

- `vim -E -s +PlugUpgrade +qa` in `run_once_install-vim-plug.sh.tmpl` can exit 1 even
  when run standalone, for unclear reasons unrelated to this migration.
- `reset -Q` in `run_onchange_update-vim-plugins.sh.tmpl` fails with
  `inappropriate ioctl for device` when run outside a real TTY.

Appending `|| true` to both restores the old "best effort, do not block" behavior
rather than papering over an unrelated bug.

## Why `hooks/post-up` split into three scripts

chezmoi's `run_once_`/`run_onchange_` semantics let each step declare its own re-run
condition. A single monolithic hook script cannot express that:

- **vim-plug install** (`run_once_install-vim-plug.sh.tmpl`) only needs to run once
  ever.
- **vim plugin update** (`run_onchange_update-vim-plugins.sh.tmpl`) re-runs whenever
  `dot_vimrc.bundles` changes. It is keyed to that file's hash.
- **doctor checks** (`run_once_doctor-checks.sh.tmpl`) are one-time sanity checks
  (`git_template/HEAD` cleanup, `/etc/zshenv` `path_helper` warning).

rcm ran the whole `hooks/post-up` script on every `rcup`, with no way to scope a part
of it to "only when this file changes."

## Why `.chezmoiignore` gained `*.md`, `LICENSE`, `install.sh`

These are repo-only artifacts (docs, the bootstrap script itself) that never land in
`$HOME`. rcm handled the equivalent via `EXCLUDES="*.md LICENSE CODEOWNERS"` in
`rcrc`. `.chezmoiignore` is the direct replacement.

`claude` and `obsidian` are also listed there. Those directories are reached only
via `symlink_dot_claude.tmpl` or the explicit `link-obsidian` script, not by chezmoi
managing them directly.

## Why `dot_gitconfig` stayed a plain rename, not a `.tmpl`

Early planning considered adding a chezmoi `profile` template variable to switch git
identity per machine. It turned out `gitconfig` already does this via git's own
`includeIf "gitdir:~/datadog/"` mechanism. Git pulls in `~/.gitconfig.datadog` for
work-tree paths. That is a cleaner, git-native solution than layering chezmoi
templating on top, so it was left alone.

## Why `~/dotfiles-local`-style overrides were retired

rcm's convention was per-machine override files living outside the repo. chezmoi's
untracked `.local`-suffixed files achieve the same thing with less machinery. No
separate directory needs to be checked. The tracked config file only needs a
source-guard pointing at its `.local` counterpart.

Only one of these hooks ever had real content on any machine: `~/.zshrc.local`. It
holds settings a company-managed provisioning tool writes outside the repo (see
`dot_zshrc`). The unused source-guards for `.gitconfig.local`, `.aliases.local`,
`.vimrc.local`, `.vimrc.bundles.local`, `.zshenv.local`, and `.tmux.conf.local` were
removed. Git identity in particular never needed this pattern. `dot_gitconfig` already
handles per-repo-path identity via git's own `includeIf "gitdir:..."`, which is more
precise than a machine-wide override (see the section above).

## Migrating another machine

See the "Migrating an Existing Machine from rcm" section in [SETUP.md](SETUP.md).
