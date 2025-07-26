# My dotfiles

Based on [thoughtbot dotfiles](https://github.com/thoughtbot/dotfiles) with personal customizations.

## Quick Start

For a new Mac:

```bash
git clone https://github.com/TonyCTHsu/dotfiles ~/dotfiles && ~/dotfiles/install.sh
```

The install script will:
- Install Homebrew (if needed)
- Install all dependencies from Brewfile
- Set up dotfiles with rcm
- Configure zsh as default shell

## Manual Install

If you prefer manual control, see [SETUP.md](SETUP.md) for detailed instructions.

## Requirements

- macOS
- Git (automatically prompts to install Command Line Tools if needed)

## Updating

After making changes to your dotfiles:

```bash
# Re-apply dotfiles
rcup

# Install new packages (if Brewfile changed)
brew bundle

# Update vim plugins (if needed)
vim -u ~/.vimrc.bundles +PlugUpdate +PlugClean! +qa
```

## Machine-Specific Customizations

For machine-specific settings, you can create local override files that won't be committed:

- `~/.gitconfig.local` - Git settings specific to this machine
- `~/.zshrc.local` - Shell customizations for this machine
- `~/.aliases.local` - Machine-specific aliases
- `~/.vimrc.local` - Vim settings for this machine

## What's in it?

[vim](http://www.vim.org/) configuration:

- [fzf](https://github.com/junegunn/fzf.vim) for fuzzy file/buffer/tag finding.
- [Rails.vim](https://github.com/tpope/vim-rails) for enhanced navigation of
  Rails file structure via `gf` and `:A` (alternate), `:Rextract` partials,
  `:Rinvert` migrations, etc.
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

## Credits

Originally based on [thoughtbot dotfiles](https://github.com/thoughtbot/dotfiles) with personal customizations and automation added.
