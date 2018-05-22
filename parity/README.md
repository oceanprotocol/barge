# Instructions to run a Parity dev node using Docker Compose
### Pre-requisites 
* Docker
* Docker-compose

### Run a private network based on this repository
* Download/clone the files in this repository
`git clone https://github.com/oceanprotocol/docker-images.git`
* cd into `parity`
* Run: `docker-compose up -d`
* This will run 3 validator/authority nodes and 3 user nodes

### Add more authority nodes to the base network
* Run the private network as described above
* Create a new validator account:
    `curl --data '{"jsonrpc":"2.0","method":"parity_newAccountFromPhrase","params":["nodeX", "nodeX"],"id":0}' -H "Content-Type: application/json" -X POST localhost:8545`
  * Returns something like this: `{"jsonrpc":"2.0","result":"0x00aa39d30f0d20ff03a22ccfc30b7efbfca597c2","id":0}`
* Copy the file `parity/keys/UTC--2018-05-22T13-53-28Z--ed4d9a7c-4206-bbf3-673c-fdd1d41b4dcb` to `parity/authorities` and rename it to `validatorX.json` (pick a better name) then modify the contents to indent properly
* Add a simple text file named `validatorX.pwd` in `parity/authorities` and add the password `nodeX` (or whatever was specified in the "params":["nodeX", "nodeX"])
* Copy/paste one of the validator specs in the docker-compose.yml file and modify it to reflect the new node name and make sure to point to the new `validatorX.json` and `validayorX.pwd` files. 
  * Also specify the address in the --engine-signer option
  * And add the name in the volumes section in the compose file
* Make a copy of `parity/node0.network.key` and modify the key inside this file (anything should do)

  