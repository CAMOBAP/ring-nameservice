#!/usr/bin/env node

const Web3 = require('web3');
const fs = require('fs');

const sender = "0x" + fs.readFileSync("./accountAddress.txt", { encoding : "utf-8" }).trim();
const passwd = fs.readFileSync("./data/passwd", { encoding : "utf-8" }).trim();

const web3 = new Web3();
web3.setProvider(new web3.providers.HttpProvider('http://localhost:8545'));
web3.eth.personal.unlockAccount(sender, passwd, 10);

function contract(web3) {
  const json = JSON.parse(fs.readFileSync("./contract/registrar.out.json", { encoding : "utf-8" }));
  const contract = json.contracts.registrar.GlobalRegistrar;
  const data = '0x' + contract.evm.bytecode.object;
  return new web3.eth.Contract(contract.abi, { data }); 
}

async function main() {
  const registrarContract = contract(web3);
  const instance = await registrarContract.deploy().send({ from: sender, gas: 1000000 });
  const address = instance.options.address;
  console.log(address);
}

main();