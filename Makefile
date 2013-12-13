PREFIX=$(HOME)
BIN=$(PREFIX)/bin

install: $(BIN)/viack $(BIN)/git-grep-with-smartcase

$(BIN)/viack: viack
	@install -Cv $< $@

$(BIN)/git-grep-with-smartcase: git-grep-with-smartcase
	@install -Cv $< $@

git-aliases:
	@echo '==> Adding git aliases'
	git alias ack "grep-with-smartcase -I --perl-regexp --break --heading --line-number"
	git alias  ag "grep-with-smartcase -I --perl-regexp --break --heading --line-number"
