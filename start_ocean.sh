#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
export BRIZO_ENV_FILE="${DIR}/brizo.env"

# Patch $DIR if spaces (BRIZO_ENV_FILE does not need patch)
DIR="${DIR/ /\\ }"
COMPOSE_DIR="${DIR}/compose-files"

export PROJECT_NAME="ocean"
export FORCEPULL="false"

# default to known working versions
export NGINX_VERSION=${NGINX_VERSION:-"@sha256:385fbcf0f04621981df6c6f1abd896101eb61a439746ee2921b26abc78f45571"}
export MONGO_VERSION=${MONGO_VERSION:-"@sha256:bae5a3d6317038b9fc61735ace2e9cfadc8f5ce70338daf233cb846a1a40d929"}
export PARITY_VERSION=${PARITY_VERSION:-"@sha256:ce6381aa49084f5a7e031af37266f81c0fbf64bdefcf54a069ab0a96f37e61fe"}
export PARITY_ETHEREUM_VERSION=${PARITY_ETHEREUM_VERSION:-"@sha256:8eed2356d9d3c25c7e7e3d3e41a9d004a9b8d5b22f60e45e4229e2df861ab5d3"}
export AQUARIUS_VERSION=${AQUARIUS_VERSION:-"@sha256:f458a3ab49e2aed8e21801c33c586d17245d5654f7bb231083aea1b4b7d35a98"}
export BRIZO_VERSION=${BRIZO_VERSION:-"@sha256:ec554083332450d3d69c06b63b60cd846027c477bef8c40a8df61b5038d563f8"}
export KEEPER_VERSION=${KEEPER_VERSION:-"@sha256:e5fee9214c72ee6ab8c910f14b3e1a9d53080fbe9efbc2f76f5dd8149ee2675c"
export PLEUSTON_VERSION=${PLEUSTON_VERSION:-"@sha256:d7369a6585b699e14a65c0c9d829ef8a3d6ddf570ade3652f67cc4e34c7148b5"}

# keeper options
export KEEPER_DEPLOY_CONTRACTS="false"
export KEEPER_ARTIFACTS_FOLDER="${HOME}/.ocean/keeper-contracts/artifacts"
# Specify which ethereum client to run or connect to: development, kovan, spree or nile
export KEEPER_NETWORK_NAME="nile"
export NODE_COMPOSE_FILE="${COMPOSE_DIR}/nodes/nile_node.yml"

# Ganache specific option, these two options have no effect when not running ganache-cli
export GANACHE_DATABASE_PATH="${DIR}"
export GANACHE_REUSE_DATABASE="false"

# Specify the ethereum default RPC container provider
export KEEPER_RPC_HOST='keeper-node'
export KEEPER_RPC_PORT='8545'
export KEEPER_RPC_URL="http://"${KEEPER_RPC_HOST}:${KEEPER_RPC_PORT}
export KEEPER_MNEMONIC=''

# Enable acl-contract validation in Secret-store
export CONFIGURE_ACL="false"

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

show_banner() {
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
            printf $COLOR_Y'Switched to latest components...\n\n'$COLOR_RESET
            export NGINX_VERSION=":alpine"
            export MONGO_VERSION=":3.6"
            export PARITY_VERSION=":stable"
            export PARITY_ETHEREUM_VERSION=":master"
            export AQUARIUS_VERSION=":latest"
            export BRIZO_VERSION=":latest"
            export KEEPER_VERSION=":latest"
            export PLEUSTON_VERSION=":latest"
            ;;
        --force-pull)
            export FORCEPULL="true"
            printf $COLOR_Y'Pulling latest components...\n\n'$COLOR_RESET
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
            COMPOSE_FILES="${COMPOSE_FILES/ -f ${COMPOSE_DIR}\/aquarius.yml/}"
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
        # Contract/Storage switches
        #################################################
        --reuse-ganache-database)
            export GANACHE_REUSE_DATABASE="true"
            printf $COLOR_Y'Starting and reusing the database...\n\n'$COLOR_RESET
            ;;
        #################################################
        # Secret-Store validation switch
        #################################################
        --acl-contract)
            export CONFIGURE_ACL="true"
            printf $COLOR_Y'Enabling acl validation in secret-store...\n\n'$COLOR_RESET
            ;;
        #################################################
        # Node type switches
        #################################################
        # connects you to kovan
        --local-kovan-node)
            export NODE_COMPOSE_FILE="${COMPOSE_DIR}/nodes/kovan_node.yml"
            export KEEPER_NETWORK_NAME="kovan"
            printf $COLOR_Y'Starting with local Kovan node...\n\n'$COLOR_RESET
            ;;
        # spins up a new ganache blockchain
        --local-ganache-node)
            COMPOSE_FILES+=" -f ${COMPOSE_DIR}/keeper_contracts.yml"
            export NODE_COMPOSE_FILE="${COMPOSE_DIR}/nodes/ganache_node.yml"
            export KEEPER_NETWORK_NAME="development"
            export KEEPER_DEPLOY_CONTRACTS="true"
            rm -f ${KEEPER_ARTIFACTS_FOLDER}/ready
            printf $COLOR_Y'Starting with local Ganache node...\n\n'$COLOR_RESET
            ;;
        # connects you to nile ocean testnet
        --local-nile-node)
            export NODE_COMPOSE_FILE="${COMPOSE_DIR}/nodes/nile_node.yml"
            export KEEPER_NETWORK_NAME="nile"
            printf $COLOR_Y'Starting with local Nile node...\n\n'$COLOR_RESET
            ;;
        # spins up spree local testnet
        --local-spree-node)
            COMPOSE_FILES+=" -f ${COMPOSE_DIR}/keeper_contracts.yml"
            export NODE_COMPOSE_FILE="${COMPOSE_DIR}/nodes/spree_node.yml"
            # use this seed only on spree!
            export KEEPER_MNEMONIC="taxi music thumb unique chat sand crew more leg another off lamp"
            export KEEPER_NETWORK_NAME="spree"
            export KEEPER_DEPLOY_CONTRACTS="true"
            #rm -f ${KEEPER_ARTIFACTS_FOLDER}/ready
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
            [ ! -z ${NODE_COMPOSE_FILE} ] && COMPOSE_FILES+=" -f ${NODE_COMPOSE_FILE}"
            [ ${FORCEPULL} = "true" ] && docker-compose $DOCKER_COMPOSE_EXTRA_OPTS --project-name=$PROJECT_NAME $COMPOSE_FILES pull
            eval docker-compose $DOCKER_COMPOSE_EXTRA_OPTS --project-name=$PROJECT_NAME $COMPOSE_FILES up --remove-orphans
            break
    esac
    shift
done
