# Color constants available to the prompt
autoload -U colors
colors

if [[ "$(uname)" == "Darwin" ]]; then
  # BSD ls reads LSCOLORS
  export CLICOLOR=1
  # Make directories bright cyan (much easier to read on dark backgrounds)
  export LSCOLORS=Gxfxcxdxbxegedabagacad
else
  # GNU ls ignores LSCOLORS and needs --color=auto. Bright cyan dirs
  # match the macOS scheme.
  export LS_COLORS='di=01;36:ln=01;35:ex=01;32'
  alias ls='ls --color=auto'
fi
