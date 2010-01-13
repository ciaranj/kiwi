
SPEC = spec
DEST = /usr/bin

all: clean bin/kiwi

clean:
	@rm -fr bin

bin/kiwi: lib/kiwi
	@mkdir -p bin
	@cp lib/kiwi bin/kiwi
	@chmod 0755 bin/kiwi

test: clean bin/kiwi server
	@$(SPEC) spec --color --format specdoc
	
server:
	@cd server && rackup -p 8888 -s thin
	
install: bin/kiwi
	@cp bin/kiwi $(DEST)/kiwi
	
uninstall: $(DEST)/kiwi
	@rm $(DEST)/kiwi
	
.PHONY: install uninstall clean server test