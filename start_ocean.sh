#!/usr/bin/env bash
# start_ocean.sh
# Copyright (c) 2019 Ocean Protocol contributors
# SPDX-License-Identifier: Apache-2.0

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
export BRIZO_ENV_FILE="${DIR}/brizo.env"

# Patch $DIR if spaces (BRIZO_ENV_FILE does not need patch)
DIR="${DIR/ /\\ }"
COMPOSE_DIR="${DIR}/compose-files"

# Default versions of Aquarius, Brizo, Keeper Contracts and Pleuston
export AQUARIUS_VERSION=${AQUARIUS_VERSION:-v0.2.0}
export BRIZO_VERSION=${BRIZO_VERSION:-v0.3.1}
export KEEPER_VERSION=${KEEPER_VERSION:-v0.9.0}
export PLEUSTON_VERSION=${PLEUSTON_VERSION:-v0.3.0}

export PROJECT_NAME="ocean"
export FORCEPULL="false"

# Ocean filesystem artifacts
export OCEAN_HOME="${HOME}/.ocean"

# keeper options
export KEEPER_OWNER_ROLE_ADDRESS="${KEEPER_OWNER_ROLE_ADDRESS}"
export KEEPER_DEPLOY_CONTRACTS="true"
export KEEPER_ARTIFACTS_FOLDER="${OCEAN_HOME}/keeper-contracts/artifacts"
# Specify which ethereum client to run or connect to: development, kovan, spree or nile
export KEEPER_NETWORK_NAME="spree"
export NODE_COMPOSE_FILE="${COMPOSE_DIR}/nodes/spree_node.yml"

# Ganache specific option, these two options have no effect when not running ganache-cli
export GANACHE_DATABASE_PATH="${DIR}"
export GANACHE_REUSE_DATABASE="false"

# Specify the ethereum default RPC container provider
export KEEPER_RPC_HOST='keeper-node'
export KEEPER_RPC_PORT='8545'
export KEEPER_RPC_URL="http://"${KEEPER_RPC_HOST}:${KEEPER_RPC_PORT}
# Use this seed only on Spree! (Spree is the default.)
export KEEPER_MNEMONIC="taxi music thumb unique chat sand crew more leg another off lamp"

# Enable acl-contract validation in Secret-store
export CONFIGURE_ACL="true"
export ACL_CONTRACT_ADDRESS=""

# Default Aquarius parameters
export DB_MODULE="mongodb"
export DB_HOSTNAME="mongodb"
export DB_PORT="27017"

# Export User UID and GID
export LOCAL_USER_ID=$(id -u)
export LOCAL_GROUP_ID=$(id -g)

# colors
COLOR_R="\033[0;31m"    # red
COLOR_G="\033[0;32m"    # green
COLOR_Y="\033[0;33m"    # yellow
COLOR_B="\033[0;34m"    # blue
COLOR_M="\033[0;35m"    # magenta
COLOR_C="\033[0;36m"    # cyan

# reset
COLOR_RESET="\033[00m"

function get_acl_address {
    local version="${1:-latest}"
    line=$(grep "^${version}=" "${DIR}/${KEEPER_NETWORK_NAME}_acl_contract_addresses.txt")
    address="${line##*=}"
    [ -z "${address}" ] && echo "Cannot determine the ACL Contract Address for ${KEEPER_NETWORK_NAME} version ${version}. Exiting" && exit 1
    echo "${address}"
}

function show_banner {
    local output=$(cat .banner)
    echo -e "$COLOR_B$output$COLOR_RESET"
    echo ""
}

function configure_secret_store {
    # restore default secret store config (Issue #126)
    if [ -e "$DIR/networks/secret-store/config/config.toml.save" ]; then
        cp "$DIR/networks/secret-store/config/config.toml.save" \
           "$DIR/networks/secret-store/config/config.toml"
    fi
}

function check_if_owned_by_root {
    if [ -d "$OCEAN_HOME" ]; then
        uid=$(ls -nd "$OCEAN_HOME" | awk '{print $3;}')
        if [ "$uid" = "0" ]; then
            printf $COLOR_R"WARN: $OCEAN_HOME is owned by root\n"$COLOR_RESET >&2
        else
            uid=$(ls -nd "$KEEPER_ARTIFACTS_FOLDER" | awk '{print $3;}')
            if [ "$uid" = "0" ]; then
                printf $COLOR_R"WARN: $KEEPER_ARTIFACTS_FOLDER is owned by root\n"$COLOR_RESET >&2
            fi
        fi
    fi
}

function clean_local_contracts {
    rm -f ${KEEPER_ARTIFACTS_FOLDER}/ready
    rm -f ${KEEPER_ARTIFACTS_FOLDER}/*.spree.json
    rm -f ${KEEPER_ARTIFACTS_FOLDER}/*.development.json
}

check_if_owned_by_root
show_banner

COMPOSE_FILES=""
COMPOSE_FILES+=" -f ${COMPOSE_DIR}/keeper_contracts.yml"
COMPOSE_FILES+=" -f ${COMPOSE_DIR}/network_volumes.yml"
COMPOSE_FILES+=" -f ${COMPOSE_DIR}/pleuston.yml"
COMPOSE_FILES+=" -f ${COMPOSE_DIR}/aquarius_mongodb.yml"
COMPOSE_FILES+=" -f ${COMPOSE_DIR}/brizo.yml"
COMPOSE_FILES+=" -f ${COMPOSE_DIR}/secret_store.yml"

DOCKER_COMPOSE_EXTRA_OPTS="${DOCKER_COMPOSE_EXTRA_OPTS:-}"


while :; do
    case $1 in
        #################################################
        # Disable color
        #################################################
        --no-ansi)
            DOCKER_COMPOSE_EXTRA_OPTS+=" --no-ansi"
            unset COLOR_R COLOR_G COLOR_Y COLOR_B COLOR_M COLOR_C COLOR_RESET
            ;;
        #################################################
        # Version switches
        #################################################
        --latest)
            export AQUARIUS_VERSION=${AQUARIUS_VERSION:-latest}
            export BRIZO_VERSION=${BRIZO_VERSION:-latest}
            export KEEPER_VERSION=${KEEPER_VERSION:-latest}
            export PLEUSTON_VERSION=${PLEUSTON_VERSION:-latest}
            printf $COLOR_Y'Switched to latest components...\n\n'$COLOR_RESET
            ;;
        --stable)
            export AQUARIUS_VERSION=${AQUARIUS_VERSION:-stable}
            export BRIZO_VERSION=${BRIZO_VERSION:-stable}
            export KEEPER_VERSION=${KEEPER_VERSION:-stable}
            export PLEUSTON_VERSION=${PLEUSTON_VERSION:-stable}
            printf $COLOR_Y'Switched to stable components...\n\n'$COLOR_RESET
            ;;
        --force-pull)
            export FORCEPULL="true"
            printf $COLOR_Y'Pulling the latest revision of the used Docker images...\n\n'$COLOR_RESET
            ;;
        #################################################
        # Exclude switches
        #################################################
        --no-pleuston)
            COMPOSE_FILES="${COMPOSE_FILES/ -f ${COMPOSE_DIR}\/pleuston.yml/}"
            printf $COLOR_Y'Starting without Pleuston...\n\n'$COLOR_RESET
            ;;
        --no-brizo)
            COMPOSE_FILES="${COMPOSE_FILES/ -f ${COMPOSE_DIR}\/brizo.yml/}"
            printf $COLOR_Y'Starting without Brizo...\n\n'$COLOR_RESET
            ;;
        --no-aquarius)
            COMPOSE_FILES="${COMPOSE_FILES/ -f ${COMPOSE_DIR}\/aquarius_mongodb.yml/}"
            printf $COLOR_Y'Starting without Aquarius...\n\n'$COLOR_RESET
            ;;
        --no-secret-store)
            COMPOSE_FILES="${COMPOSE_FILES/ -f ${COMPOSE_DIR}\/secret_store.yml/}"
            printf $COLOR_Y'Starting without Secret Store...\n\n'$COLOR_RESET
            ;;

        #################################################
        # Only Secret Store
        #################################################
        --only-secret-store)
            COMPOSE_FILES=""
            COMPOSE_FILES+=" -f ${COMPOSE_DIR}/network_volumes.yml"
            COMPOSE_FILES+=" -f ${COMPOSE_DIR}/secret_store.yml"
            NODE_COMPOSE_FILE=""
            printf $COLOR_Y'Starting only Secret Store...\n\n'$COLOR_RESET
            ;;
        #################################################
        # Elasticsearch
        #################################################
        --elasticsearch)
            COMPOSE_FILES+=" -f ${COMPOSE_DIR}/aquarius_elasticsearch.yml"
            COMPOSE_FILES="${COMPOSE_FILES/ -f ${COMPOSE_DIR}\/aquarius_mongodb.yml/}"
            export DB_MODULE="elasticsearch"
            export DB_HOSTNAME="elasticsearch"
            export DB_PORT="9200"
            export DB_USERNAME="elastic"
            export DB_PASSWORD="changeme"
            export DB_SSL="false"
            export DB_VERIFY_CERTS="false"
            export DB_CA_CERTS=""
            export DB_CLIENT_KEY=""
            export DB_CLIENT_CERT=""
            printf $COLOR_Y'Starting with Elasticsearch...\n\n'$COLOR_RESET
            ;;
        #################################################
        # Contract/Storage switches
        #################################################
        --reuse-ganache-database)
            export GANACHE_REUSE_DATABASE="true"
            printf $COLOR_Y'Starting and reusing the database...\n\n'$COLOR_RESET
            ;;
        #################################################
        # Secret-Store validation switch
        #################################################
        --no-acl-contract)
            export CONFIGURE_ACL="false"
            printf $COLOR_Y'Disabling acl validation in secret-store...\n\n'$COLOR_RESET
            ;;
        #################################################
        # Node type switches
        #################################################
        # connects you to kovan
        --local-kovan-node)
            export NODE_COMPOSE_FILE="${COMPOSE_DIR}/nodes/kovan_node.yml"
            COMPOSE_FILES="${COMPOSE_FILES/ -f ${COMPOSE_DIR}\/keeper_contracts.yml/}"
            COMPOSE_FILES="${COMPOSE_FILES/ -f ${COMPOSE_DIR}\/secret_store.yml/}"
            export KEEPER_MNEMONIC=''
            export KEEPER_NETWORK_NAME="kovan"
            export KEEPER_DEPLOY_CONTRACTS="false"
            export ACL_CONTRACT_ADDRESS="$(get_acl_address ${KEEPER_VERSION})"
            printf $COLOR_Y'Starting with local Kovan node...\n\n'$COLOR_RESET
            printf $COLOR_Y'Starting without Secret Store...\n\n'$COLOR_RESET
            ;;
        # spins up a new ganache blockchain
        --local-ganache-node)
            export NODE_COMPOSE_FILE="${COMPOSE_DIR}/nodes/ganache_node.yml"
            export KEEPER_MNEMONIC=''
            export KEEPER_NETWORK_NAME="development"
            export KEEPER_DEPLOY_CONTRACTS="true"
            printf $COLOR_Y'Starting with local Ganache node...\n\n'$COLOR_RESET
            ;;
        # connects you to nile ocean testnet
        --local-nile-node)
            export NODE_COMPOSE_FILE="${COMPOSE_DIR}/nodes/nile_node.yml"
            COMPOSE_FILES="${COMPOSE_FILES/ -f ${COMPOSE_DIR}\/keeper_contracts.yml/}"
            COMPOSE_FILES="${COMPOSE_FILES/ -f ${COMPOSE_DIR}\/secret_store.yml/}"
            export KEEPER_MNEMONIC=''
            export KEEPER_NETWORK_NAME="nile"
            export KEEPER_DEPLOY_CONTRACTS="false"
            export ACL_CONTRACT_ADDRESS="$(get_acl_address ${KEEPER_VERSION})"
            printf $COLOR_Y'Starting with local Nile node...\n\n'$COLOR_RESET
            printf $COLOR_Y'Starting without Secret Store...\n\n'$COLOR_RESET
            ;;
        # spins up spree local testnet
        --local-spree-node)
            export NODE_COMPOSE_FILE="${COMPOSE_DIR}/nodes/spree_node.yml"
            # use this seed only on spree!
            export KEEPER_MNEMONIC="taxi music thumb unique chat sand crew more leg another off lamp"
            export KEEPER_NETWORK_NAME="spree"
            export KEEPER_DEPLOY_CONTRACTS="true"
            printf $COLOR_Y'Starting with local Spree node...\n\n'$COLOR_RESET
            ;;
        #################################################
        # Cleaning switches
        #################################################
        --purge)
            printf $COLOR_R'Doing a deep clean ...\n\n'$COLOR_RESET
            docker-compose --project-name=$PROJECT_NAME $COMPOSE_FILES -f ${NODE_COMPOSE_FILE} down
            docker network rm ${PROJECT_NAME}_default || true
            docker network rm ${PROJECT_NAME}_backend || true
            docker network rm ${PROJECT_NAME}_secretstore || true
            docker volume rm ${PROJECT_NAME}_keeper-node || true
            docker volume rm ${PROJECT_NAME}_secret-store || true
            read -p "Are you sure you want to delete $KEEPER_ARTIFACTS_FOLDER? " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]
            then
                rm -rf "${KEEPER_ARTIFACTS_FOLDER}"
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
            configure_secret_store
            [ ! -z ${NODE_COMPOSE_FILE} ] && COMPOSE_FILES+=" -f ${NODE_COMPOSE_FILE}"
            [ ${KEEPER_DEPLOY_CONTRACTS} = "true" ] && clean_local_contracts
            [ ${FORCEPULL} = "true" ] && docker-compose $DOCKER_COMPOSE_EXTRA_OPTS --project-name=$PROJECT_NAME $COMPOSE_FILES pull
            eval docker-compose $DOCKER_COMPOSE_EXTRA_OPTS --project-name=$PROJECT_NAME $COMPOSE_FILES up --remove-orphans
            break
    esac
    shift
done
