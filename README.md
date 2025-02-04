[![banner](https://raw.githubusercontent.com/oceanprotocol/art/master/github/repo-banner%402x.png)](https://oceanprotocol.com)

<h1 align="center">barge</h1>

> 🐳 Docker Compose files for the full Ocean Protocol stack running locally for development.

---

- [Prerequisites](#prerequisites)
- [Get Started](#get-started)
- [Cleanup](#cleanup)
  - [Troubleshooting](#troubleshootin)
- [Startup Options](#startup-options)
  - [Component Versions](#component-versions-and-exposed-ports)
  - [Log levels](#log-levels)
  - [All Options](#all-options)
- [Docker Building Blocks](#docker-building-blocks)
  - [Aquarius](#aquarius)
  - [Provider](#provider)
  - [Ganache](#ganache)
  - [TheGraph](#thegraph)
  - [ocean-contracts](#ocean-contracts)
  - [Dashboard](#dashboard)
- [Contributing](#contributing)
- [License](#license)

---

## Prerequisites
We recommend running Barge inside a Linux machine.
- macOs - due to lacking docker network features, we recommend running Barge inside a Linux VM.
- Windows is not currently supported. If you are on Windows, we recommend running Barge inside a Linux VM. Another option might be to use the [Windows Subsystem for Linux (WSL)](https://en.wikipedia.org/wiki/Windows_Subsystem_for_Linux).
- [Docker](https://www.docker.com/get-started)
  - On Linux, [allow non-root users](https://www.thegeekdiary.com/run-docker-as-a-non-root-user/)
  - On Windows or MacOS, [increase memory to 4 GB (default is 2 GB)](https://stackoverflow.com/a/44533437). Or, for C2D, make it 8 to 16 GB
- [Docker Compose](https://docs.docker.com/compose/)

## Get Started

If you're new to Barge, it's best to start with the defaults:

```bash
git clone git@github.com:oceanprotocol/barge.git
cd barge

./start_ocean.sh
```

This will run the current default versions of [Aquarius](https://github.com/oceanprotocol/aquarius), [Provider](https://github.com/oceanprotocol/provider-py), and [Ganache](https://github.com/trufflesuite/ganache-cli) with [our contracts](https://github.com/oceanprotocol/ocean-contracts) deployed to it.

<img width="486" alt="Welcome to Ocean Protocol" src="Welcome_to_Ocean_Protocol.png">


## Cleanup

To clean up your environment, you can run
> ```bash
> ./cleanup.sh
> ```

This will stop & remove any ocean related containers, then delete any volumes and networks created by barge.


### Troubleshooting

If your code using Barge hits `KeyError: "development"`, this is a Barge issue: Barge couldn't deploy the contracts and update `address.json` in `~/.ocean/`. _Further_ cleanup is needed. Further cleanup can fix other issues too. Here are tactics.

Tactic: clean up old Docker containers
```console
docker system prune -a --volumes
```

Tactic: delete Ocean cache, or a sub-directory of it. (This is not part of cleanup.sh in case you want to preserve parts of `~/.ocean/`.)
```console
# delete whole cache
rm -rf ~/.ocean

# OR, delete sub-directory
# (find the sub-directory, and rm -rf it)
```

Tactic: Kill redis or postgres processes. Why: they usually have autostart enabled and can interfere with Barge.
```console
# use ps. Do as superuser to ensure you see the process.
sudo ps aux | grep redis
sudo ps aux | grep postgresql

# If you see unwanted processes, kill them by process id. -9 to force
kill -9 <pid>
```

Tactic: reboot your computer. Why: will stop any other unwanted process.


## Startup Options

The startup script comes with a set of options for customizing various things.

### Component Versions and exposed ports

The default versions are always a combination of component versions which are considered stable.

| Component name      | Required by        | Version                           | IP Address      | Ports exposed |
| --------------      | ------------------ | --------------------------------- | --------------- | ------------- |
| ganache             |  ocean-contracts   | latest                            | 172.15.0.3      | 8545 -> 8545  |
| ocean-contracts     |                    | v2.2.1                            | 172.15.0.14     |               |
| Aquarius            |                    | v5.1.4                            | 172.15.0.5      | 5000 -> 5000  |
| Elasticsearch       |  Aquarius          | 8.5.1                             | 172.15.0.6      |               |
| Typesense           |  Ocean-node        | 0.25.1                            | 172.15.0.20     | 8108 -> 8108  |
| Provider            |                    | v2.1.6                            | 172.15.0.4      | 8030 -> 8030  |
| Provider2           |                    | v2.1.6                            | 172.15.0.7      | 8030 -> 8030  |
| RBAC Server         |                    | main                              | 172.15.0.8      | 3000 -> 3000  |
| GraphNode           |                    | graphprotocol/graph-node:v0.28.2   | 172.15.0.15     | 9000 -> 8000 ,9001 -> 8001 , 9020 -> 8020,  9030 -> 8030, 9040 -> 8040  |
| Graphipfs           |                    | ipfs/go-ipfs:v0.4.23              | 172.15.0.16     | 5001 -> 5001  |
| Graphpgsql          |                    | postgres                          | 172.15.0.7      | 5432 -> 5432  |
| Dashboard           |                    | portainer/portainer               | 172.15.0.25     | 9100 -> 9000  |
| Redis               |                    | bitnami/redis:latest              | 172.15.0.18     | 6379 -> 6379  |
| C2d                 |                    | multiple components               | 172.15.0.12,172.15.0.13     | 31000 -> 31000  |


You can override the Docker image tag used for a particular component by setting its associated environment variable before calling `start_ocean.sh`:

- `AQUARIUS_VERSION`
- `PROVIDER_VERSION`
- `CONTRACTS_VERSION`
- `RBAC_VERSION`
- `ELASTICSEARCH_VERSION`

For example:

```bash
export AQUARIUS_VERSION=v2.0.0
./start_ocean.sh
```

### Log levels

You can specify what type of logs barge should display for `Aquarius`, `Provider` or `Subgraph`
by exporting the following environment variables.

- `AQUARIUS_LOG_LEVEL`
- `PROVIDER_LOG_LEVEL`
- `SUBGRAPH_LOG_LEVEL`

Currently, they are all set to `INFO`.

For example:

```bash
export AQUARIUS_LOG_LEVEL=DEBUG
./start_ocean.sh
```

### All Options

| Option                     | Description                                                                                     |
| -------------------------- | ----------------------------------------------------------------------------------------------- |
| `--no-aquarius`            | Start up Ocean without the `aquarius` Building Block.                                           |
| `--no-elasticsearch`       | Start up Ocean without the `elasticsearch` Building Block.                                      |
| `--with-typesense`         | Start up Ocean with Typesense |
| `--no-provider`            | Start up Ocean without the `provider` Building Block.                                           |
| `--no-ipfs`                | Start up Ocean without the `ipfs` Building Block                                                |
| `--with-provider2`         | Runs a 2nd provider, on port 8031. This is required for ocean.js/ocean.py integration tests. 2nd Provider will use the same image and parameters (log_level, ipfs gateway, compute gateway, etc) as provider1, but has a different private key     |
| `--no-dashboard`           | Start up Ocean without the `dashboard` Building Block.                                          |
| `--with-rbac`              | Start up Ocean with RBAC Server                                                                 |
| `--with-thegraph`          | Start up Ocean with graphnode,postgresql and deploys ocean-subgraph                             |
| `--skip-subgraph-deploy`  | Will skip deployment of ocean-subgraphs                                                         |
| `--skip-deploy`            | Start up Ocean without deploying the contracts. Useful when ethereum node already has contracts.|
| `--force-pull`             | Force pulling the latest revision of the used Docker images.                                    |
| `--purge`                  | Removes the Docker containers, volumes, artifact folder and networks used by the script.        |
| `--exposeip`               | Binds the components to that specific ip. Example: `./start_ocean.sh --exposeip 192.168.0.1`    |
| `--with-c2d`               | Runs a local C2D Cluster                                                                        |


## Docker Building Blocks

Barge consists of a set of building blocks that can be combined to form a local test environment. By default all building blocks will be started by the `start_ocean.sh` script.

### Aquarius

By default it will start two containers (one for Aquarius and one for its database engine). By default, Barge will use Elasticsearch for its database engine.

This Building Block can be disabled by setting the `--no-aquarius` flag.

| Hostname        | External Port | Internal URL         | Local URL             | Description                                           |
| --------------- | ------------- | -------------------- | --------------------- | ----------------------------------------------------- |
| `aquarius`      | `5000`        | http://aquarius:5000 | http://localhost:5000 | [Aquarius](https://github.com/oceanprotocol/aquarius) |
| `elasticsearch` |               |                      |                       | The Elasticsearch used by Aquarius                    |

### Provider

| Hostname    | External Port | Internal URL          | Local URL             | Description                                         |
| ----------- | ------------- | --------------------- | --------------------- | --------------------------------------------------- |
| `provider`  | `8030`        | http://provider:8030 | http://localhost:8030  |  |

### Ganache

| Hostname    | External Port | Internal URL          | Local URL             | Description                                         |
| ----------- | ------------- | --------------------- | --------------------- | --------------------------------------------------- |
| `ganache`   | `8545`        | http://ganache:8545   | http://localhost:8545   |  |

### TheGraph

| Hostname    | External Port | Internal URL          | Local URL             | Description                                         |
| ----------- | ------------- | --------------------- | --------------------- | --------------------------------------------------- |
| `graphnode` | `9000`        | http://graphnode:9000 | http://localhost:9000 |  |

### ocean-contracts

* Deploy all smart contracts from the `ocean-contracts` repo
* Export artifacts files (.json) to default shared folder between all containers
* Create address file (address.json) that has the address of each deployed smart contract that is required by the ocean library. This file is saved to the same folder with the artifacts files

The accounts can be accessed with this seed phrase:

```
taxi music thumb unique chat sand crew more leg another off lamp
```

Alternatively, you can pass your own mnemonic with `GANACHE_MNEMONIC`.

### Dashboard

This will start a `portainer` dashboard with the following admin credentials and connects to the local docker host. This Building Block can be disabled by setting the `--no-dashboard` flag.

- User: `admin`
- Password: `oceanprotocol`

| Hostname    | External Port | Internal URL          | Local URL             | Description                                         |
| ----------- | ------------- | --------------------- | --------------------- | --------------------------------------------------- |
| `dashboard` | `9100`        | http://dashboard:9100 | http://localhost:9100 | [Portainer](https://github.com/portainer/portainer) |

### RBAC Server

| Hostname    | External Port | Internal URL          | Local URL             | Description                                         |
| ----------- | ------------- | --------------------- | --------------------- | --------------------------------------------------- |
| `rbac`      | `3000`        | http://rbac:3000      | http://localhost:3000 |                                                     |


The following addresses are preconfigured for testing:  (first 10 addresses from the default mnemonic)

| Address                                    |  Roles                          |
| -----------------------------------------  | ------------------------------- |
| 0xe2DD09d719Da89e5a3D0F2549c7E24566e947260 | ["user","publisher","consumer"] |
| 0xBE5449a6A97aD46c8558A3356267Ee5D2731ab5e | ["user","publisher","consumer"] |
| 0xA78deb2Fa79463945C247991075E2a0e98Ba7A09 | ["user","publisher","consumer"] |
| 0x02354A1F160A3fd7ac8b02ee91F04104440B28E7 | ["user","publisher","consumer"] |
| 0xe17D2A07EFD5b112F4d675ea2d122ddb145d117B | ["user","publisher","consumer"] |
| 0xA32C84D2B44C041F3a56afC07a33f8AC5BF1A071 | ["user","publisher","consumer"] |
| 0xFF3fE9eb218EAe9ae1eF9cC6C4db238B770B65CC | ["user"]                        |
| 0x529043886F21D9bc1AE0feDb751e34265a246e47 | ["consumer"]                    |
| 0xe08A1dAe983BC701D05E492DB80e0144f8f4b909 | ["publisher"]                   |
| 0xbcE5A3468386C64507D30136685A99cFD5603135 | ["consumer","publisher"]        |

## Contributing

See the page titled "[Ways to Contribute](https://docs.oceanprotocol.com/concepts/contributing/)" in the Ocean Protocol documentation.


## Readiness
 Several building blocks on barge are going to require some time until they are ready.  Watch for the following files to be created:

| Building block                             |  File                                         | Condition       |
| -----------------------------------------  | -------------------------------               | --------------  |
| ocean-contracts                            | ${OCEAN_HOME}/ocean-contracts/artifacts/ready |
| c2d                                        | ${OCEAN_HOME}/ocean-c2d/ready |         |
| c2d                                        | ${OCEAN_HOME}/ocean-c2d/imagesready |  Only if WAIT_FOR_C2DIMAGES == 'yeah' |


## Certs
  Registry certs were created using the following commands:
  ```bash
  openssl genrsa 2048 > registry.key
  openssl req -new -x509 -nodes -sha1 -days 3650 -key registry.key -out registry.crt -addext 'subjectAltName = IP:172.15.0.11'
  ```

## License

```text
Copyright 2023 Ocean Protocol Foundation

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
