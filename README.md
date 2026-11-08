# My dotfiles

Based on [thoughtbot dotfiles](https://github.com/thoughtbot/dotfiles) with personal customizations.

## Quick Start

Same one-liner on both platforms. `install.sh` dispatches per OS:

```bash
git clone https://github.com/TonyCTHsu/dotfiles ~/dotfiles && ~/dotfiles/install.sh
```

On a new Mac, that is all. On a new Omarchy (Arch Linux) machine, the
first run stops at the 1Password check. Follow [OMARCHY.md](OMARCHY.md)
for the two extra steps.

## Manual Install

If you prefer manual control, see [SETUP.md](SETUP.md) for macOS or
[OMARCHY.md](OMARCHY.md) for Omarchy.

Migrating a machine still running the old `rcm`-based setup? See
[SETUP.md](SETUP.md#migrating-an-existing-machine-from-rcm). For the structure and
rationale behind the current chezmoi layout, see [MIGRATION.md](MIGRATION.md).

## Requirements

- macOS or Arch Linux (Omarchy)
- Git (macOS prompts to install Command Line Tools when it is missing)

## Updating

After making changes to your dotfiles:

```bash
# Re-apply dotfiles
chezmoi apply

# Install new packages (if Brewfile changed)
brew bundle

# Update vim plugins (if needed)
vim -u ~/.vimrc.bundles +PlugUpdate +PlugClean! +qa
```

## Machine-Specific Customizations

For machine-specific shell settings that must not be committed (for example,
company-managed environment variables), create `~/.zshrc.local`.
`dot_zshrc` sources it automatically when present.

Git identity is instead handled per-repo-path via `includeIf "gitdir:..."` in
`dot_gitconfig` - see that file for the pattern.

## What's in it?

[vim](http://www.vim.org/) configuration:

- [fzf](https://github.com/junegunn/fzf.vim) for fuzzy file/buffer/tag finding.
- [Rails.vim](https://github.com/tpope/vim-rails) for improved navigation of
  Rails file structure via `gf` and `:A` (alternate), `:Rextract` partials,
  and `:Rinvert` migrations.
- Run many kinds of tests [from vim]([https://github.com/janko-m/vim-test)
- Set `<leader>` to a single space.
- Switch between the last two files with space-space.
- Syntax highlighting for Markdown, HTML, JavaScript, Ruby, Go, Elixir, more.
- Use [Ag](https://github.com/ggreer/the_silver_searcher) instead of Grep when
  available.
- Map `<leader>ct` to re-index ctags.
- Use [vim-mkdir](https://github.com/pbrisbin/vim-mkdir) for automatically
  creating non-existing directories before writing the buffer.
- Use [vim-plug](https://github.com/junegunn/vim-plug) to manage plugins.

[tmux](http://robots.thoughtbot.com/a-tmux-crash-course)
configuration:

- Improve color resolution.
- Remove administrative debris (session name, hostname, time) in status bar.
- Set prefix to `Ctrl+s`
- Soften status bar color from harsh green to light gray.

[git](http://git-scm.com/) configuration:

- Adds a `co-upstream-pr $PR_NUMBER $LOCAL_BRANCH_NAME` subcommand to checkout remote upstream branch into a local branch.
- Adds a `create-branch` alias to create feature branches.
- Adds a `delete-branch` alias to delete feature branches.
- Adds a `merge-branch` alias to merge feature branches into master.
- Adds an `up` alias to fetch and rebase `origin/master` into the feature
  branch. Use `git up -i` for interactive rebases.
- Adds `post-{checkout,commit,merge}` hooks to re-index your ctags.
- Adds `pre-commit` and `prepare-commit-msg` stubs that delegate to your local
  config.
- Adds `trust-bin` alias to append a project's `bin/` directory to `$PATH`.

[Ruby](https://www.ruby-lang.org/en/) configuration:

- Add trusted binstubs to the `PATH`.
- Load the ASDF version manager.

[Rails](https://rubyonrails.org)

- Adds [railsrc][] with the following options to integrate with [Suspenders][].

```
--database=postgresql
--skip-test
-m=https://raw.githubusercontent.com/thoughtbot/suspenders/main/lib/install/web.rb
```

If you want to skip this file altogether, run `rails new my_app --no_rc`.

[railsrc]: https://github.com/rails/rails/blob/7f7f9df8641e35a076fe26bd097f6a1b22cb4e2d/railties/lib/rails/generators/rails/app/USAGE#L5C1-L7
[Suspenders]: https://github.com/thoughtbot/suspenders

Shell aliases and scripts:

- `...` for quicker navigation to the parent's parent directory.
- `b` for `bundle`.
- `g` with no arguments is `git status` and with arguments acts like `git`.
- `migrate` for `bin/rails db:migrate db:rollback && bin/rails db:migrate db:test:prepare`.
- `mcd` to make a directory and change into it.
- `replace foo bar **/*.rb` to find and replace within a given list of files.
- `tat` to attach to tmux session named the same as the current directory.
- `v` for `$VISUAL`.

[Obsidian](https://obsidian.md) appearance config (`appearance.json`, `core-plugins.json`,
`community-plugins.json`, `snippets/`). It is not wired into `install.sh`, since not every
machine has the vault. Run manually per machine:

```bash
link-obsidian [vault_path]  # defaults to $HOME/obsidian
```

This symlinks those files/directories into the vault's `.obsidian/` folder so appearance
tweaks stay in sync across machines. Vault content and other `.obsidian/` state
(`workspace.json`, `plugins/`, and similar files) are left untouched. Community themes
(for example, Minimal) are not vendored here. Reinstall them per machine via Settings →
Appearance → Themes.

## Credits

Originally based on [thoughtbot dotfiles](https://github.com/thoughtbot/dotfiles) with personal customizations and automation added.
