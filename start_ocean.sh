#!/usr/bin/env bash

export OCEAN_VERSION=latest
# Must be set to true for the first run, change it to "false" to avoid migrating the smart contracts on each run.
export DEPLOY_CONTRACTS="true"
# Ganache specific option, these two options have no effect when not running ganache-cli
export GANACHE_DATABASE_PATH="."
export REUSE_DATABASE="true"
# Specify which ethereum client to run or connect to: kovan, ganache, or ocean_poa_net_local
export KEEPER_NETWORK_NAME="ganache"
export ARTIFACTS_FOLDER=~/.ocean/keeper-contracts/artifacts

docker-compose up