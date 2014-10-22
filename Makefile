prefix  := /usr/local
bin     := $(prefix)/bin

scripts := viack git-grep-with-smartcase git-grep-or-ag
aliases := viag git-viack git-viag git-vigrep

install:
	@install -dv $(bin)
	@install -cv $(scripts) $(bin)
	@for alias in $(aliases); do ln -snfv $(bin)/viack $(bin)/$$alias | perl -pe 'print "symlink: "'; done

uninstall:
	@rm -v $(patsubst %,$(bin)/%,$(scripts) $(aliases)) \
		| perl -pe 'print "rm: "'
