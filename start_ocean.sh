#!/usr/bin/env bash

# Must be set to true for the first run, change it to "false" to avoid migrating the smart contracts on each run.
export DEPLOY_CONTRACTS="true"
# Ganache specific option, these two options have no effect when not running ganache-cli
export GANACHE_DATABASE_PATH="."
export REUSE_DATABASE="false"
# Specify which ethereum client to run or connect to: kovan, ganache, or ocean_poa_net_local
export KEEPER_NETWORK_NAME="ganache"
export ARTIFACTS_FOLDER=~/.ocean/keeper-contracts/artifacts

# default to `stable` versions of all components
# unless `--latest` argument is given
if [ "$1" == "--latest" ]; then
    export OCEAN_VERSION=latest
else
    export OCEAN_VERSION=stable
fi

if [ "$1" == "--no-pleuston" ]
then
export REUSE_DATABASE="true"
docker-compose -f docker-compose-no-pleuston.yml up

elif [ "$1" == "--local-parity-node" ]
then
export KEEPER_NETWORK_NAME="ocean_poa_net_local"
docker-compose -f docker-compose-local-parity-node.yml up

else
docker-compose up

fi