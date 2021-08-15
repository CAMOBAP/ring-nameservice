.PHONY: contract clean run geth
.DEFAULT_GOAL: all

GETH_DATADIR ?= data
GETH_ACCOUNT_PATH ?= $(GETH_DATADIR)/passwd
GETH_ACCOUNT_PASSWD ?= "toto"

all: contract

contract:
	$(MAKE) -C contract

clean:
	$(MAKE) -C clean
	rm -rf $(GETH_DATADIR)

$(GETH_DATADIR):
	geth --datadir $(GETH_DATADIR) init instructions/genesis.json

accountAddress.txt $(GETH_ACCOUNT_PATH): $(GETH_DATADIR)
	echo $(GETH_ACCOUNT_PASSWD) > $(GETH_ACCOUNT_PATH)
	geth --datadir $(GETH_DATADIR) --password $(GETH_ACCOUNT_PATH) account new
	geth --datadir $(GETH_DATADIR) --verbosity 0 account list | awk -F'[{}]' '0x{print $2}' > accountAddress.txt

geth:
	geth --datadir $(GETH_DATADIR) --syncmode=full --networkid 1551 --allow-insecure-unlock \
		--http --http.addr 0.0.0.0 --http.api eth,net,web3,personal,admin  --netrestrict="127.0.0.1/8" \
		--bootnodes "enode://11ba6d3bfdc29a8afb24dcfcf9a08c8008005ead62756eadb363523c2ca8b819efbb264053db3d73949f1375bb3f03090f44cacfb88bade38bb6fc2cb3d890a5@173.231.120.228:30301" console

package-lock.json node_modules: package.json
	npm install yarn
	yarn install

run: package-lock.json contractAddress.txt
	node index.js

contractAddress.txt: $(GETH_DATADIR) contract accountAddress.txt
	node deploy_contract.js > contractAddress.txt
