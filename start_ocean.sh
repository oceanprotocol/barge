#!/usr/bin/env bash
#
# Copyright (c) 2023 Ocean Protocol contributors
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
export TYPESENSE_VERSION=${TYPESENSE_VERSION:-0.25.1}
export AQUARIUS_VERSION=${AQUARIUS_VERSION:-v5.1.5}
export ELASTICSEARCH_VERSION=${ELASTICSEARCH_VERSION:-8.5.1}
export PROVIDER_VERSION=${PROVIDER_VERSION:-v2.1.6}
export SUBGRAPH_VERSION=${SUBGRAPH_VERSION:-v4.0.2}
export CONTRACTS_VERSION=${CONTRACTS_VERSION:-v2.2.1}
export RBAC_VERSION=${RBAC_VERSION:-next}
export GRAPH_NODE_VERSION=${GRAPH_NODE_VERSION:-v0.33.0}

export OPERATOR_SERVICE_VERSION=${OPERATOR_SERVICE_VERSION:-oceanprotocol/operator-service:v4main}
export OPERATOR_ENGINE_VERSION=${OPERATOR_ENGINE_VERSION:-oceanprotocol/operator-engine:v4main}
export POD_CONFIGURATION_VERSION=${POD_CONFIGURATION_VERSION:-oceanprotocol/pod-configuration:v4main}
export POD_PUBLISHING_VERSION=${POD_PUBLISHING_VERSION:-oceanprotocol/pod-publishing:v4main}
export WAIT_FOR_C2DIMAGES=${WAIT_FOR_C2DIMAGES:-false}

export PDR_PUBLISHER_VERSION=${PDR_PUBLISHER_VERSION:-latest}
export PDR_BACKEND_VERSION=${PDR_BACKEND_VERSION:-latest}


export PROJECT_NAME="ocean"
export FORCEPULL="false"


# Export LOG LEVEL
export AQUARIUS_LOG_LEVEL=${AQUARIUS_LOG_LEVEL:-INFO}
export PROVIDER_LOG_LEVEL=${PROVIDER_LOG_LEVEL:-INFO}
export SUBGRAPH_LOG_LEVEL=${SUBGRAPH_LOG_LEVEL:-info}

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
export GANACHE_INSTAMINE=${GANACHE_INSTAMINE:-"eager"}
export GANACHE_BLOCKTIME=${GANACHE_BLOCKTIME:-0}
export GANACHE_FORK=${GANACHE_FORK:-"istanbul"}
# Ocean contracts
export OCEAN_HOME="${HOME}/.ocean"
export CONTRACTS_OWNER_ROLE_ADDRESS="${CONTRACTS_OWNER_ROLE_ADDRESS}"
export DEPLOY_CONTRACTS=true
export DEPLOY_SUBGRAPH=true
export OCEAN_ARTIFACTS_FOLDER="${OCEAN_HOME}/ocean-contracts/artifacts"
mkdir -p ${OCEAN_ARTIFACTS_FOLDER}
export OCEAN_C2D_FOLDER="${OCEAN_HOME}/ocean-c2d/"
mkdir -p ${OCEAN_C2D_FOLDER}
export OCEAN_SUBGRAPH_FOLDER="${OCEAN_HOME}/ocean-subgraph/"
rm -f "${OCEAN_SUBGRAPH_FOLDER}/ready"
mkdir -p ${OCEAN_SUBGRAPH_FOLDER}

export ADDRESS_FILE="${OCEAN_ARTIFACTS_FOLDER}/address.json"
echo "export ADDRESS_FILE=${ADDRESS_FILE}"

#certs folder
export OCEAN_CERTS_FOLDER="${OCEAN_HOME}/ocean-certs/"
mkdir -p ${OCEAN_CERTS_FOLDER}
# copy certs
cp -r ./certs/* ${OCEAN_CERTS_FOLDER}
# Specify which ethereum client to run or connect to: development
export CONTRACTS_NETWORK_NAME="development"

# Default Aquarius parameters: use Elasticsearch
export EVENTS_MONITOR_SLEEP_TIME=5
export DB_MODULE="elasticsearch"
export DB_HOSTNAME="http://172.15.0.6"
export DB_PORT="9200"
export DB_USERNAME="elastic"
export DB_PASSWORD="changeme"
export DB_SSL="false"
export DB_VERIFY_CERTS="false"
export DB_CA_CERTS=""
export DB_CLIENT_KEY=""
export DB_CLIENT_CERT=""
CHECK_ELASTIC_VM_COUNT=true

export IPFS_GATEWAY=http://172.15.0.16:5001
export IPFS_HTTP_GATEWAY=http://172.15.0.16:8080/ipfs/
#Provider
export REQUEST_TIMEOUT=10
export PROVIDER_WORKERS=10
export PROVIDER_IPFS_GATEWAY=https://gateway.ipfs.io/
export PROVIDER_PRIVATE_KEY=0xfd5c1ccea015b6d663618850824154a3b3fb2882c46cefb05b9a93fea8c3d215
export PROVIDER2_PRIVATE_KEY=0xc852b55146fd168ec3d392bbd70988c18463efa460a395dede376453aca1180e

if [ ${IP} = "localhost" ]; then
    export AQUARIUS_URI=http://172.15.0.5:5000
else
    export AQUARIUS_URI=http://${IP}:5000
fi

#export OPERATOR_SERVICE_URL=http://127.0.0.1:8050
export OPERATOR_SERVICE_URL=${OPERATOR_SERVICE_URL:-"http://172.15.0.13:31000/"}

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
COMPOSE_FILES+=" -f ${COMPOSE_DIR}/elasticsearch.yml"
COMPOSE_FILES+=" -f ${COMPOSE_DIR}/ipfs.yml"
COMPOSE_FILES+=" -f ${COMPOSE_DIR}/provider.yml"
COMPOSE_FILES+=" -f ${COMPOSE_DIR}/redis.yml"
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
            COMPOSE_FILES="${COMPOSE_FILES/ -f ${COMPOSE_DIR}\/redis.yml/}"
            printf $COLOR_Y'Starting without Provider...\n\n'$COLOR_RESET
            ;;
	    --with-provider2)
	        COMPOSE_FILES+=" -f ${COMPOSE_DIR}/provider2.yml"
            printf $COLOR_Y'Starting with a 2nd Provider...\n\n'$COLOR_RESET
            ;;
        --with-registry)
            COMPOSE_FILES+=" -f ${COMPOSE_DIR}/registry.yml"
            printf $COLOR_Y'Starting with Registry...\n\n'$COLOR_RESET
            ;;
        --with-typesense)
	        COMPOSE_FILES+=" -f ${COMPOSE_DIR}/typesense.yml"
            printf $COLOR_Y'Starting with Typesense...\n\n'$COLOR_RESET
            ;;
        --with-c2d)
            COMPOSE_FILES+=" -f ${COMPOSE_DIR}/registry.yml"
	    COMPOSE_FILES+=" -f ${COMPOSE_DIR}/ipfs.yml"
            COMPOSE_FILES+=" -f ${COMPOSE_DIR}/c2d.yml"
            printf $COLOR_Y'Starting with C2D...\n\n'$COLOR_RESET
            ;;
        --with-rbac)
	        COMPOSE_FILES+=" -f ${COMPOSE_DIR}/rbac.yml"
            printf $COLOR_Y'Starting with RBAC Server...\n\n'$COLOR_RESET
            ;;
        --no-ipfs)
            COMPOSE_FILES="${COMPOSE_FILES/ -f ${COMPOSE_DIR}\/ipfs.yml/}"
	        printf $COLOR_Y'Starting without IPFS...\n\n'$COLOR_RESET
            ;;
        --with-thegraph)
            COMPOSE_FILES+=" -f ${COMPOSE_DIR}/thegraph.yml"
            printf $COLOR_Y'Starting with TheGraph...\n\n'$COLOR_RESET
            ;;
        --no-aquarius)
            COMPOSE_FILES="${COMPOSE_FILES/ -f ${COMPOSE_DIR}\/aquarius.yml/}"
            printf $COLOR_Y'Starting without Aquarius...\n\n'$COLOR_RESET
            ;;
        --no-elasticsearch)
            COMPOSE_FILES="${COMPOSE_FILES/ -f ${COMPOSE_DIR}\/elasticsearch.yml/}"
            printf $COLOR_Y'Starting without Elastic search...\n\n'$COLOR_RESET
            ;;
        --no-dashboard)
            COMPOSE_FILES="${COMPOSE_FILES/ -f ${COMPOSE_DIR}\/dashboard.yml/}"
            printf $COLOR_Y'Starting without Dashboard ...\n\n'$COLOR_RESET
            ;;
        --skip-deploy)
            export DEPLOY_CONTRACTS=false
            printf $COLOR_Y'Ocean contracts will not be deployed, the last deployment (if any) will be intact ...\n\n'$COLOR_RESET
            ;;
        --skip-subgraph-deploy)
            export DEPLOY_SUBGRAPH=false
            printf $COLOR_Y'Ocean subgraph will not be deployed, the last deployment (if any) will be intact ...\n\n'$COLOR_RESET
            ;;
        --predictoor)
            # Add what we need
            COMPOSE_FILES+=" -f ${COMPOSE_DIR}/thegraph.yml"
            # We should remove what is not needed for now, but ocean,py requires both aqua & provider
            #COMPOSE_FILES="${COMPOSE_FILES/ -f ${COMPOSE_DIR}\/provider.yml/}"
            #COMPOSE_FILES="${COMPOSE_FILES/ -f ${COMPOSE_DIR}\/redis.yml/}"
            #COMPOSE_FILES="${COMPOSE_FILES/ -f ${COMPOSE_DIR}\/aquarius.yml/}"
            #COMPOSE_FILES="${COMPOSE_FILES/ -f ${COMPOSE_DIR}\/elasticsearch.yml/}"
            #COMPOSE_FILES="${COMPOSE_FILES/ -f ${COMPOSE_DIR}\/dashboard.yml/}"
            # Enforce images
            #export CONTRACTS_VERSION=predictoor
            #export SUBGRAPH_VERSION=predictoor
            export PDR_BACKEND_VERSION=${PDR_BACKEND_VERSION:-latest}

            # replicate true blockchain behiavour
            export GANACHE_INSTAMINE=strict
            export GANACHE_BLOCKTIME=1
            ;;
        --with-pdr-trueval)
            COMPOSE_FILES+=" -f ${COMPOSE_DIR}/pdr-trueval.yml"
            printf $COLOR_Y'Starting with pdr-trueval...\n\n'$COLOR_RESET
            ;;
        --with-pdr-trader)
            COMPOSE_FILES+=" -f ${COMPOSE_DIR}/pdr-trader.yml"
            printf $COLOR_Y'Starting with pdr-trader...\n\n'$COLOR_RESET
            ;;
        --with-pdr-predictoor)
            COMPOSE_FILES+=" -f ${COMPOSE_DIR}/pdr-predictoor.yml"
            printf $COLOR_Y'Starting with pdr-predictoor...\n\n'$COLOR_RESET
            ;;
        --with-pdr-publisher)
            COMPOSE_FILES+=" -f ${COMPOSE_DIR}/pdr-publisher.yml"
            printf $COLOR_Y'Starting with pdr-publisher...\n\n'$COLOR_RESET
            ;;
        --with-pdr-dfbuyer)
            COMPOSE_FILES+=" -f ${COMPOSE_DIR}/pdr-dfbuyer.yml"
            printf $COLOR_Y'Starting with pdr-dfbuyer...\n\n'$COLOR_RESET
            ;;
        #################################################
        # Cleaning switches
        #################################################
        --purge)
            printf $COLOR_R'Doing a deep clean ...\n\n'$COLOR_RESET
            eval docker-compose --project-name=$PROJECT_NAME "$COMPOSE_FILES" down
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
            printf $COLOR_Y'Starting Ocean V4...\n\n'$COLOR_RESET
            [ ${DEPLOY_CONTRACTS} = "true" ] && clean_local_contracts
            [ ${FORCEPULL} = "true" ] && eval docker-compose "$DOCKER_COMPOSE_EXTRA_OPTS" --project-name=$PROJECT_NAME "$COMPOSE_FILES" pull
            eval docker compose "$DOCKER_COMPOSE_EXTRA_OPTS" --project-name=$PROJECT_NAME "$COMPOSE_FILES" up --remove-orphans
            break
    esac
    shift
done
