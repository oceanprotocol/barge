# Ocean private test net using Proof Of Authority consensus
### Setup

0. Install [docker](https://docs.docker.com/engine/installation/) and [docker-compose](https://docs.docker.com/compose/install/)
1. Run `git clone https://github.com/oceanprotocol/docker-images.git`
2. Run `cd docker-images/parity`
3. Run `docker-compose up ` (add `-d` to run in daemon mode)
4. This will run 3 validator/authority nodes and 1 user node

### Access JSON RPC 
Access JSON RPC at [http://127.0.0.1:8545](http://127.0.0.1:8545).

### Some handy curl commands

### Send transaction
```
curl --data '{"jsonrpc":"2.0","method":"personal_sendTransaction","params":[{"from":"0x<address>","to":"0x<address>","value":"0x<value>"}, "<password if any>"],"id":0}' -H "Content-Type: application/json" -X POST localhost:8545
```

#### Unlock account
replace `null` with number of seconds to indicate how long account will be unlocked
Account address goes in the first param (here is's just "0x")
```
curl --data '{"method":"personal_unlockAccount","params":["0x","hunter2",null],"id":1,"jsonrpc":"2.0"}' -H "Content-Type: application/json" -X POST localhost:8545

```

### New account
Using just a password
```
curl --data '{"method":"personal_newAccount","params":["password-hunter2"],"id":1,"jsonrpc":"2.0"}' -H "Content-Type: application/json" -X POST localhost:8545
```

Using a recovery phrase and password
```
curl --data '{"method":"parity_newAccountFromPhrase","params":["stylus outing overhand dime radial seducing harmless uselessly evasive tastiness eradicate imperfect","hunter2"],"id":1,"jsonrpc":"2.0"}' -H "Content-Type: application/json" -X POST localhost:8545
```

Refer to these sources for more goodies:
* https://github.com/paritytech/wiki
* https://github.com/paritytech/wiki/blob/master/JSONRPC-personal-module.md
* https://github.com/paritytech/wiki/blob/master/JSONRPC-parity_accounts-module.md

### Instructions to add a validator node using Docker Compose
* Run the private network as described above
* Create a new validator account:
    `curl --data '{"jsonrpc":"2.0","method":"parity_newAccountFromPhrase","params":["nodeX-phrase", "nodeX-password"],"id":0}' -H "Content-Type: application/json" -X POST localhost:8545`
  * Returns something like this: `{"jsonrpc":"2.0","result":"0x00aa39d30f0d20ff03a22ccfc30b7efbfca597c2","id":0}`
* Copy the file `parity/keys/UTC--2018-05-22T13-53-28Z--ed4d9a7c-4206-bbf3-673c-fdd1d41b4dcb` to `parity/authorities` and rename it to `validatorX.json` (pick a better name) then modify the contents to improve indentation (optional)
* Add a simple text file named `validatorX.pwd` in `parity/authorities` and add the password `nodeX-password` (or whatever was specified in the "params":["nodeX-phrase", "nodeX-password"])
* Copy/paste a validator image definition section in the docker-compose.yml file and modify it to reflect the new node name and make sure to point to the new `validatorX.json` and `validayorX.pwd` files.
  * This is what will be added to the docker-compose.yml file:
```
  validatorX:
    image: parity/parity:stable
    command:
      --config /parity/config/validator.toml
      --engine-signer 0x00aa39d30f0d20ff03a22ccfc30b7efbfca597c2
    volumes:
      - ./parity/config:/parity/config:ro
      - validatorX:/root/.local/share/io.parity.ethereum/
      - ./parity/authorities/validatorX.json:/root/.local/share/io.parity.ethereum/keys/${NETWORK_NAME}/validator.json:ro
      - ./parity/authorities/validatorX.pwd:/parity/validator.pwd:ro
      - ./parity/nodeX.network.key:/root/.local/share/io.parity.ethereum/network/key:ro
    networks:
      my_net:
        ipv4_address: 172.16.0.13

``` 
  * Make sure to assign a new `ipv4_address` address
  * Specify the new account address in the --engine-signer option
  * And add the name in the volumes section in the compose file:
```
volumes:
  validator0:
  validator1:
  validator2:
  validatorX:

```
* Generate a new bootnode key and add it here `docker-images/parity/parity/nodeX.network.key`
* Get an enode address and add it in both `member.toml` and `validator.toml` files in the bootnodes list under `[network]`
* Update the validators list in `chain.json` by adding the new account to the existing list


## Notes
* We ran into an issue with running smart contracts where a function in one contract fails if it calls a function of another contract
  * This problem is fixed by adding the following lines to the `chain.json` file to enable byzantium mode in the EVM:
```
 "eip140Transition": 0,
 "eip211Transition": 0,
 "eip214Transition": 0,
 "eip658Transition": 0
```
  * The problem is reported in `https://github.com/paritytech/parity/issues/8503` and `https://github.com/ethereum/solidity/issues/3969`
  
## The ocean test net
The private test net is running on Azure VM `ocn-hackaton` with ip address `40.115.16.244`

To connect to the network, provide the ip address and use port `8545`

To deploy keeper-contracts, use the following in your truffle.js file:
```
ocean_poa_net: {
    host: 'http://40.115.16.244',
    port: 8545,
    network_id: '*',
    gas: 6000000,
    from: "0x00bd138abd70e2f00903268f3db08f2d25677c9e"
},
```