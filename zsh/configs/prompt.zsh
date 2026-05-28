# Initialize pure prompt: https://github.com/sindresorhus/pure

if [[ -n $HOMEBREW_PREFIX ]]; then
  fpath+="$HOMEBREW_PREFIX/share/zsh/site-functions"
  autoload -U promptinit; promptinit

  PURE_GIT_PULL=0

  zstyle :prompt:pure:git:branch color green

  prompt pure
fi