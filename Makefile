
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
	
install: bin/kiwi
	@cp bin/kiwi $(DEST)/kiwi
	
uninstall: $(DEST)/kiwi
	@rm $(DEST)/kiwi
	
.PHONY: test