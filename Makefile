
SPEC = spec

test:
	@$(SPEC) spec --color --format specdoc
	
.PHONY: test