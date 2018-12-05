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
  - [Ocean Protocol components](#ocean-protocol-components)
     - [Environment Variables](#environment-variables)
     - [Parity Client Accounts](#parity-client-accounts)
  - [Contributing](#contributing)
  - [License](#license)

---

## Prerequisites

You need to have the newest versions available of both:

* [Docker](https://www.docker.com/get-started)
* [Docker Compose](https://docs.docker.com/compose/)

Populate the following in `brizo.env` file:
* All of the `AZURE_`... related variables: necessary for `Brizo` to serve consume requests

## Get Started

Then bring up an instance of the whole Ocean Protocol network stack with the `start_ocean.sh` script:

```bash
git clone git@github.com:oceanprotocol/docker-images.git
cd docker-images/

./start_ocean.sh
```

<img width="535" alt="screen shot 2018-10-10 at 12 20 48" src="https://user-images.githubusercontent.com/90316/46729966-22206600-cc87-11e8-9e1a-156d8a6c5e43.png">

This will bring up the `stable` versions of all components, referring to their respective `master` branches.

To get the `latest` versions of all components, referring to their `develop` branches, pass the argument `--latest`:

To run as a publisher, `Brizo` configuration must be set with valid Azure account credentials. This is done in

```bash
./start_ocean.sh --latest
```

After getting everything running, you can open the **Pleuston Frontend** application in your browser:

[http://localhost:3000](http://localhost:3000)

### Script Options

The `start_ocean.sh` script provides the following options:

Option | Description
---    | ---
`--latest` | Get the `latest` versions of all components, referring to their `develop` branches.
`--no-pleuston` | Start up Ocean without an instance of `pleuston`. Helpful for development on `pleuston`.
`--local-secret-store` | Runs a local parity POA node and Secret Store instead of ganache-cli.
`--reuse-database` | Start up Ocean and reuse the Database from ganache. Helpful for development.
`--testnet-parity-node` | Start up a parity client connected to Ocean testnet.
`--kovan-parity-node` | Start up a parity client connected to Kovan testnet.
`--purge` | Remove the volumes, local folder and networks used by the script.

For example, if you do:

```bash
./start_ocean.sh --latest
```

then the main/default [docker-compose.yml](docker-compose.yml) will be used, so the following Docker images will all be started:

- mongo:3.6
- oceanprotocol/keeper-contracts:latest
- oceanprotocol/aquarius:latest
- oceanprotocol/brizo:latest
- oceanprotocol/pleuston:latest

To see what ports each of those listens on, read [docker-compose.yml](docker-compose.yml). Note that `keeper-contracts` runs a local Ganache node (not a local Parity Ethereum POA node).

If you do:

```bash
./start_ocean.sh --no-pleuston
```

then [docker-compose-no-pleuston.yml](docker-compose-no-pleuston.yml) will be used, so these images will be started:

- mongo:3.6
- oceanprotocol/keeper-contracts:stable
- oceanprotocol/aquarius:stable
- oceanprotocol/brizo:stable

If you do:

```bash
./start_ocean.sh --latest --local-secret-store
```

then [docker-compose-local-secret-store.yml](docker-compose-local-secret-store.yml) will be used. Note that it _doesn't_ start Pleuston, and it _does_ start a Parity Secret Store. The images that are started would be:

- mongo:3.6
- oceanprotocol/parity-ethereum:master (for parity client)
- oceanprotocol/parity-ethereum:master (for secret store)
- nginx:alpine (for secret store cluster)
- oceanprotocol/keeper-contracts:latest
- oceanprotocol/aquarius:latest
- oceanprotocol/brizo:latest

If you do:

```bash
./start_ocean.sh --latest --no-pleuston --local-secret-store
```

then the last-selected Docker Compose file will be used, i.e. the one selected by `--local-secret-store`: [docker-compose-local-secret-store.yml](docker-compose-local-secret-store.yml).

Finally, if you do:

```bash
./start_ocean.sh --testnet-parity-node
```

then `docker-compose-only-parity.yml` Docker Compose file will be used. It will start only one container (`oceanprotocol/parity-ethereum:master`) that will connect to the Ocean testnet network. The parity client is configure to allow connections with the RPC interface.

Or if you do:

```bash
./start_ocean.sh --kovan-parity-node
```

then `docker-compose-only-parity.yml` Docker Compose file will be used. It will start only one container (`oceanprotocol/parity-ethereum:master`) that will connect to the Kovan testnet network. The parity client is configure to allow connections with the RPC interface.

### Connecting to local components

You can connect to the components deployed with these docker compose files. For example, to avoid exposing the unlocked account when running `--kovan-parity-node` or `--testnet-parity-node`, the RPC port (8545) is not exposed locally. In this case, you can get the container ip runing the command:

```bash
PARITY_CLIENT_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker ps | grep 'ocean_parity-node_1_' | cut -d' ' -f1))
echo $PARITY_CLIENT_IP
```

And then using that ip to connect from your host. In case you want to connect from another container, you must attach that container to the same network as the parity client:

```bash
docker run -ti --network ocean_default --rm --entrypoint=/bin/sh oceanprotocol/keeper-contracts:latest

# Now can connect with $PARITY_CLIENT_IP
```

### Parity Client Accounts

If you run the `start_ocean.sh` script with the `--local-secret-store` option, you will have available a Parity Client instance with the following accounts enabled:

Account | Password | Balance
--------|----------|--------
0x00bd138abd70e2f00903268f3db08f2d25677c9e | node0 | 10000000111000111000111000
0x068ed00cf0441e4829d9784fcbe7b9e26d4bd8d0 | secret | 100000000
0xa99d43d86a0758d5632313b8fa3972b6088a21bb | secret | 100000000


Use one of the above accounts to populate `PARITY_ADDRESS` and `PARITY_PASSWORD` in `brizo.env` file to avoid asccount `locked` issues from the keeper contracts.

### Environment Variables

The `start_ocean.sh` script and `.env` file sets defaults for the following environment variables but you can use these in combination with the Docker Compose files for further customization, e.g.:

```bash
export REUSE_DATABASE="true"
docker-compose --project-name=ocean -f docker-compose-no-pleuston.yml up
```

Variable | Description
---      | ---
`REUSE_DATABASE` | The keeper-contracts component runs with ganache by default and every run will produce and deploy new instances of the keeper contracts. Ganache can be run with a specific database path by setting the env var `REUSE_DATABASE` to `"true"`. By default, the ganache database will be setup in the cwd.
`DEPLOY_CONTRACTS` | skip deploying smart contracts by setting this to `"false"`, in this case `REUSE_DATABASE` should be set to `"true"` in the previous run when using ganache
`KEEPER_NETWORK_NAME` | set to one of `"ganache"` (default), `"kovan"`, or `"ocean_poa_net_local"`
`ARTIFACTS_FOLDER` | this is where the deployed smart contracts abi files will be available. This can be pointed at any path you like.

In addition to these variables, when running Brizo you need to provide the Azure credentials to allow Brizo to connect to Azure. These variables can be configured in the file `brizo.env`.

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
