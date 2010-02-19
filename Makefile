
SPEC = spec
DEST = /usr/bin

all: test

test: bin/kiwi
	@$(SPEC) spec --color
	
test-server:
	@cd server && $(SPEC) spec -r spec/spec_helper --color
	
server-start:
	@thin -c server --rackup config.ru start -p 8888 -d -P server.pid
	
server-stop:
	@cat server/server.pid | xargs kill -TERM
	
install: bin/kiwi
	install bin/kiwi $(DEST)/kiwi
	
uninstall: $(DEST)/kiwi
	rm $(DEST)/kiwi
	
.PHONY: install uninstall server-start server-stop test test-server