.PHONY: contract clean run geth
.DEFAULT_GOAL: all

GETH_DATADIR ?= data
GETH_ACCOUNT_PATH ?= $(GETH_DATADIR)/passwd

all: contract

contract:
	$(MAKE) -C contract

clean:
	$(MAKE) -C contract clean
	rm -rf $(GETH_DATADIR) accountAddress.txt contractAddress.txt

$(GETH_DATADIR)/geth/nodekey: $(GETH_DATADIR)/genesis.json
	geth --datadir $(GETH_DATADIR) init $(GETH_DATADIR)/genesis.json

$(GETH_DATADIR)/genesis.json: accountAddress.txt
	cat instructions/genesis.json | awk '{gsub(/29B5638EB1440f715EB65E6ff1879dCA633A6Adf/,"$(shell cat accountAddress.txt)")}1' > $(GETH_DATADIR)/genesis.json
	# cp instructions/genesis.json $(GETH_DATADIR)/genesis.json

accountAddress.txt: $(GETH_ACCOUNT_PATH)
	echo $(shell openssl rand -base64 32) > $(GETH_ACCOUNT_PATH)
	geth --datadir $(GETH_DATADIR) --password $(GETH_ACCOUNT_PATH) account new
	geth --datadir $(GETH_DATADIR) --verbosity 0 account list | awk -F'[{}]' '{printf $$2}' > accountAddress.txt

$(GETH_ACCOUNT_PATH):
	mkdir -p $(shell dirname $(GETH_ACCOUNT_PATH))
	echo $(GETH_ACCOUNT_PASSWD) > $(GETH_ACCOUNT_PATH)

geth: $(GETH_DATADIR)/geth/nodekey
	geth --datadir $(GETH_DATADIR) --syncmode=full --networkid 1551 --allow-insecure-unlock --nodiscover \
		--http --http.addr 127.0.0.1 --http.api eth,net,web3,personal,admin  --netrestrict="127.0.0.1/8" \
		--bootnodes "enode://11ba6d3bfdc29a8afb24dcfcf9a08c8008005ead62756eadb363523c2ca8b819efbb264053db3d73949f1375bb3f03090f44cacfb88bade38bb6fc2cb3d890a5@173.231.120.228:30301" console

node_modules: package.json
	yarn install

run: node_modules contractAddress.txt
	node index.js

contractAddress.txt: contract accountAddress.txt
	# node deploy_contract.js > contractAddress.txt contract now embed in genesis
	echo "0000000000000000000000000000000000000001" > contractAddress.txt

# https://github.com/ethereum/go-ethereum/issues/19699