## Communication Style

- Be terse in all output
- No emojis anywhere (responses, code, comments, commit messages) unless explicitly requested

## Change control

- A question or an opinion request ("what do you think") asks for
  analysis. Answer in prose
  with a recommendation. Show code as a snippet or a proposed diff; leave
  the files untouched.
- Edits need an imperative: "do", "make", "add", "fix", "revert",
  "implement", or a "yes" / "go ahead" reply to a proposal.
- Unsure whether a message authorizes edits? Treat it as not authorized.
  Ask.

## Convention files

- Read repo-local convention files (`CONTRIBUTING.md`, `.changes/AGENTS.md`,
  `.github/AGENTS.md`) in full before following them. A partial read
  (`head`, a line limit) leaves later rules invisible.

## Committing

- One commit per distinct concern; combine only when inseparable (e.g. a rename touching many files) — even when fixing several review comments in one pass
- Do not amend commits. Each change is a new commit on top of the
  previous one
- Never commit on the default branch, branch name always prefix with `tonyc.t.hsu/` to be explicit about ownership
- Run git commands that can open an editor (`commit`, `rebase --continue`, `merge`) with `--no-edit` or `GIT_EDITOR=true`; an interactive editor hangs non-interactive agent sessions
- A repo's own conventions win over the defaults in this file

## Remote access

- Never change the remote without explicit consent from me in the current session. This includes `git push` (any form, including `--force-with-lease`), `gh pr create`, `gh issue create`, `gh repo create`, and commands that edit GitHub settings
- Local operations (commits, amends, branch creation) are fine
- If work is ready to push, stop and ask

## Git workflow: worktrees over in-place branching

- Feature/fix work never happens in the main checkout. Create a git worktree first.
- Default location: `.worktrees/<branch>` at the repo root, ignored via the
  global gitignore (`core.excludesFile`), not the repo's `.gitignore`. That
  needs one setup and no commit on the default branch.
- Before creating, run `git worktree list`. If the branch already has a
  worktree, reuse it.
- Start work: `git worktree add .worktrees/<branch> -b tonyc.t.hsu/<branch>`
  from the main checkout. This branch-ref write is the one allowed change
  there. Edits and commits are not: treat the main checkout as read-only.
- Then move the session into the worktree. Start pi with
  `pi .worktrees/<branch>`: the session cwd also selects the repo AGENTS.md
  and project config. Or delegate with `worktree: true` / `cwd:` subagents,
  with the parent only coordinating. No command runs against the main
  checkout after setup.
- Run the repo's dependency install inside the worktree before other work.
- Finish: commits happen inside the worktree. Run `git worktree remove` only
  after the branch is pushed or explicitly kept.

## Session naming

- When the session's objective is settled, call the `name_session` tool
  with a name of at most six words. One call per session.

## Pull Requests

- Always create as drafts
- GitHub issue and PR bodies: unwrapped prose, one blank line between paragraphs. Hard line-wrap only files committed to the repo, and match the repo's existing wrap style there
