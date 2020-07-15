#!/usr/bin/env bash
# start_ocean.sh
# Copyright (c) 2019 Ocean Protocol contributors
# SPDX-License-Identifier: Apache-2.0
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

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
export BRIZO_ENV_FILE="${DIR}/brizo.env"

# Patch $DIR if spaces (BRIZO_ENV_FILE does not need patch)
DIR="${DIR/ /\\ }"
COMPOSE_DIR="${DIR}/compose-files"

# Default versions of Aquarius, Brizo, Keeper Contracts and Commons
export AQUARIUS_VERSION=${AQUARIUS_VERSION:-v3}
export PROVIDER_VERSION=${PROVIDER_VERSION:-latest}

export PROJECT_NAME="ocean"
export FORCEPULL="false"


# Specify the ethereum default RPC container provider
if [ ${IP} = "localhost" ]; then
    export KEEPER_RPC_HOST="172.15.0.3"
else
    export KEEPER_RPC_HOST=${IP}
fi
export KEEPER_RPC_PORT="8545"
export KEEPER_RPC_URL="http://"${KEEPER_RPC_HOST}:${KEEPER_RPC_PORT}
# Use this seed only on Spree! (Spree is the default.)
export GANACHE_MNEMONIC=${GANACHE_MNEMONIC:-"taxi music thumb unique chat sand crew more leg another off lamp"}


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
export PROVIDER_WORKERS=4   
export PROVIDER_IPFS_GATEWAY=https://ipfs.oceanprotocol.com
export PROVIDER_ENCRYPTED_KEY='{"id":"4fabd7bf-bf01-2df3-2791-75b1ef4eebae","version":3,"crypto":{"cipher":"aes-128-ctr","cipherparams":{"iv":"d427c17019b8e3e8f09f321e1976c80f"},"ciphertext":"4ff54c4f47da24dfe6a712a7bf9e715a18bd99f690eedcacc817af2e1d08c1cd","kdf":"pbkdf2","kdfparams":{"c":10240,"dklen":32,"prf":"hmac-sha256","salt":"fc6aef875f184722a70ad528f1b2efc5ceb868b6065b65630e50a83a458d2b50"},"mac":"4a40051eb54bef80b2cbcb209e2c8747531b0ee76d1a59b93d69b350be4af9dd"},"address":"00c6a0bc5cd0078d6cd0b659e8061b404cfa5704","name":"","meta":"{}"}'
export PROVIDER_ADDRESS=0x00c6a0bc5cd0078d6cd0b659e8061b404cfa5704
export PROVIDER_PASSWORD=9B4653C8AA99E707798D603F226A0687
export PROVIDER_KEYFILE="/accounts/provider.json"

if [ ${IP} = "localhost" ]; then
    export AQUARIUS_URI=http://172.15.0.5:5000
    export BRIZO_URL=http://172.15.0.4:8030
else
    export AQUARIUS_URI=http://${IP}:5000
    export BRIZO_URL=http://${IP}:8030
fi

#export OPERATOR_SERVICE_URL=http://127.0.0.1:8050
export OPERATOR_SERVICE_URL=https://operator-api.operator.dev-ocean.com


# Export User UID and GID
export LOCAL_USER_ID=$(id -u)
export LOCAL_GROUP_ID=$(id -g)


#add aquarius to /etc/hosts

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

function get_acl_address {
    # detect keeper version
    local version="${1:-latest}"

    # sesarch in the file for the keeper version
    line=$(grep "^${version}=" "${DIR}/ACL/${KEEPER_NETWORK_NAME}_addresses.txt")
    # set address
    address="${line##*=}"

    # if address is still empty
    if [ -z "${address}" ]; then
      # fetch from latest line
      line=$(grep "^latest=" "${DIR}/ACL/${KEEPER_NETWORK_NAME}_addresses.txt")
      # set address
      address="${line##*=}"
    fi

    echo "${address}"
}

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
            uid=$(ls -nd "$KEEPER_ARTIFACTS_FOLDER" | awk '{print $3;}')
            if [ "$uid" = "0" ]; then
                printf $COLOR_R"WARN: $KEEPER_ARTIFACTS_FOLDER is owned by root\n"$COLOR_RESET >&2
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

check_if_owned_by_root
show_banner

COMPOSE_FILES=""
COMPOSE_FILES+=" -f ${COMPOSE_DIR}/network_volumes.yml"
COMPOSE_FILES+=" -f ${COMPOSE_DIR}/dashboard.yml"
COMPOSE_FILES+=" -f ${COMPOSE_DIR}/aquarius_elasticsearch.yml"
COMPOSE_FILES+=" -f ${COMPOSE_DIR}/provider.yml"
COMPOSE_FILES+=" -f ${COMPOSE_DIR}/ganache.yml"
DOCKER_COMPOSE_EXTRA_OPTS="${DOCKER_COMPOSE_EXTRA_OPTS:-}"

while :; do
    case $1 in
        --exposeip)
	   ;;
        #################################################
        # Log level
        #################################################
        --debug)
            export BRIZO_LOG_LEVEL="DEBUG"
            export EVENTS_HANDLER_LOG_LEVEL="DEBUG"
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
            printf $COLOR_Y'Starting without Ganache...\n\n'$COLOR_RESET
            ;;
        --no-aquarius)
            COMPOSE_FILES="${COMPOSE_FILES/ -f ${COMPOSE_DIR}\/aquarius_elasticsearch.yml/}"
            printf $COLOR_Y'Starting without Aquarius...\n\n'$COLOR_RESET
            ;;
        --no-dashboard)
            COMPOSE_FILES="${COMPOSE_FILES/ -f ${COMPOSE_DIR}\/dashboard.yml/}"
            printf $COLOR_Y'Starting without Dashboard ...\n\n'$COLOR_RESET
            ;;
        #################################################
        # MongoDB
        #################################################
        --mongodb)
            COMPOSE_FILES+=" -f ${COMPOSE_DIR}/aquarius_mongodb.yml"
            COMPOSE_FILES="${COMPOSE_FILES/ -f ${COMPOSE_DIR}\/aquarius_elasticsearch.yml/}"
            CHECK_ELASTIC_VM_COUNT=false
            export DB_MODULE="mongodb"
            export DB_HOSTNAME="mongodb"
            export DB_PORT="27017"
            printf $COLOR_Y'Starting with MongoDB...\n\n'$COLOR_RESET
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
            [ ${FORCEPULL} = "true" ] && eval docker-compose "$DOCKER_COMPOSE_EXTRA_OPTS" --project-name=$PROJECT_NAME "$COMPOSE_FILES" pull
            eval docker-compose "$DOCKER_COMPOSE_EXTRA_OPTS" --project-name=$PROJECT_NAME "$COMPOSE_FILES" up --remove-orphans
            break
    esac
    shift
done
