---
name: pr-description
description: Draft and create a GitHub pull request description from the current branch's commits and diff. Use whenever the user asks to "open a PR", "create a pull request", "write a PR description", "draft the PR body/summary", or wants help turning their branch/commits into a PR — even if they just say "let's PR this" or "ready to open a PR for this branch". Follows the repo's own PR template and any repo-specific conventions (CLAUDE.md/AGENTS.md/CONTRIBUTING.md) instead of a generic format, and always gets explicit approval on the drafted title/body before running `gh pr create`.
---

# PR Description

Turn the current branch into a well-formed pull request: read what actually
changed, fill in the repo's own template (not a generic one), get the user's
sign-off, then create it.

The core failure mode this skill guards against is drafting a description
that *sounds* plausible but doesn't match either the repo's conventions or
what the code actually does. Both are answered by reading things, not by
guessing.

## Step 1 — Learn the repo's conventions

Before drafting anything, find out how this repo wants PRs written. Check,
in order, and use whichever exist:

1. `.github/PULL_REQUEST_TEMPLATE.md` (or `.github/PULL_REQUEST_TEMPLATE/*.md`
   if there are multiple templates) — this is the structure the body MUST
   follow, section by section. Don't invent your own headings if a template
   exists.
2. `CLAUDE.md`, `AGENTS.md`, `CONTRIBUTING.md` at the repo root — look
   specifically for rules about: PR title format, changelog/release-note
   conventions, required labels, target remote/repo for `gh` commands, who
   the description is written for, and any "always ask before X" rules
   around PRs.
3. `git log --oneline -20` on the base branch — skim a few recent *merged*
   PRs (`gh pr list --state merged --limit 5` + `gh pr view <n>`) to see the
   house style in practice, if the written rules leave something ambiguous.

If no template and no written conventions exist, fall back to a plain
structure: What does this PR do? / Why? / How was it tested?

## Step 2 — Understand what actually changed

Don't draft from the branch name or from memory of the conversation — read
the real diff:

```bash
git status
git log <base-branch>..HEAD --oneline
git diff <base-branch>...HEAD
```

Figure out the base branch and remote the same way the repo's own
conventions specify (e.g. a required `--repo` flag, a non-`origin` remote).
If commits are messy (WIP, fixups), summarize the *net effect* of the diff
rather than narrating the commit history — reviewers care what changed, not
how you got there.

If the diff touches something you don't understand well enough to describe
correctly (a subsystem, a flag, an unfamiliar API), read the surrounding
code before writing about it. A confidently-wrong summary is worse than
asking the user one clarifying question.

## Step 3 — Draft the description

Fill in the template's sections using what you learned in Step 1 and Step 2.
Whatever headings a repo template imposes, apply this thinking to the
*content* you put under them — this holds whether or not a template exists:

- **Why gets high-level context, not itemized detail.** State the
  motivating context or a concrete example as a short narrative — the
  reviewer should understand the problem being solved, not just that
  something changed.
- **What is the strategy, not the implementation.** Describe the approach
  taken and the reasoning behind it, as a narrative, not a bullet-per-file
  or bullet-per-commit recap of the diff (the diff already shows that).
- **Validation gets called out explicitly.** How this was verified
  (tests added/run, manual repro, etc.) deserves its own visible mention —
  don't bury it inside "what" or skip it.
- **Additional info is the catch-all.** Notable tradeoffs, alternatives
  considered, known limitations, or deliberate simplifications go here
  when there's something worth flagging — it's fine to omit this section
  when there's nothing to add.

When no template exists at all, use Why / What / Validation / Additional
info as the section headings themselves.

- Write for the person reviewing the code, not for a changelog reader or
  the original requester — be concise, one sentence per point.
- Only claim testing was done if you can see it (existing tests covering
  the change, or tests you added/ran) — don't assert "tested manually"
  when you didn't.
- If the repo has a customer-facing changelog convention (many do — check
  Step 1's sources for the exact required format), follow that format
  exactly, including any required prefix words. Get this from the repo's
  own docs, not from a generic guess — the exact wording/format
  requirement varies by repo and getting it wrong is a common review
  nit.
- If the repo requires specific PR metadata (labels, `--repo` target,
  reviewers), note what you'll pass to `gh pr create` so the approval step
  covers it too.

## Step 4 — Get explicit approval before creating anything

Opening a PR is visible to other people and not trivially reversible —
always show the drafted title and full body in the conversation and wait
for the user to approve or edit it before running `gh pr create`. This
holds even if the user's original request sounded like a green light to
"just do it" — drafting and creating are two different commitments, and
the draft is the one point where a wrong assumption is cheap to fix.

Once approved:

```bash
git push -u <remote> <branch>   # only if the branch isn't already pushed, and only after confirming this is wanted
gh pr create --repo <owner/repo> --title "..." --body "$(cat <<'EOF'
...
EOF
)" [--label ... ] [other required flags from Step 1]
```

Use a heredoc for `--body` so formatting survives; don't inline
newline-heavy text as a shell argument. If pushing the branch is needed and
wasn't already implied by the user's request, confirm that too — it's a
separate action from opening the PR itself.

Report back the PR URL that `gh pr create` returns.
