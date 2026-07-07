# makes color constants available
autoload -U colors
colors

# enable colored output from ls, etc. on FreeBSD-based systems
export CLICOLOR=1

# Make directories bright cyan (much easier to read on dark backgrounds)
export LSCOLORS=Gxfxcxdxbxegedabagacad
