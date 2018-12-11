[![banner](https://raw.githubusercontent.com/oceanprotocol/art/master/github/repo-banner%402x.png)](https://oceanprotocol.com)

<h1 align="center">docker-images</h1>

> 🐳 Docker images and Compose for the full Ocean Protocol Network stack.
> [oceanprotocol.com](https://oceanprotocol.com)

---

**🐲🦑 THERE BE DRAGONS AND SQUIDS. This is in alpha state and you can expect running into problems. If you run into them, please open up [a new issue](https://github.com/oceanprotocol/docker-images/issues). 🦑🐲**

---

## Table of Contents

  - [Prerequisites](#prerequisites)
  - [Get Started](#get-started)
     - [Script Options](#script-options)
  - [Docker Building Blocks](#docker-building-blocks)
    - [Pleuston](#pleuston)
    - [Aquarius](#aquarius)
    - [Brizo](#brizo)
    - [Keeper Node](#keeper-node)
    - [Secret Store](#secret-store)
  - [Spree Network](#spree-network)
  - [Nile Network](#nile-network)
  - [Contributing](#contributing)
  - [License](#license)
  
---

## Prerequisites

You need to have the newest versions available of both:

* [Docker](https://www.docker.com/get-started)
* [Docker Compose](https://docs.docker.com/compose/)
* Linux/MacOS. Currently Windows OS is not supported.

**To run as a publisher:** `Brizo` configuration must be set with valid Azure account credentials. This is done in the file [`brizo.env`](./brizo.env). Follow our tutorial [Set up Azure Storage](https://docs.oceanprotocol.com/tutorials/azure-for-brizo/) to learn how to get those credentials.

## Get Started

Then bring up an instance of the whole Ocean Protocol network stack with the `./start_ocean.sh` script:

```bash
git clone git@github.com:oceanprotocol/docker-images.git
cd docker-images/

./start_ocean.sh
```

<img width="535" alt="screen shot 2018-10-10 at 12 20 48" src="https://user-images.githubusercontent.com/90316/46729966-22206600-cc87-11e8-9e1a-156d8a6c5e43.png">

---

This will bring up the `stable` versions of all components, referring to their respective `master` branches.

To get the `latest` versions of all components, referring to their `develop` branches, pass the argument `--latest`:
 
```bash
./start_ocean.sh --latest
```

After getting everything running, you can open the **Pleuston Frontend** application in your browser:

[http://localhost:3000](http://localhost:3000)

### Script Options

The `./start_ocean.sh` script provides the following options:

Option                      | Description
----------------------------| -----------
`--latest`                  | Get the `latest` versions of all components instead of `stable`, referring to their `develop` branches.
`--no-pleuston`             | Start up Ocean without the `pleuston` Building Block. Helpful for development on `pleuston`.
`--no-aquarius`             | Start up Ocean without the `aquarius` Building Block.
`--no-brizo`                | Start up Ocean without the `brizo` Building Block.
`--no-secret-store`         | Start up Ocean without the `secret-store` Building Block.
`--local-ganache-node`      | Runs a local `ganache` node.
`--local-spree-node`        | Runs a node of the local `spree` network.
`--local-nile-node`         | Runs a node of the `nile` network and connects the node to the `nile` network.
`--local-kovan-node`        | Runs a light node of the `kovan` network and connects the node to the `kovan` network.
`--reuse-ganache-database`  | Configures a running `ganache` node to use a persistent database.
`--purge`                   | Removes the containers, volumes, artifact folder and networks used by the script.

## Docker Building Blocks

Ocean compose consists of a set of building blocks that can be combined to form a local test environment. By default all building blocks will be started with the `./start_ocean.sh` script.

### Pleuston

By default it will start one container. This Building Block can be disabled by setting the `--no-pleuston` flag. 

Hostname   | External Port | Internal Url          | Local Url             | Description
-----------|---------------|-----------------------|-----------------------|--------------
`pleuston` | `3000`        | http://pleuston:3000  | http://localhost:3000 | [Pleuston](https://github.com/oceanprotocol/pleuston)

### Aquarius

By default it will start two containers. This Building Block can be disabled by setting the `--no-aquarius` flag. 

Hostname   | External Port | Internal Url         | Local Url             | Description
-----------|---------------|----------------------|-----------------------|--------------
`aquarius` | `5000`        | http://aquarius:5000 | http://localhost:5000 | [Aquarius](https://github.com/oceanprotocol/aquarius)
`mongodb`  |               |                      |                       | MongoDB used by Aquarius

### Brizo

By default it will start one container. This Building Block can be disabled by setting the `--no-brizo` flag. 

Hostname   | External Port | Internal Url       | Local Url             | Description
-----------|---------------|--------------------|-----------------------|--------------
`brizo`    | `8030`        | http://brizo:8030  | http://localhost:8030 | [Brizo](https://github.com/oceanprotocol/brizo)

### Keeper Node

Controlled by the `--local-*-node` config switches will start a container `keeper-node` that uses port `8545` to expose an rpc endpoint to the Ethereum Protocol.
You can find a detailed explanation of how to use this in the [script options](#script-options) section of this document.

Hostname      | External Port | Internal Url            | Local Url             | Description
--------------|---------------|-------------------------|-----------------------|--------------
`keeper-node` | `8545`        | http://keeper-node:8545 | http://localhost:8545 | An Ethereum RPC node

This node can be one of the following types:

Node      | Description
----------|-------------
`ganache` | Runs a local `ganache-cli` node that is not persistent by default. The contracts from the desired `keeper-contracts` version will be deployed upon launch of this node.
`spree`   | Runs a local node of the `spree` network. See [Spree Network](#spree-network) for details. The contracts from the desired `keeper-contracts` version will be deployed upon launch of this node.
`nile`    | Runs an instance of the `nile` network and connects to the Nile testnet. See [Nile Network](#nile-network) for details.
`kovan`   | Runs an instance of the `kovan` network and connects to the Kovan testnet.

### Secret Store

By default it will start three container. This Building Block can be disabled by setting the `--no-secret-store` flag. 

Hostname                    | External Ports   | Internal Url                          | Local Url              | Description
----------------------------|------------------|---------------------------------------|------------------------|--------------
`secret-store`              | `12000`, `32771` | http://secret-store:12000             | http://localhost:12000 | An instance of the Ocean Secret Store
`secret-store-cors-proxy`   | `12001`          | http://secret-store-cors-proxy:12001  | http://localhost:12001 | A nginx proxy to enable CORS on the secret store
`secret-store-signing-node` | `9545`           | http://secret-store-signing-node:9545 | http://localhost:9545  | A parity node to `sign` messages for the secret store and to `decrypt` and `encrypt`

### Spree Network

If you run the `./start_ocean.sh` script with the `--local-spree-node` option (please see [Keeper Node](#keeper-node) section of this document for more details).
You will have available a keeper node in the local and private `spree` network with the following accounts enabled:

Account                                      | Password   | Balance    
---------------------------------------------|------------|--------
`0x00bd138abd70e2f00903268f3db08f2d25677c9e` | node0      | 10000000111000111000111000
`0x068ed00cf0441e4829d9784fcbe7b9e26d4bd8d0` | secret     | 100000000
`0xa99d43d86a0758d5632313b8fa3972b6088a21bb` | secret     | 100000000

Use one of the above accounts to populate `PARITY_ADDRESS` and `PARITY_PASSWORD` in `brizo.env` file to avoid account `locked` issues from the keeper contracts.

### Nile Network

Please see [Nile Testnet](https://docs.oceanprotocol.com/concepts/testnets/#nile-testnet) for details.

## Contributing

See the page titled "[Ways to Contribute](https://docs.oceanprotocol.com/concepts/contributing/)" in the Ocean Protocol documentation.

## License

```text
Copyright 2018 Ocean Protocol Foundation

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
