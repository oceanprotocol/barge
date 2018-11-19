[![banner](doc/img/repo-banner@2x.png)](https://oceanprotocol.com)

<h1 align="center">docker-images</h1>

> 🐳 Docker compose and tools running the complete Ocean Protocol network stack.
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
  - [Contributing](#contributing)
  - [License](#license)

---

## Prerequisites

You need to have the newest versions available of both:

* [Docker](https://www.docker.com/get-started)
* [Docker Compose](https://docs.docker.com/compose/)

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
`--local-parity-node` | Runs a local parity POA node and Secret Store instead of ganache-cli.
`--reuse-database` | Start up Ocean and reuse the Database from ganache. Helpful for development.

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
./start_ocean.sh --latest --local-parity-node
```

then [docker-compose-local-parity-node.yml](docker-compose-local-parity-node.yml) will be used. Read it to see what images it starts. Note that it _doesn't_ start Pleuston, and it _does_ start a Parity Secret Store.

If you do:

```bash
./start_ocean.sh --latest --no-pleuston --local-parity-node
```

then the last-selected Docker Compose file will be used, i.e. the one selected by `--local-parity-node`: [docker-compose-local-parity-node.yml](docker-compose-local-parity-node.yml).

### Parity Client Accounts

If you run the `start_ocean.sh` script with the `--local-parity-node` option, you will have available a Parity Client instance with the following accounts enabled:

Account | Password | Balance
--------|----------|--------
0x00bd138abd70e2f00903268f3db08f2d25677c9e | node0 | 10000000111000111000111000
0x068ed00cf0441e4829d9784fcbe7b9e26d4bd8d0 | secret | 100000000
0xa99d43d86a0758d5632313b8fa3972b6088a21bb | secret | 100000000

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

## Contributing

We use GitHub as a means for maintaining and tracking issues and source code development.

If you would like to contribute, please fork this repository, do work in a feature branch, and finally open a pull request for maintainers to review your changes.

Ocean Protocol uses [C4 Standard process](https://github.com/unprotocols/rfc/blob/master/1/README.md) to manage changes in the source code. Find here more details about [Ocean C4 OEP](https://github.com/oceanprotocol/OEPs/tree/master/1).

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
