[![banner](doc/img/repo-banner@2x.png)](https://oceanprotocol.com)

<h1 align="center">docker-images</h1>

> 🐳 Docker compose and tools running the complete Ocean Protocol network stack.
> [oceanprotocol.com](https://oceanprotocol.com)

---

**🐲🦑 THERE BE DRAGONS AND SQUIDS. This is in alpha state and you can expect running into problems. If you run into them, please open up [a new issue](https://github.com/oceanprotocol/docker-images/issues). 🦑🐲**

---

## Table of Contents

* [Prerequisites](#prerequisites)
* [Get Started](#get-started)
* [Ocean Protocol components](#ocean-protocol-components)
    - [Versions](#versions)
* [Contributing](#contributing)
* [License](#license)

---

## Prerequisites

You need to have the newest versions available of both:

* [Docker](https://www.docker.com/get-started)
* [Docker Compose](https://docs.docker.com/compose/)

## Get Started

Then bring up an instance of the whole Ocean Protocol network stack with:

```bash
git clone git@github.com:oceanprotocol/docker-images.git
cd docker-images/

docker-compose --project-name=ocean up
```

After getting everything running, you can open the **Pleuston Frontend** application in your browser:

```
http://localhost:3000
```

## Ocean Protocol components

The Ocean Docker compose starts the following components:

* [🦄 pleuston](https://github.com/oceanprotocol/pleuston). Frontend listening on port `3000`.
* [🐋 provider](https://github.com/oceanprotocol/provider). Backend listening on port `5000`.
* [💧 keeper-contracts](https://github.com/oceanprotocol/keeper-contracts). RPC client listening on port `8545`.

### Versions

The version of the Ocean components can be configured setting the environment variable `OCEAN_VERSION`. By default `master` branch runs the latest stable version release, and `develop` branch runs the code generated in the `master` branch of the Ocean components. If you want to run the component's code of `develop` branch:

```bash
export OCEAN_VERSION=latest
docker-compose --project-name=ocean up
```

![Ocean Docker Images](doc/img/docker-images.jpg)

## Contributing

We use GitHub as a means for maintaining and tracking issues and source code development.

If you would like to contribute, please fork this repository, do work in a feature branch, and finally open a pull request for maintainers to review your changes.

Ocean Protocol uses [C4 Standard process](https://github.com/unprotocols/rfc/blob/master/1/README.md) to manage changes in the source code. Find here more details about [Ocean C4 OEP](https://github.com/oceanprotocol/OEPs/tree/master/1).

## License

```
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
