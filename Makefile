
SPEC = spec
DEST = /usr/local/bin
DOC_DEST = /usr/local/etc/kiwi
LIB_DEST = ~/.node_libraries

all: test

test: bin/kiwi
	@$(SPEC) spec --color
	
test-server:
	@cd server && $(SPEC) spec -r spec/spec_helper --color
	
server-start:
	@thin -e test -c server --rackup config.ru start -p 8888 -d -P server.pid -l server.log
	
server-stop:
	@cat server/server.pid | xargs kill -TERM
	
install: bin/kiwi
	install bin/kiwi $(DEST)/kiwi
	install lib/kiwi.js $(LIB_DEST)/kiwi.js
	mkdir -p $(DOC_DEST)
	cp -fr docs $(DOC_DEST)
	
uninstall: $(DEST)/kiwi
	rm $(DEST)/kiwi
	rm $(LIB_DEST)/kiwi.js
	rm -fr $(DOC_DEST)
	
.PHONY: install uninstall server-start server-stop test test-server