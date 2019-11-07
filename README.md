A DWIM wrapper for GNU grep and git grep that can open up matches for
editing/reviewing in vim.

    usage: g [opts] <pattern> [<paths>]
           g [opts] <pattern> [<paths>] /v[i[mg]]
           vig [opts] <pattern> [<paths>]

Use `g` like grep, but with PCRE patterns and nicer default formatting for
readability.

Use `vig` the same way, but when you want to edit the matches in vim.

For maximum Getting Out Of The Way, vim is invoked with a variety of options
for stepping through results.

1. All matching files are loaded in the file list.  You can use `:n` to go the
   next file.

2. The search pattern is preloaded into the current search as a vim-compatibile
   regular expression (translated from PCRE).  You can use `n` to skip around
   in a file between matches.  If you enable persistent search highlighting in
   vim, you'll see matches highlighted.

3. The quickfix list is populated with the hits so that `:cn` will jump to the
   line of the next result, moving to the next file as necessary.

If you find yourself using the `:grep` command to search files and load up the
quickfix list from within vim, you can tell vim to use `g` by putting the
following in your `.vimrc`:

    set grepprg=g

For convenience, you can also invoke `vig` by appending `/vig` or `/vim` (or
a shortened prefix) to a `g` command line.  This is handy when combined with
Bash's history recall (e.g. Ctrl-P or the up arrow).

## Installation

`g` requires only Perl and the modules that ship with core Perl.  Installation
is as simple as:

    make install prefix=/usr/local

You can uninstall just as easily with:

    make uninstall prefix=/usr/local

Just adjust prefix if you need a different path.

## Colors

I like to make the default filename and line number colors used by `git grep`
match GNU `grep`'s:

    git config --global color.grep.filename "green bold"
    git config --global color.grep.linenumber blue
