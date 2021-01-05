[![banner](https://raw.githubusercontent.com/oceanprotocol/art/master/github/repo-banner%402x.png)](https://oceanprotocol.com)

<h1 align="center">barge</h1>

> 🐳 Docker Compose files for the full Ocean Protocol stack running locally for development.

---

- [Prerequisites](#prerequisites)
- [Get Started](#get-started)
- [Options](#options)
  - [Component Versions](#component-versions)
  - [All Options](#all-options)
- [Docker Building Blocks](#docker-building-blocks)
  - [Aquarius](#aquarius)
  - [Provider](#provider)
  - [Ganache](#ganache)
  - [ocean-contracts](#ocean-contracts)
  - [Dashboard](#dashboard)
- [Contributing](#contributing)
- [License](#license)

---

## Prerequisites

You need to have the newest versions of:

- Linux or macOS. Windows is not currently supported. If you are on Windows, we recommend running Barge inside a Linux VM. Another option might be to use the [Windows Subsystem for Linux (WSL)](https://en.wikipedia.org/wiki/Windows_Subsystem_for_Linux).
- [Docker](https://www.docker.com/get-started)
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

> It's overkill, but to be _sure_ that you use exactly the Docker images and volumes you want, you can prune all the Docker things in your system first:

> ```bash
> docker system prune --all --volumes
> ```

## Options

The startup script comes with a set of options for customizing various things.

### Component Versions

The default versions are always a combination of component versions which are considered stable.

| Aquarius | Provider | Ganache  | ocean-contracts |
| -------- | -------- | -------- | --------------- |
| `v2.1.6` | `v0.4.0` | `latest` |  `V0.5.7`

You can override the Docker image tag used for a particular component by setting its associated environment variable before calling `start_ocean.sh`:

- `AQUARIUS_VERSION`
- `PROVIDER_VERSION`
- `CONTRACTS_VERSION`

For example:

```bash
export AQUARIUS_VERSION=v2.0.0
./start_ocean.sh
```

### All Options

| Option                     | Description                                                                                     |
| -------------------------- | ----------------------------------------------------------------------------------------------- |
| `--no-aquarius`            | Start up Ocean without the `aquarius` Building Block.                                           |
| `--no-provider`            | Start up Ocean without the `provider` Building Block.                                           |
| `--no-ganache`             | Start up Ocean without the `ganache` Building Block.                                            |
| `--no-dashboard`           | Start up Ocean without the `dashboard` Building Block.                                          |
| `--force-pull`             | Force pulling the latest revision of the used Docker images.                                    |
| `--purge`                  | Removes the Docker containers, volumes, artifact folder and networks used by the script.        |
| `--exposeip`               | Binds the components to that specific ip. Example: `./start_ocean.sh --exposeip 192.168.0.1`    |


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
| `provider`  | `8030`        | http://provider:9000 | http://localhost:8030  |  |

### Ganache

| Hostname    | External Port | Internal URL          | Local URL             | Description                                         |
| ----------- | ------------- | --------------------- | --------------------- | --------------------------------------------------- |
| `ganache`   | `8545`        | http://ganache:9000   | http://localhost:8545   |  |

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
| `dashboard` | `9000`        | http://dashboard:9000 | http://localhost:9000 | [Portainer](https://github.com/portainer/portainer) |

## Contributing

See the page titled "[Ways to Contribute](https://docs.oceanprotocol.com/concepts/contributing/)" in the Ocean Protocol documentation.

## License

```text
Copyright 2021 Ocean Protocol Foundation

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
