#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
COMPOSE_DIR="${DIR}/compose-files"

export PROJECT_NAME="ocean"
# default to latest versions
export OCEAN_VERSION=latest

# keeper options
export KEEPER_DEPLOY_CONTRACTS="true"
export KEEPER_ARTIFACTS_FOLDER=$HOME/.ocean/keeper-contracts/artifacts
# Specify which ethereum client to run or connect to: development, kovan, spree or nile
export KEEPER_NETWORK_NAME="nile"
export NODE_FILE=${COMPOSE_DIR}/nodes/nile_node.yml

# Ganache specific option, these two options have no effect when not running ganache-cli
export GANACHE_DATABASE_PATH="${DIR}"
export GANACHE_REUSE_DATABASE="false"

export BRIZO_ENV_FILE=$DIR/brizo.env

# Specify the ethereum default RPC container provider
export KEEPER_RPC_HOST='keeper-node'
export KEEPER_RPC_PORT='8545'
export KEEPER_RPC_URL="http://"${KEEPER_RPC_HOST}:${KEEPER_RPC_PORT}

# colors
COLOR_R="\033[0;31m"    # red
COLOR_G="\033[0;32m"    # green
COLOR_Y="\033[0;33m"    # yellow
COLOR_B="\033[0;34m"    # blue
COLOR_M="\033[0;35m"    # magenta
COLOR_C="\033[0;36m"    # cyan

# reset
COLOR_RESET="\033[00m"

function show_banner {
    local output=$(cat .banner)
    echo -e "$COLOR_B$output$COLOR_RESET"
    echo ""
}

show_banner

COMPOSE_FILES=""
COMPOSE_FILES+=" -f ${COMPOSE_DIR}/network_volumes.yml"
COMPOSE_FILES+=" -f ${COMPOSE_DIR}/pleuston.yml"
COMPOSE_FILES+=" -f ${COMPOSE_DIR}/aquarius.yml"
COMPOSE_FILES+=" -f ${COMPOSE_DIR}/brizo.yml"
COMPOSE_FILES+=" -f ${COMPOSE_DIR}/secret_store.yml"

while :; do
    case $1 in
        #################################################
        # Version switches
        #################################################
        --latest)
            export OCEAN_VERSION=latest
            printf $COLOR_Y'Switched to latest components...\n\n'$COLOR_RESET
            ;;
        #################################################
        # Exclude switches
        #################################################
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
        --no-secret-store)
            COMPOSE_FILES=${COMPOSE_FILES/ -f ${COMPOSE_DIR}\/secret_store.yml/}
            printf $COLOR_Y'Starting without Secret Store...\n\n'$COLOR_RESET
            ;;
        #################################################
        # Contract/Storage switches
        #################################################
        --reuse-ganache-database)
            export GANACHE_REUSE_DATABASE="true"
            printf $COLOR_Y'Starting and reusing the database ...\n\n'$COLOR_RESET
            ;;
        #################################################
        # Node type switches
        #################################################
        # connects you to kovan
        --local-kovan-node)
            export NODE_FILE=${COMPOSE_DIR}/nodes/kovan_node.yml
            export KEEPER_NETWORK_NAME="kovan"
            printf $COLOR_Y'Starting with local Kovan node...\n\n'$COLOR_RESET
            ;;
        # spins up a new ganache blockchain
        --local-ganache-node)
            COMPOSE_FILES+=" -f ${COMPOSE_DIR}/keeper_contracts.yml"
            export NODE_FILE=${COMPOSE_DIR}/nodes/ganache_node.yml
            export KEEPER_NETWORK_NAME="development"
            export KEEPER_DEPLOY_CONTRACTS="true"
            printf $COLOR_Y'Starting with local Ganache node...\n\n'$COLOR_RESET
            ;;
        # connects you to nile ocean testnet
        --local-nile-node)
            export NODE_FILE=${COMPOSE_DIR}/nodes/nile_node.yml
            export KEEPER_NETWORK_NAME="nile"
            printf $COLOR_Y'Starting with local Nile node...\n\n'$COLOR_RESET
            ;;
        # spins up spree local testnet
        --local-spree-node)
            COMPOSE_FILES+=" -f ${COMPOSE_DIR}/keeper_contracts.yml"
            export NODE_FILE=${COMPOSE_DIR}/nodes/spree_node.yml
            export KEEPER_NETWORK_NAME="spree"
            export KEEPER_DEPLOY_CONTRACTS="true"
            printf $COLOR_Y'Starting with local Spree node...\n\n'$COLOR_RESET
            ;;
        #################################################
        # Cleaning switches
        #################################################
        --purge)
            docker network rm ${PROJECT_NAME}_backend || true
            docker network rm ${PROJECT_NAME}_default || true
            docker volume rm ${PROJECT_NAME}_keeper-node || true
            docker volume rm ${PROJECT_NAME}_secret-store || true
            read -p "Are you sure you want to delete $KEEPER_ARTIFACTS_FOLDER? " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]
            then
                rm -rf ${KEEPER_ARTIFACTS_FOLDER}
            fi
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
            docker-compose --project-name=$PROJECT_NAME $COMPOSE_FILES -f ${NODE_FILE} up --remove-orphans
            break
    esac
    shift
done
