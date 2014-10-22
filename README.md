# vim ♥ ack

viack opens the results of your ack search in vim.

For maximum Getting Out Of The Way, it invokes vim with a variety of options
for stepping through results.

1. All matching files are loaded in the file list.  You can use `:n` to go the
   next file.

2. The search pattern is preloaded into the current search as a vim-compatibile
   regular expression (translated from ack/ag's PCRE).  You can use `n` to skip
   around in a file between matches.  If you enable persistent search
   highlighting in vim, you'll see matches highlighted.

3. The quickfix list is populated with the hits so that `:cn` will jump to the
   line of the next result, moving to the next file as necessary.

# Aliases

viack is aliased as viag in case you want to search using ag instead of ack.
It also integrates with git as:

* git viack
* git viag
* git vigrep

all of which use `git grep` to do the searching (tuned to accept PCRE and
otherwise act compatible to ack/ag).

# git ack/ag support via git-grep-with-smartcase

Adding two git aliases `ack` and `ag` to complement `viack` and `viag` is
suggested for maximal convenience and the least amount of finger retraining.
You can do so by running:

    git alias ack "grep-with-smartcase -I --perl-regexp --break --heading --line-number"
    git alias ag  "grep-with-smartcase -I --perl-regexp --break --heading --line-number"

I also like to make the default filename and line number colors match ack's:

    git config color.grep.filename "green bold"
    git config color.grep.linenumber blue

# vim `:grep` support with git-grep-or-ag

If you find yourself using the `:grep` command to search files and load up the
quickfix list from within vim, you opportunistically use `git grep` and
fallback to `ag` if not in a git repo.  In your `.vimrc`, put:

    set grepprg=git-grep-or-ag

# Installation

viack requires only Perl and the modules that ship with core Perl.  Of course,
you have to have ack/ag installed too.  Installation is as simple as:

    make install prefix=/usr/local

You can uninstall just as easily with:

    make uninstall prefix=/usr/local

Just adjust prefix if you need a different path.
