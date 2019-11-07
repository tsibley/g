prefix  := /usr/local
bin     := $(prefix)/bin

scripts := g
aliases := vig

install:
	@install -dv $(bin)
	@install -cv $(scripts) $(bin)
	@for alias in $(aliases); do ln -snfv $(bin)/g $(bin)/$$alias | perl -pe 'print "symlink: "'; done

uninstall:
	@rm -v $(patsubst %,$(bin)/%,$(scripts) $(aliases)) \
		| perl -pe 'print "rm: "'
