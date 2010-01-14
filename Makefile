
SPEC = spec
BIN_DEST = /usr/bin
LIB_DEST = /usr/lib/kiwi

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
	install bin/kiwi $(BIN_DEST)/kiwi
	mkdir -p $(LIB_DEST)
	cp -fr server $(LIB_DEST)/server
	
uninstall: $(BIN_DEST)/kiwi
	rm $(BIN_DEST)/kiwi
	rm -fr $(LIB_DEST)
	
.PHONY: install uninstall clean server-start server-stop test