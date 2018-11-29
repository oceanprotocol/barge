#!/usr/bin/env bash

export DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
COMPOSE_DIR="${DIR}/compose-files"
# Must be set to true for the first run, change it to "false" to avoid migrating the smart contracts on each run.
export DEPLOY_CONTRACTS="true"
# Ganache specific option, these two options have no effect when not running ganache-cli
export GANACHE_DATABASE_PATH="${DIR}"
export REUSE_DATABASE="false"
# Specify which ethereum client to run or connect to: kovan, ganache, or ocean_poa_net_local
export KEEPER_NETWORK_NAME="ganache"
export ARTIFACTS_FOLDER=$HOME/.ocean/keeper-contracts/artifacts

# colors
COLOR_R="\033[0;31m"    # red
COLOR_G="\033[0;32m"    # green
COLOR_Y="\033[0;33m"    # yellow
COLOR_B="\033[0;34m"    # blue
COLOR_M="\033[0;35m"    # magenta
COLOR_C="\033[0;36m"    # cyan

# reset
COLOR_RESET="\033[00m"

function usage {
    cat <<EOF
Usage: $(basename "$0") [--help] [--latest] [--reuse-database] [--no-pleuston] [--local-secret-store] [--kovan-parity-node] [--testnet-parity-node]

where:
  --help: Shows this help
  --latest: Use the tag "latest" of the ocean docker images
  --reuse-database: Reuse Ganache database if used
  --no-pleuston: Do not deploy pleuston
  --local-secret-store: Deploy Ocean stack with Secret-store and parity client
  --kovan-parity-node: Deploy only a parity node connected to Kovan testnet
  --testnet-parity-node: Deploy only a parity node connected to Ocean testnet
EOF
}

function error {
    local message="$1"
    echo -e "$COLOR_R$message$COLOR_RESET"
    exit 1
}

function show_banner {
    local output=$(cat .banner)
    echo -e "$COLOR_B$output$COLOR_RESET"
    echo ""
}

show_banner

# default to stable versions
export OCEAN_VERSION=stable

# Compose files
COMPOSE_FILES=""
COMPOSE_FILES+=" -f ${COMPOSE_DIR}/network_volumes.yml"
COMPOSE_FILES+=" -f ${COMPOSE_DIR}/mongo.yml"
COMPOSE_FILES+=" -f ${COMPOSE_DIR}/keeper_contracts.yml"
COMPOSE_FILES+=" -f ${COMPOSE_DIR}/pleuston.yml"
COMPOSE_FILES+=" -f ${COMPOSE_DIR}/aquarius.yml"
COMPOSE_FILES+=" -f ${COMPOSE_DIR}/brizo.yml"
while :; do
    case $1 in
        --help)
            usage
            exit 0
            ;;
        --latest)
            export OCEAN_VERSION=latest
            printf $COLOR_Y'Switched to latest components...\n\n'$COLOR_RESET
            ;;
        --reuse-database)
            export REUSE_DATABASE="true"
            printf $COLOR_Y'Starting and reusing the database ...\n\n'$COLOR_RESET
            ;;
        --no-pleuston)
            COMPOSE_FILES=${COMPOSE_FILES/ -f ${COMPOSE_DIR}\/pleuston.yml/}
            printf $COLOR_Y'Starting without Pleuston...\n\n'$COLOR_RESET
            ;;
        --no-brizo)
            COMPOSE_FILES=${COMPOSE_FILES/ -f ${COMPOSE_DIR}\/brizo.yml/}
            printf $COLOR_Y'Starting without Brizo...\n\n'$COLOR_RESET
            ;;
        --no-aquarius)
            COMPOSE_FILES=${COMPOSE_FILES/ -f ${COMPOSE_DIR}\/aquarius.yml/}
            printf $COLOR_Y'Starting without Aquarius...\n\n'$COLOR_RESET
            ;;
        --local-secret-store)
            COMPOSE_FILES+=" -f ${COMPOSE_DIR}/parity_client_local.yml"
            COMPOSE_FILES+=" -f ${COMPOSE_DIR}/secret_store.yml"
            export KEEPER_NETWORK_NAME="ocean_poa_net_local"
            printf $COLOR_Y'Starting with local Parity node...\n\n'$COLOR_RESET
            ;;
        --kovan-parity-node)
            COMPOSE_FILES=${COMPOSE_FILES/ -f ${COMPOSE_DIR}\/mongo.yml/}
            COMPOSE_FILES=${COMPOSE_FILES/ -f ${COMPOSE_DIR}\/keeper_contracts.yml/}
            COMPOSE_FILES+=" -f ${COMPOSE_DIR}/parity_client.yml"
            export NETWORK="kovan"
            ;;
        --testnet-parity-node)
            COMPOSE_FILES=${COMPOSE_FILES/ -f ${COMPOSE_DIR}\/mongo.yml/}
            COMPOSE_FILES=${COMPOSE_FILES/ -f ${COMPOSE_DIR}\/keeper_contracts.yml/}
            COMPOSE_FILES+=" -f ${COMPOSE_DIR}/parity_client.yml"
            export NETWORK="ocean-network"
            ;;
        --) # End of all options.
            shift
            break
            ;;
        -?*)
            printf $COLOR_R'WARN: Unknown option (ignored): %s\n'$COLOR_RESET "$1" >&2
            break
            ;;
        *)
            printf $COLOR_Y'Starting Ocean...\n\n'$COLOR_RESET
            docker-compose --project-name=ocean $COMPOSE_FILES up
            break
    esac
    shift
done
