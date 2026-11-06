# Load the personal signing key into the agent once per boot. The
# first shell after login prompts for the passphrase; later shells
# see the key already loaded in the shared agent.
if [[ "$(uname)" == "Linux" ]] && [[ -n "$SSH_AUTH_SOCK" ]] && [[ -S "$SSH_AUTH_SOCK" ]]; then
  ssh-add -l >/dev/null 2>&1 || ssh-add "$HOME/.ssh/id_github_signing" >/dev/null 2>&1
fi
