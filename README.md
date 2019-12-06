[![banner](https://raw.githubusercontent.com/oceanprotocol/art/master/github/repo-banner%402x.png)](https://oceanprotocol.com)

<h1 align="center">barge</h1>

> 🐳 Docker Compose files for the full Ocean Protocol stack.

---

- [Prerequisites](#prerequisites)
- [Get Started](#get-started)
- [Options](#options)
  - [Component Versions](#component-versions)
  - [All Options](#all-options)
- [Docker Building Blocks](#docker-building-blocks)
  - [Commons](#commons)
  - [Aquarius](#aquarius)
  - [Brizo](#brizo)
  - [Events Handler](#events-handler)
  - [Keeper Node](#keeper-node)
  - [Secret Store](#secret-store)
  - [Faucet](#faucet)
  - [Dashboard](#dashboard)
- [Spree Network](#spree-network)
  - [Spree Mnemonic](#spree-mnemonic)
- [Contributing](#contributing)
- [License](#license)

---

## Prerequisites

You need to have the newest versions of:

- Linux or macOS. Windows is not currently supported. If you are on Windows, we recommend running Barge inside a Linux VM. Another option might be to use the [Windows Subsystem for Linux (WSL)](https://en.wikipedia.org/wiki/Windows_Subsystem_for_Linux).
- [Docker](https://www.docker.com/get-started)
- [Docker Compose](https://docs.docker.com/compose/)
- If you want to use Azure Storage with Brizo (and you might not), then you must edit the file [`brizo.env`](./brizo.env) to have your Azure credentials. To learn how to get those credentials, see our tutorial to [Set up Azure Storage](https://docs.oceanprotocol.com/tutorials/azure-for-brizo/).

## Get Started

If you're new to Barge, it's best to start with the defaults:

```bash
git clone git@github.com:oceanprotocol/barge.git
cd barge

./start_ocean.sh
```

That will run the current default versions of Aquarius, Brizo, Events Handler, Commons, Keeper Contracts, and Faucet. It will also run a local Spree network (i.e. `--local-spree-node`).

<img width="486" alt="Welcome to Ocean Protocol" src="Welcome_to_Ocean_Protocol.png">

It's overkill, but to be _sure_ that you use exactly the Docker images and volumes you want, you can prune all the Docker things in your system first:

```bash
docker system prune --all --volumes
```

## Options

The startup script comes with a set of options for customizing various things.

### Component Versions

The default versions are always a combination of component versions which are considered stable.

| Aquarius | Brizo    | Events Handler | Keeper    | Commons  | Faucet   |
| -------- | -------- | -------------- | --------- | -------- | -------- |
| `v1.0.5` | `v0.7.2` | `v0.3.4`       | `v0.12.7` | `v2.0.0` | `v0.3.2` |

You can use the `--latest` option to pull the most recent Docker images for all components, which are always tagged as `latest` in Docker. The `latest` Docker image tag derives from the default main branch of the component's Git repo.

You can override the Docker image tag used for a particular component by setting its associated environment variable before calling `start_ocean.sh`:

- `AQUARIUS_VERSION`
- `BRIZO_VERSION`
- `EVENTS_HANDLER_VERSION`
- `KEEPER_VERSION`
- `COMMONS_CLIENT_VERSION`
- `COMMONS_SERVER_VERSION`
- `FAUCET_VERSION`

For example:

```bash
export BRIZO_VERSION=v0.4.4
./start_ocean.sh
```

will use the default Docker image tags for Aquarius, Keeper Contracts and Commons, but `v0.2.1` for Brizo.

> If you use the `--latest` option, then the `latest` Docker images will be used _regardless of whether you set any environment variables beforehand._

### All Options

| Option                     | Description                                                                                     |
| -------------------------- | ----------------------------------------------------------------------------------------------- |
| `--latest`                 | Pull Docker images tagged with `latest`.                                                        |
| `--no-commons`             | Start up Ocean without the `commons` Building Block. Helpful for development on `commons`.      |
| `--no-aquarius`            | Start up Ocean without the `aquarius` Building Block.                                           |
| `--no-brizo`               | Start up Ocean without the `brizo` Building Block.                                              |
| `--no-events-handler`      | Start up Ocean without the `events-handler` Building Block.                                     |
| `--no-secret-store`        | Start up Ocean without the `secret-store` Building Block.                                       |
| `--no-faucet`              | Start up Ocean without the `faucet` Building Block.                                             |
| `--no-acl-contract`        | Disables the configuration of secret store's ACL contract address                               |
| `--no-dashboard`           | Start up Ocean without the `dashboard` Building Block.                                          |
| `--mongodb`                | Start up Ocean with MongoDB as DB engine for Aquarius instead of Elasticsearch.                 |
| `--local-ganache-node`     | Runs a local `ganache` node.                                                                    |
| `--local-spree-node`       | Runs a node of the local `spree` network. This is the default.                                  |
| `--local-spree-no-deploy`  | Runs a node of the local `spree` network, without contract deployment.                          |
| `--local-duero-node`       | Runs a local parity node and connects the node to the `duero` network.                          |
| `--local-nile-node`        | Runs a local parity node and connects the node to the `nile` network.                           |
| `--local-pacific-node`     | Runs a local parity node and connects the node to the `pacific` network (official Ocean network |
| `--reuse-ganache-database` | Configures a running `ganache` node to use a persistent database.                               |
| `--force-pull`             | Force pulling the latest revision of the used Docker images.                                    |
| `--purge`                  | Removes the Docker containers, volumes, artifact folder and networks used by the script.        |
| `--exposeip`               | Binds the components to that specific ip. Exemple: ./start_ocean.sh --exposeip 192.168.0.1      |

## Docker Building Blocks

Barge consists of a set of building blocks that can be combined to form a local test environment. By default all building blocks will be started by the `start_ocean.sh` script.

### Commons

By default it will start two containers (client & server). If Commons is running, you can open the **Commons Frontend** application in your browser:

[http://localhost:3000](http://localhost:3000)

This Building Block can be disabled by setting the `--no-commons` flag.

| Hostname         | External Port | Internal URL               | Local URL             | Description                                                |
| ---------------- | ------------- | -------------------------- | --------------------- | ---------------------------------------------------------- |
| `commons-client` | `3000`        | http://commons-client:3000 | http://localhost:3000 | [Commons Client](https://github.com/oceanprotocol/commons) |
| `commons-server` | `4000`        | http://commons-server:4000 | http://locahost:4000  | [Commons Server](https://github.com/oceanprotocol/commons) |

### Aquarius

By default it will start two containers (one for Aquarius and one for its database engine). By default, Barge will use Elasticsearch for its database engine. You can use the `--mongodb` option to use MongoDB instead.

This Building Block can be disabled by setting the `--no-aquarius` flag.

| Hostname        | External Port | Internal URL         | Local URL             | Description                                           |
| --------------- | ------------- | -------------------- | --------------------- | ----------------------------------------------------- |
| `aquarius`      | `5000`        | http://aquarius:5000 | http://localhost:5000 | [Aquarius](https://github.com/oceanprotocol/aquarius) |
| `elasticsearch` |               |                      |                       | The Elasticsearch used by Aquarius                    |
| `mongodb`       |               |                      |                       | The MongoDB used by Aquarius                          |

### Brizo

By default it will start one container. This Building Block can be disabled by setting the `--no-brizo` flag.

| Hostname | External Port | Internal URL      | Local URL             | Description                                     |
| -------- | ------------- | ----------------- | --------------------- | ----------------------------------------------- |
| `brizo`  | `8030`        | http://brizo:8030 | http://localhost:8030 | [Brizo](https://github.com/oceanprotocol/brizo) |

### Events Handler

By default it will start one container. This Building Block can be disabled by setting the `--no-events-handler` flag.

| Hostname         | External Port | Internal URL | Local URL | Description                                                       |
| ---------------- | ------------- | ------------ | --------- | ----------------------------------------------------------------- |
| `events-handler` |               |              |           | [Events-handler](https://github.com/oceanprotocol/events-handler) |

### Keeper Node

Controlled by the `--local-*-node` config switches will start a container `keeper-node` that uses port `8545` to expose an rpc endpoint to the Ethereum Protocol.
You can find a detailed explanation of how to use this in the [script options](#script-options) section of this document.

| Hostname      | External Port | Internal URL            | Local URL             | Description          |
| ------------- | ------------- | ----------------------- | --------------------- | -------------------- |
| `keeper-node` | `8545`        | http://keeper-node:8545 | http://localhost:8545 | An Ethereum RPC node |

This node can be one of the following types (with the default being `spree`):

| Node      | Description                                                                                                                                                                                                          |
| --------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `ganache` | Runs a local [ganache-cli](https://github.com/trufflesuite/ganache-cli) node that is not persistent by default. The contracts from the desired `keeper-contracts` version will be deployed upon launch of this node. |
| `spree`   | This is the default. Runs a local node of the Spree Network. See [Spree Network](#spree-network) for details. The contracts from the desired `keeper-contracts` version will be deployed upon launch of this node.   |
| `duero`   | Runs a local node of the Duero Network and connects to the [Duero Testnet](https://docs.oceanprotocol.com/concepts/testnets/#the-duero-testnet).                                                                     |
| `nile`    | Runs a local node of the Nile Network and connects to the [Nile Testnet](https://docs.oceanprotocol.com/concepts/testnets/#nile-testnet).                                                                            |
| `pacific` | Runs a local node of the Pacific Network and connects to the [Pacific network](https://docs.oceanprotocol.com/concepts/pacific-network/).                                                                            |

### Secret Store

By default it will start three containers. This Building Block can be disabled by setting the `--no-secret-store` flag.

| Hostname                    | External Ports   | Internal URL                          | Local URL              | Description                                                                                   |
| --------------------------- | ---------------- | ------------------------------------- | ---------------------- | --------------------------------------------------------------------------------------------- |
| `secret-store`              | `12000`, `32771` | http://secret-store:12000             | http://localhost:12000 | An instance of the Ocean Secret Store                                                         |
| `secret-store-cors-proxy`   | `12001`          | http://secret-store-cors-proxy:12001  | http://localhost:12001 | An NGINX proxy to enable CORS on the secret store                                             |
| `secret-store-signing-node` | `9545`           | http://secret-store-signing-node:9545 | http://localhost:9545  | A Parity Ethereum node to `sign` messages for the secret store and to `decrypt` and `encrypt` |

### Faucet

By default it will start two containers, one for Faucet server and one for its database (MongoDB). This Building Block can be disabled by setting the `--no-faucet` flag.

| Hostname | External Port | Internal URL       | Local URL             | Description                                       |
| -------- | ------------- | ------------------ | --------------------- | ------------------------------------------------- |
| `faucet` | `3001`        | http://faucet:3001 | http://localhost:3001 | [Faucet](https://github.com/oceanprotocol/faucet) |

By default the Faucet allows requests every 24hrs. To disable the timespan check you can pass `FAUCET_TIMESPAN=0` as environment variable before starting the script.

### Dashboard

This will start a `portainer` dashboard with the following admin credentials and connects to the local docker host. This Building Block can be disabled by setting the `--no-dashboard` flag.

- User: `admin`
- Password: `oceanprotocol`

| Hostname    | External Port | Internal URL          | Local URL             | Description                                         |
| ----------- | ------------- | --------------------- | --------------------- | --------------------------------------------------- |
| `dashboard` | `9000`        | http://dashboard:9000 | http://localhost:9000 | [Portainer](https://github.com/portainer/portainer) |

## Spree Network

If you run the `./start_ocean.sh` script with the `--local-spree-node` option (please see [Keeper Node](#keeper-node) section of this document for more details),
you will have available a keeper node in the local and private Spree Network with the following accounts enabled:

| Account                                      | Type     | Password/Key                 | Balance          |
| -------------------------------------------- | -------- | ---------------------------- | ---------------- |
| `0x00Bd138aBD70e2F00903268F3Db08f2D25677C9e` | key      | node0                        | 1000000000 Ether |
| `0x068Ed00cF0441e4829D9784fCBe7b9e26D4BD8d0` | key      | secret                       | 1000000000 Ether |
| `0xA99D43d86A0758d5632313b8fA3972B6088A21BB` | key      | secret                       | 1000000000 Ether |
| `0xe2DD09d719Da89e5a3D0F2549c7E24566e947260` | mnemonic | [info here](#spree-mnemonic) | 1000000000 Ether |
| `0xBE5449a6A97aD46c8558A3356267Ee5D2731ab5e` | mnemonic | [info here](#spree-mnemonic) | 1000000000 Ether |
| `0xA78deb2Fa79463945C247991075E2a0e98Ba7A09` | mnemonic | [info here](#spree-mnemonic) | 1000000000 Ether |
| `0x02354A1F160A3fd7ac8b02ee91F04104440B28E7` | mnemonic | [info here](#spree-mnemonic) | 1000000000 Ether |
| `0xe17D2A07EFD5b112F4d675ea2d122ddb145d117B` | mnemonic | [info here](#spree-mnemonic) | 1000000000 Ether |
| `0xA32C84D2B44C041F3a56afC07a33f8AC5BF1A071` | mnemonic | [info here](#spree-mnemonic) | 1000000000 Ether |
| `0xFF3fE9eb218EAe9ae1eF9cC6C4db238B770B65CC` | mnemonic | [info here](#spree-mnemonic) | 1000000000 Ether |
| `0x529043886F21D9bc1AE0feDb751e34265a246e47` | mnemonic | [info here](#spree-mnemonic) | 1000000000 Ether |
| `0xe08A1dAe983BC701D05E492DB80e0144f8f4b909` | mnemonic | [info here](#spree-mnemonic) | 1000000000 Ether |
| `0xbcE5A3468386C64507D30136685A99cFD5603135` | mnemonic | [info here](#spree-mnemonic) | 1000000000 Ether |

Use one of the above accounts to populate `PROVIDER_ADDRESS`, `PROVIDER_PASSWORD` and `PROVIDER_KEYFILE` in `start_ocean.sh`.
This account will is used in `brizo` and `events-handler` as the `provider` account which is important for processing the
service agreements flow. The `PROVIDER_KEYFILE` must be placed in the `accounts` folder and must match the ethereum
address from `PROVIDER_ADDRESS`. The `PROVIDER_ADDRESS` is also set in `commons` instance so that published assets get
assigned the correct provider address.

### Spree Mnemonic

The accounts from type mnemonic can be access with this seedphrase:

`taxi music thumb unique chat sand crew more leg another off lamp`

## Contributing

See the page titled "[Ways to Contribute](https://docs.oceanprotocol.com/concepts/contributing/)" in the Ocean Protocol documentation.

## License

```text
Copyright 2019 Ocean Protocol Foundation

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
