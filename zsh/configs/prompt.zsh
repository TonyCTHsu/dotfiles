# Initialize pure prompt: https://github.com/sindresorhus/pure

# Guard against re-sourcing: rerunning `prompt pure` in the same shell
# can stack stale precmd state, causing the prompt header to be printed
# multiple times per Enter.
if [[ -z $prompt_pure_loaded ]] && [[ -n $HOMEBREW_PREFIX ]]; then
  fpath+="$HOMEBREW_PREFIX/share/zsh/site-functions"
  autoload -U promptinit; promptinit

  PURE_GIT_PULL=0

  zstyle :prompt:pure:git:branch color green

  prompt pure
  typeset -g prompt_pure_loaded=1
fi