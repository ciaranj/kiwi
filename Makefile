
SPEC = spec
DEST = /usr/bin

all: clean bin/kiwi

clean:
	@rm -fr bin

bin/kiwi: lib/kiwi
	@mkdir -p bin
	@cp lib/kiwi bin/kiwi
	@chmod 0755 bin/kiwi

test: clean bin/kiwi
	@$(SPEC) spec --color --format specdoc
	
server-start:
	@thin -c server --rackup config.ru start -p 8888 -d -P server.pid
	
server-stop:
	@cd server && cat server.pid | xargs kill -TERM
	
install: bin/kiwi
	@cp bin/kiwi $(DEST)/kiwi
	
uninstall: $(DEST)/kiwi
	@rm $(DEST)/kiwi
	
.PHONY: install uninstall clean server test