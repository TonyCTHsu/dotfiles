---
name: pr-description
description: Draft and create a GitHub pull request description from the current branch's commits and diff. Use whenever the user asks to open a PR, create a pull request, or write a PR description. Also use it when the user wants help turning a branch and its commits into a PR. Follows the repo's own PR template and any repo-specific conventions (CLAUDE.md, AGENTS.md, CONTRIBUTING.md) instead of a generic format. Always gets explicit approval on the drafted title and body before running `gh pr create`.
---

# PR Description

Turn the current branch into a well-formed pull request. Read what actually changed. Fill in the repo's own template, not a generic one. Get the user's approval, then create the PR.

The skill guards against one core failure mode: a description that sounds plausible but matches neither the repo's conventions nor what the code actually does. Reading answers both questions. Guessing answers neither.

## Step 1. Learn the repo's conventions

Before drafting anything, find out how this repo wants PRs written. Check, in order, and use whichever exist:

1. `.github/PULL_REQUEST_TEMPLATE.md` (or `.github/PULL_REQUEST_TEMPLATE/*.md` when there are multiple templates). This is the structure the body must follow, section by section. Do not invent your own headings when a template exists.
2. `CLAUDE.md`, `AGENTS.md`, `CONTRIBUTING.md` at the repo root. Look for rules about PR title format, changelog and release-note conventions, and required labels. Look for the target remote or repo for `gh` commands. Also look for who the description is written for, and any "always ask before X" rules around PRs.
3. `git log --oneline -20` on the base branch. Skim a few recent merged PRs (`gh pr list --state merged --limit 5` plus `gh pr view <n>`) to see the house style in practice. Do this when the written rules leave something ambiguous.

When no template and no written conventions exist, fall back to a plain structure. What does this PR do? Why? How was it tested?

## Step 2. Understand what actually changed

Do not draft from the branch name or from memory of the conversation. Read the real diff:

```bash
git status
git log <base-branch>..HEAD --oneline
git diff <base-branch>...HEAD
```

Figure out the base branch and remote the way the repo's own conventions specify, for example a required `--repo` flag or a non-`origin` remote. When commits are messy (WIP, fixups), summarize the net effect of the diff rather than narrating the commit history. Reviewers care what changed, not how you got there.

When the diff touches something you cannot describe correctly (a subsystem, a flag, an unfamiliar API), read the surrounding code before writing about it. A confidently wrong summary is worse than asking the user one clarifying question.

## Step 3. Draft the description

Fill in the template's sections from what you learned in Step 1 and Step 2. Whatever headings a repo template imposes, apply this thinking to the content you put under them. This holds whether or not a template exists:

- **Why gets high-level context, not itemized detail.** State the motivating context or a concrete example as a short narrative. The reviewer must understand the problem being solved, not merely that something changed.
- **What is the strategy, not the implementation.** Describe the approach and the reasoning behind it as a narrative. Do not recap the diff bullet by file or bullet by commit. The diff already shows that.
- **Validation gets called out explicitly.** How this was verified (tests added or run, manual repro) deserves its own visible mention. Do not bury it inside "what" or skip it.
- **Additional info is the catch-all.** It holds notable tradeoffs, alternatives considered, known limitations, or deliberate simplifications. Flag something only when it is worth flagging. It is fine to omit this section when there is nothing to add.

When no template exists at all, use Why / What / Validation / Additional info as the section headings themselves.

- Write for the person reviewing the code, not for a changelog reader or the original requester. Be concise, one sentence per point.
- Only claim testing was done when you can see it. That means existing tests covering the change, or tests you added and ran. Do not assert "tested manually" when you did not.
- Many repos have a customer-facing changelog convention. Check Step 1's sources for the exact required format. Include any required prefix words. Get the wording from the repo's own docs, not from a generic guess. The exact format varies by repo, and getting it wrong is a common review nit.
- Note what you will pass to `gh pr create` when the repo requires specific PR metadata (labels, `--repo` target, reviewers). The approval step then covers it too.

## Step 4. Get explicit approval before creating anything

Opening a PR is visible to other people and not trivially reversible. Always show the drafted title and full body in the conversation, and wait for the user to approve or edit it before running `gh pr create`. This holds even when the user's original request sounded like a green light. Drafting and creating are two different commitments, and the draft is the one point where a wrong assumption is cheap to fix.

Once approved:

```bash
git push -u <remote> <branch>   # only when the branch is not already pushed, and only after confirming this is wanted
gh pr create --repo <owner/repo> --title "..." --body "$(cat <<'EOF'
...
EOF
)" [--label ... ] [other required flags from Step 1]
```

Use a heredoc for `--body` so formatting survives. Do not inline newline-heavy text as a shell argument. When pushing the branch is needed and the user's request did not already imply it, confirm that too. Pushing is a separate action from opening the PR itself.

Report back the PR URL that `gh pr create` returns.
