.PHONY: clean

SOLC ?= solc

ifeq ($(SOLC),solcjs)
	SOLC_OPTS := --base-path $(realpath .)
else
	SOLC_OPTS := --allow-paths $(realpath .)
endif

registrar.out.json: registrar.sol build.json
	$(SOLC) $(SOLC_OPTS) --standard-json < build.json > registrar.out.json

clean:
	rm -rf registrar.out.json