# Initialize pure prompt: https://github.com/sindresorhus/pure

if command -v brew >/dev/null 2>&1; then
  fpath+="$(brew --prefix)/share/zsh/site-functions"
  autoload -U promptinit; promptinit

  PURE_GIT_PULL=0

  zstyle :prompt:pure:git:branch color green

  prompt pure
fi