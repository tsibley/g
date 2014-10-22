prefix  := /usr/local
bin     := $(prefix)/bin

aliases := viag git-viack git-viag git-vigrep

install:
	@install -dv $(bin)
	@install -cv viack git-grep-with-smartcase $(bin)
	@for alias in $(aliases); do ln -snfv $(bin)/viack $(bin)/$$alias | perl -pe 'print "symlink: "'; done

uninstall:
	@rm -v $(bin)/viack $(patsubst %,$(bin)/%,$(aliases)) $(bin)/git-grep-with-smartcase \
		| perl -pe 'print "rm: "'
