#!/usr/bin/env bash
#
# Copyright (c) 2020 Ocean Protocol contributors
# SPDX-License-Identifier: Apache-2.0
#
# Usage: ./start_ocean.sh
#

IP="localhost"
optspec=":-:"
while getopts "$optspec" optchar; do
    case "${optchar}" in
           -)
           case "${OPTARG}" in
                exposeip)
                    IP="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                 ;;
            esac;;
    esac
done

set -e

# Patch $DIR if spaces
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
DIR="${DIR/ /\\ }"
COMPOSE_DIR="${DIR}/compose-files"

# Default versions of Aquarius, Provider

export AQUARIUS_VERSION=${AQUARIUS_VERSION:-v2.1.6}
export PROVIDER_VERSION=${PROVIDER_VERSION:-latest}
export CONTRACTS_VERSION=${CONTRACTS_VERSION:-v0.5.7}
export PROJECT_NAME="ocean"
export FORCEPULL="false"

# Export User UID and GID
export LOCAL_USER_ID=$(id -u)
export LOCAL_GROUP_ID=$(id -g)


# Specify the ethereum default RPC container provider
if [ ${IP} = "localhost" ]; then
    export NETWORK_RPC_HOST="172.15.0.3"
else
    export NETWORK_RPC_HOST=${IP}
fi
export NETWORK_RPC_PORT="8545"
export NETWORK_RPC_URL="http://"${NETWORK_RPC_HOST}:${NETWORK_RPC_PORT}
# Use this seed on ganache to always create the same wallets
export GANACHE_MNEMONIC=${GANACHE_MNEMONIC:-"taxi music thumb unique chat sand crew more leg another off lamp"}

# Ocean contracts
export OCEAN_HOME="${HOME}/.ocean"
export CONTRACTS_OWNER_ROLE_ADDRESS="${CONTRACTS_OWNER_ROLE_ADDRESS}"
export DEPLOY_CONTRACTS=true
export OCEAN_ARTIFACTS_FOLDER="${OCEAN_HOME}/ocean-contracts/artifacts"
export ADDRESS_FILE="${OCEAN_ARTIFACTS_FOLDER}/address.json"
echo "export ADDRESS_FILE=${ADDRESS_FILE}"
# Specify which ethereum client to run or connect to: development
export CONTRACTS_NETWORK_NAME="development"

# Default Aquarius parameters: use Elasticsearch
export DB_MODULE="elasticsearch"
export DB_HOSTNAME="172.15.0.6"
export DB_PORT="9200"
export DB_USERNAME="elastic"
export DB_PASSWORD="changeme"
export DB_SSL="false"
export DB_VERIFY_CERTS="false"
export DB_CA_CERTS=""
export DB_CLIENT_KEY=""
export DB_CLIENT_CERT=""
CHECK_ELASTIC_VM_COUNT=true


#Provider
export PROVIDER_LOG_LEVEL=INFO
export PROVIDER_WORKERS=1
export PROVIDER_IPFS_GATEWAY=https://ipfs.oceanprotocol.com
export PROVIDER_PRIVATE_KEY=0xfd5c1ccea015b6d663618850824154a3b3fb2882c46cefb05b9a93fea8c3d215

if [ ${IP} = "localhost" ]; then
    export AQUARIUS_URI=http://172.15.0.5:5000
else
    export AQUARIUS_URI=http://${IP}:5000
fi

#export OPERATOR_SERVICE_URL=http://127.0.0.1:8050
export OPERATOR_SERVICE_URL=https://operator-api.operator.dev-ocean.com


# Add aquarius to /etc/hosts
# Workaround mainly for macOS

if [ ${IP} = "localhost" ]; then
	if grep -q "aquarius" /etc/hosts; then
    		echo "aquarius exists"
	else
    		echo "127.0.0.1 aquarius" | sudo tee -a /etc/hosts
	fi
fi

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


function check_if_owned_by_root {
    if [ -d "$OCEAN_HOME" ]; then
        uid=$(ls -nd "$OCEAN_HOME" | awk '{print $3;}')
        if [ "$uid" = "0" ]; then
            printf $COLOR_R"WARN: $OCEAN_HOME is owned by root\n"$COLOR_RESET >&2
        else
            uid=$(ls -nd "$OCEAN_ARTIFACTS_FOLDER" | awk '{print $3;}')
            if [ "$uid" = "0" ]; then
                printf $COLOR_R"WARN: $OCEAN_ARTIFACTS_FOLDER is owned by root\n"$COLOR_RESET >&2
            fi
        fi
    fi
}


function check_max_map_count {
  vm_max_map_count=$(docker run --rm busybox sysctl -q vm.max_map_count)
  vm_max_map_count=${vm_max_map_count##* }
  vm_max_map_count=262144
  if [ $vm_max_map_count -lt 262144 ]; then
    printf $COLOR_R'vm.max_map_count current kernel value ($vm_max_map_count) is too low for Elasticsearch\n'$COLOR_RESET
    printf $COLOR_R'You must update vm.max_map_count to at least 262144\n'$COLOR_RESET
    printf $COLOR_R'Please refer to https://www.elastic.co/guide/en/elasticsearch/reference/6.6/vm-max-map-count.html\n'$COLOR_RESET
    exit 1
  fi
}

function clean_local_contracts {
    rm -f "${OCEAN_ARTIFACTS_FOLDER}/ready"
    rm -f "${OCEAN_ARTIFACTS_FOLDER}/*.json"
}

check_if_owned_by_root
show_banner

COMPOSE_FILES=""
COMPOSE_FILES+=" -f ${COMPOSE_DIR}/network_volumes.yml"
COMPOSE_FILES+=" -f ${COMPOSE_DIR}/dashboard.yml"
COMPOSE_FILES+=" -f ${COMPOSE_DIR}/aquarius.yml"
COMPOSE_FILES+=" -f ${COMPOSE_DIR}/provider.yml"
COMPOSE_FILES+=" -f ${COMPOSE_DIR}/ganache.yml"
COMPOSE_FILES+=" -f ${COMPOSE_DIR}/ocean_contracts.yml"

DOCKER_COMPOSE_EXTRA_OPTS="${DOCKER_COMPOSE_EXTRA_OPTS:-}"

while :; do
    case $1 in
        --exposeip)
	   ;;
        #################################################
        # Disable color
        #################################################
        --no-ansi)
            DOCKER_COMPOSE_EXTRA_OPTS+=" --no-ansi"
            unset COLOR_R COLOR_G COLOR_Y COLOR_B COLOR_M COLOR_C COLOR_RESET
            ;;
        --force-pull)
            export FORCEPULL="true"
            printf $COLOR_Y'Pulling the latest revision of the used Docker images...\n\n'$COLOR_RESET
            ;;
        #################################################
        # Exclude switches
        #################################################
        --no-provider)
            COMPOSE_FILES="${COMPOSE_FILES/ -f ${COMPOSE_DIR}\/provider.yml/}"
            printf $COLOR_Y'Starting without Provider...\n\n'$COLOR_RESET
            ;;
        --no-ganache)
            COMPOSE_FILES="${COMPOSE_FILES/ -f ${COMPOSE_DIR}\/ganache.yml/}"
            COMPOSE_FILES="${COMPOSE_FILES/ -f ${COMPOSE_DIR}\/ocean_contracts.yml/}"
            printf $COLOR_Y'Starting without Ganache...\n\n'$COLOR_RESET
            ;;
        --no-aquarius)
            COMPOSE_FILES="${COMPOSE_FILES/ -f ${COMPOSE_DIR}\/aquarius.yml/}"
            printf $COLOR_Y'Starting without Aquarius...\n\n'$COLOR_RESET
            ;;
        --no-dashboard)
            COMPOSE_FILES="${COMPOSE_FILES/ -f ${COMPOSE_DIR}\/dashboard.yml/}"
            printf $COLOR_Y'Starting without Dashboard ...\n\n'$COLOR_RESET
            ;;
        --skip-deploy)
            export DEPLOY_CONTRACTS=false
            printf $COLOR_Y'Ocean contracts will not be deployed, the last deployment (if any) will be intact ...\n\n'$COLOR_RESET
            ;;
        #################################################
        # Cleaning switches
        #################################################
        --purge)
            printf $COLOR_R'Doing a deep clean ...\n\n'$COLOR_RESET
            eval docker-compose --project-name=$PROJECT_NAME "$COMPOSE_FILES" -f "${NODE_COMPOSE_FILE}" down
            docker network rm ${PROJECT_NAME}_default || true
            docker network rm ${PROJECT_NAME}_backend || true
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
            [ ${CHECK_ELASTIC_VM_COUNT} = "true" ] && check_max_map_count
            printf $COLOR_Y'Starting Ocean V3...\n\n'$COLOR_RESET
            [ ${DEPLOY_CONTRACTS} = "true" ] && clean_local_contracts
            [ ${FORCEPULL} = "true" ] && eval docker-compose "$DOCKER_COMPOSE_EXTRA_OPTS" --project-name=$PROJECT_NAME "$COMPOSE_FILES" pull
            eval docker-compose "$DOCKER_COMPOSE_EXTRA_OPTS" --project-name=$PROJECT_NAME "$COMPOSE_FILES" up --remove-orphans
            break
    esac
    shift
done
