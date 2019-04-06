#!/usr/bin/env python

from pathlib import Path
import libs
import colorama
import argparse
from colors import *

# colorama is used for cross platform compatible terminal coloring


# DIR = "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
# BRIZO_ENV_FILE = "${DIR}/brizo.env".format(DIR)

# https://stackoverflow.com/questions/8365394/set-environment-variable-in-python-script



# make sure to export all the environment variables too to avoid breaking changes


DIR = libs.set_current_directory()
BRIZO_ENV_FILE = libs.export("BRIZO_ENV_FILE", DIR + "/brizo.env")

# print(DIR)
# print(BRIZO_ENV_FILE)

# # Patch $DIR if spaces (BRIZO_ENV_FILE does not need patch)
# DIR="${DIR/ /\\ }"
# COMPOSE_DIR="${DIR}/compose-files"

# ! above not needed because its Python? need to run tests to make sure

# export PROJECT_NAME="ocean"
# export FORCEPULL="false"

COMPOSE_DIR = libs.export("COMPOSE_DIR", DIR + "/compose-files")
PROJECT_NAME = libs.export("PROJECT_NAME", "ocean")
FORCEPULL = libs.export("FORCEPULL", "false")

# # default to latest versions
# export OCEAN_VERSION=stable

OCEAN_VERSION = libs.export("OCEAN_VERSION", "stable")

# keeper options
# export KEEPER_DEPLOY_CONTRACTS="false"
# export KEEPER_ARTIFACTS_FOLDER="${HOME}/.ocean/keeper-contracts/artifacts"
# # Specify which ethereum client to run or connect to: development, kovan, spree or nile
# export KEEPER_NETWORK_NAME="nile"
# export NODE_COMPOSE_FILE="${COMPOSE_DIR}/nodes/nile_node.yml"

KEEPER_DEPLOY_CONTRACTS = libs.export("KEEPER_DEPLOY_CONTRACTS", "false")

HOME = str(Path.home())

KEEPER_ARTIFACTS_FOLDER = libs.export("KEEPER_ARTIFACTS_FOLDER", HOME + "/.ocean/keeper-contracts/artifacts")

# Specify which ethereum client to run or connect to: development, kovan, spree or nile
KEEPER_NETWORK_NAME = libs.export("KEEPER_NETWORK_NAME", "nile")
# todo change this?
KEEPER_VERSION = libs.export("KEEPER_VERSION", "latest")

NODE_COMPOSE_FILE = libs.export("NODE_COMPOSE_FILE", COMPOSE_DIR + "/nodes/nile_node.yml")

# Ganache specific option, these two options have no effect when not running ganache-cli
# export GANACHE_DATABASE_PATH="${DIR}"
# export GANACHE_REUSE_DATABASE="false"

GANACHE_DATABASE_PATH = libs.export("GANACHE_DATABASE_PATH", DIR)
GANACHE_REUSE_DATABASE = libs.export("GANACHE_REUSE_DATABASE", "false")

# Specify the ethereum default RPC container provider
# export KEEPER_RPC_HOST='keeper-node'
# export KEEPER_RPC_PORT='8545'
# export KEEPER_RPC_URL="http://"${KEEPER_RPC_HOST}:${KEEPER_RPC_PORT}
# export KEEPER_MNEMONIC=''

KEEPER_RPC_HOST = libs.export("KEEPER_RPC_HOST", 'keeper-node')
KEEPER_RPC_PORT = libs.export("KEEPER_RPC_PORT", '8545')
KEEPER_RPC_URL = libs.export("KEEPER_RPC_URL", "http://{}:{}".format(KEEPER_RPC_HOST, KEEPER_RPC_PORT))
KEEPER_MNEMONIC = libs.export("KEEPER_MNEMONIC", '')

# # Enable acl-contract validation in Secret-store
# export CONFIGURE_ACL="true"
# export ACL_CONTRACT_ADDRESS=""

CONFIGURE_ACL = libs.export("CONFIGURE_ACL", "true")
ACL_CONTRACT_ADDRESS = libs.export("ACL_CONTRACT_ADDRESS", "")

# # Export User UID and GID
# export LOCAL_USER_ID=$(id -u)
# export LOCAL_GROUP_ID=$(id -g)

# LOCAL_USER_ID = libs.export("LOCAL_USER_ID", libs.run('id -u'))
LOCAL_USER_ID = libs.export("LOCAL_USER_ID", libs.get_user_id())
LOCAL_GROUP_ID = libs.export("LOCAL_GROUP_ID", libs.get_group_id())

# # colors
# COLOR_R="\033[0;31m"    # red
# COLOR_G="\033[0;32m"    # green
# COLOR_Y="\033[0;33m"    # yellow
# COLOR_B="\033[0;34m"    # blue
# COLOR_M="\033[0;35m"    # magenta
# COLOR_C="\033[0;36m"    # cyan



#! need to get arg 1 and store it

# function get_acl_address {

    #! takes param 1 if its not set sets it to -latest
#     local version="${1:-latest}"
#     line=$(grep "^${version}=" "${DIR}/${KEEPER_NETWORK_NAME}_acl_contract_addresses.txt")
#     address="${line##*=}"
#     [ -z "${address}" ] && echo "Cannot determine the ACL Contract Address for ${KEEPER_NETWORK_NAME} version ${version}. Exiting" && exit 1
#     echo "${address}"
# }

# function show_banner {
#     local output=$(cat .banner)
#     echo -e "$COLOR_B$output$COLOR_RESET"
#     echo ""
# }

# show_banner

# COMPOSE_FILES=""
# COMPOSE_FILES+=" -f ${COMPOSE_DIR}/network_volumes.yml"
# COMPOSE_FILES+=" -f ${COMPOSE_DIR}/pleuston.yml"
# COMPOSE_FILES+=" -f ${COMPOSE_DIR}/aquarius.yml"
# COMPOSE_FILES+=" -f ${COMPOSE_DIR}/brizo.yml"
# COMPOSE_FILES+=" -f ${COMPOSE_DIR}/secret_store.yml"

colorama.init()

libs.show_banner()

print(COLOR_RESET)


# DOCKER_COMPOSE_EXTRA_OPTS="${DOCKER_COMPOSE_EXTRA_OPTS:-}"

DOCKER_COMPOSE_EXTRA_OPTS = libs.export("DOCKER_COMPOSE_EXTRA_OPTS", '-')

parser = argparse.ArgumentParser(description='Barge makes it easy to build projects using the Ocean Protocol')


# ! add to docs that --help and -h display the help dialog

libs.add_cli_flags(
    parser,
    {
        'no-ansi': 'Disables text coloring',
        'latest': 'Pulls latest version of containers',
        'force-pull': 'Force docker to pull the components',
        'no-pleuston': 'Exclude Pleuston',
        'no-brizo': 'Exclude Brizo',
        'no-aquarius': 'Exclude Aquarius',
        'no-secret-store': 'Exclude secret store',
        'only-secret-store': 'Only launch the secret store',
        'reuse-ganache-database': 'Don\'t wipe the ganache database after reboot',
        'no-acl-contract': 'Disables ACL validation in secret store',
        'local-kovan-node': 'Use a local kovan node',
        'local-ganache-node': 'Use a local ganache node',
        'local-spree-node': 'Use a local spree node',
        'purge': 'Removes volumes and containers',
    },
)

compose_files = {
    "network_volumes",
    "pleuston",
    "aquarius",
    "brizo",
    "secret_store"
}

args = parser.parse_args()

if args.no_ansi:
    DOCKER_COMPOSE_EXTRA_OPTS = DOCKER_COMPOSE_EXTRA_OPTS + " --no-ansi"
    COLOR_R = ""
    COLOR_G = ""
    COLOR_Y = ""
    COLOR_B = ""
    COLOR_M = ""
    COLOR_C = ""
    COLOR_RESET = ""

if args.latest:
    libs.notify("Switched to latest components")
    # AQUARIUS_VERSION = libs.export()

    # todo ! look at what this flag does in the shell script with regards to below  vars

    # export AQUARIUS_VERSION=${AQUARIUS_VERSION:-$OCEAN_VERSION}
    # export BRIZO_VERSION=${BRIZO_VERSION:-$OCEAN_VERSION}
    # export KEEPER_VERSION=${KEEPER_VERSION:-$OCEAN_VERSION}
    # export PLEUSTON_VERSION=${PLEUSTON_VERSION:-$OCEAN_VERSION}

if args.force_pull:
    FORCEPULL = libs.export("FORCEPULL", "true")
    libs.notify("Pulling latest components")

if args.no_plueston:
    compose_files = libs.exclude(compose_files, 'pleuston')

if args.no_brizo:
    compose_files = libs.exclude(compose_files, 'brizo')

if args.no_aquarius:
    compose_files = libs.exclude(compose_files, 'aquarius')

if args.no_secret_store:
    compose_files = libs.exclude(compose_files, 'secret-store')

if args.only_secret_store:
    compose_files = {"network_volumes", "secret_store"}
    NODE_COMPOSE_FILE = ""
    libs.notify("Starting only secret store")

if args.reuse_ganache_database:
    GANACHE_REUSE_DATABASE = libs.export("GANACHE_REUSE_DATABASE", "true")
    libs.notify("Starting and reusing the database")

if args.no_acl_contract:
    CONFIGURE_ACL = libs.export("CONFIGURE_ACL", "false")
    libs.notify("Disabling acl validation in secret-store")

if args.local_kovan_node:
    NODE_COMPOSE_FILE = libs.export("NODE_COMPOSE_FILE", COMPOSE_DIR + "/nodes/kovan_node.yml")
    KEEPER_NETWORK_NAME = libs.export("KEEPER_NETWORK_NAME", "kovan")
    ACL_CONTRACT_ADDRESS = libs.export("ACL_CONTRACT_ADDRESS", libs.get_acl_address(KEEPER_VERSION))
    libs.notify("Starting with local Kovan node")

if args.local_ganache_node:

    compose_files.add("keeper_contracts")
    NODE_COMPOSE_FILE = libs.export("NODE_COMPOSE_FILE", COMPOSE_DIR + "/nodes/ganache_node.yml")
    KEEPER_NETWORK_NAME = libs.export("KEEPER_NETWORK_NAME", "development")
    KEEPER_DEPLOY_CONTRACTS = libs.export("KEEPER_DEPLOY_CONTRACTS", "true")
    libs.remove(KEEPER_ARTIFACTS_FOLDER + "/ready")
    libs.remove(KEEPER_ARTIFACTS_FOLDER + "/*.development.json")

    libs.notify("Starting with local Ganache node")

if args.local_nile_node:
    NODE_COMPOSE_FILE = libs.export("NODE_COMPOSE_FILE", COMPOSE_DIR + "/nodes/nile_node.yml")
    KEEPER_NETWORK_NAME = libs.export("KEEPER_NETWORK_NAME", "nile")
    ACL_CONTRACT_ADDRESS = libs.export("ACL_CONTRACT_ADDRESS", libs.get_acl_address(KEEPER_VERSION))
    libs.notify("Starting with local Nile node")

if args.local_spree_node:
    compose_files.add("keeper_contracts")
    NODE_COMPOSE_FILE = libs.export("NODE_COMPOSE_FILE", COMPOSE_DIR + "/nodes/spree_node.yml")

    # use this seed only on spree!
    KEEPER_MNEMONIC = libs.export("KEEPER_MNEMONIC", "taxi music thumb unique chat sand crew more leg another off lamp")
    KEEPER_NETWORK_NAME = libs.export("KEEPER_NETWORK_NAME", "spree")
    KEEPER_DEPLOY_CONTRACTS = libs.export("KEEPER_DEPLOY_CONTRACTS", "true")
    libs.remove(KEEPER_ARTIFACTS_FOLDER + "/ready")
    libs.remove(KEEPER_ARTIFACTS_FOLDER + "/*.spree.json")
    libs.notify('Starting with local Spree node')


if args.purge:
    libs.notify("Doing a deep clean")
    libs.run("docker-compose --project-name=$PROJECT_NAME $COMPOSE_FILES -f " + NODE_COMPOSE_FILE + " down")

    libs.docker("network rm " + PROJECT_NAME + "_default")
    libs.docker("network rm " + PROJECT_NAME + "_backend")
    libs.docker("network rm " + PROJECT_NAME + "_secretstore")
    libs.docker("volume rm " + PROJECT_NAME + "_keeper-node")
    libs.docker("volume rm " + PROJECT_NAME + "_secret-store")

    answer = input("Are you sure you want to delete " + KEEPER_ARTIFACTS_FOLDER + "? (Y/N)")

    while answer.lower() not in ('y', 'yes', 'n', 'no'):
        answer = input("Please provide either Y for yes or N for no as your answer")

    if answer.lower() in ('y', 'yes'):
        libs.delete_folder(KEEPER_ARTIFACTS_FOLDER)


    # todo continue from here


    # docker-compose --project-name=$PROJECT_NAME $COMPOSE_FILES -f ${NODE_COMPOSE_FILE} down
    # docker network rm ${PROJECT_NAME}_default || true
    # docker network rm ${PROJECT_NAME}_backend || true
    # docker network rm ${PROJECT_NAME}_secretstore || true
    # docker volume rm ${PROJECT_NAME}_keeper-node || true
    # docker volume rm ${PROJECT_NAME}_secret-store || true
    # read -p "Are you sure you want to delete $KEEPER_ARTIFACTS_FOLDER? " -n 1 -r
    # echo

    # prompt for yes or no as Yy or Nn only else reask
    # if [[ $REPLY =~ ^[Yy]$ ]]
    # then
    #     rm -rf "${KEEPER_ARTIFACTS_FOLDER}"
    # fi
    # ;;
#

# end of switches look at what the below thing does think it just breaks while loop
#
# --) # End of all options.
#             shift
#             break
#             ;;

# below is probably not needed
#         -?*)
#             printf $COLOR_R'WARN: Unknown option (ignored): %s\n'$COLOR_RESET "$1" >&2
#             break
#             ;;
#         *)

# actually boot up docker with the stuff now
#             printf $COLOR_Y'Starting Ocean...\n\n'$COLOR_RESET

# last minite add node compose file??? not sure waht the first bit does or the bit below
# check it out in shell without running docker think its just a if statement
#             [ ! -z ${NODE_COMPOSE_FILE} ] && COMPOSE_FILES+=" -f ${NODE_COMPOSE_FILE}"
#             [ ${FORCEPULL} = "true" ] && docker-compose $DOCKER_COMPOSE_EXTRA_OPTS --project-name=$PROJECT_NAME $COMPOSE_FILES pull
#             eval docker-compose $DOCKER_COMPOSE_EXTRA_OPTS --project-name=$PROJECT_NAME $COMPOSE_FILES up --remove-orphans
#             break
#     esac
#     shift
# done


# todo check github if keeper version is defined somewhere else


# create the list of files to pass to docker-compose
COMPOSE_FILES = " ".join(list(map(lambda x: "-f {}/{}.yml", compose_files)))


libs.notify('Starting Ocean')
# while :; do
#     case $1 in
#         #################################################
#         # Disable color
#         #################################################
#         --no-ansi)
#             DOCKER_COMPOSE_EXTRA_OPTS+=" --no-ansi"
#             unset COLOR_R COLOR_G COLOR_Y COLOR_B COLOR_M COLOR_C COLOR_RESET
#             ;;
#         #################################################
#         # Version switches
#         #################################################
#         --latest)
#             export OCEAN_VERSION=latest
#             printf $COLOR_Y'Switched to latest components...\n\n'$COLOR_RESET
#             export AQUARIUS_VERSION=${AQUARIUS_VERSION:-$OCEAN_VERSION}
#             export BRIZO_VERSION=${BRIZO_VERSION:-$OCEAN_VERSION}
#             export KEEPER_VERSION=${KEEPER_VERSION:-$OCEAN_VERSION}
#             export PLEUSTON_VERSION=${PLEUSTON_VERSION:-$OCEAN_VERSION}
#             ;;
#         --force-pull)
#             export FORCEPULL="true"
#             printf $COLOR_Y'Pulling latest components...\n\n'$COLOR_RESET
#             ;;
#         #################################################
#         # Exclude switches
#         #################################################
#         --no-pleuston)
#             COMPOSE_FILES="${COMPOSE_FILES/ -f ${COMPOSE_DIR}\/pleuston.yml/}"
#             printf $COLOR_Y'Starting without Pleuston...\n\n'$COLOR_RESET
#             ;;
#         --no-brizo)
#             COMPOSE_FILES="${COMPOSE_FILES/ -f ${COMPOSE_DIR}\/brizo.yml/}"
#             printf $COLOR_Y'Starting without Brizo...\n\n'$COLOR_RESET
#             ;;
#         --no-aquarius)
#             COMPOSE_FILES="${COMPOSE_FILES/ -f ${COMPOSE_DIR}\/aquarius.yml/}"
#             printf $COLOR_Y'Starting without Aquarius...\n\n'$COLOR_RESET
#             ;;
#         --no-secret-store)
#             COMPOSE_FILES="${COMPOSE_FILES/ -f ${COMPOSE_DIR}\/secret_store.yml/}"
#             printf $COLOR_Y'Starting without Secret Store...\n\n'$COLOR_RESET
#             ;;

#         #################################################
#         # Only Secret Store
#         #################################################
#         --only-secret-store)
#             COMPOSE_FILES=""
#             COMPOSE_FILES+=" -f ${COMPOSE_DIR}/network_volumes.yml"
#             COMPOSE_FILES+=" -f ${COMPOSE_DIR}/secret_store.yml"
#             NODE_COMPOSE_FILE=""
#             printf $COLOR_Y'Starting only Secret Store...\n\n'$COLOR_RESET
#             ;;
#         #################################################
#         # Contract/Storage switches
#         #################################################
#         --reuse-ganache-database)
#             export GANACHE_REUSE_DATABASE="true"
#             printf $COLOR_Y'Starting and reusing the database...\n\n'$COLOR_RESET
#             ;;
#         #################################################
#         # Secret-Store validation switch
#         #################################################
#         --no-acl-contract)
#             export CONFIGURE_ACL="false"
#             printf $COLOR_Y'Disabling acl validation in secret-store...\n\n'$COLOR_RESET
#             ;;
#         #################################################
#         # Node type switches
#         #################################################
#         # connects you to kovan
#         --local-kovan-node)
#             export NODE_COMPOSE_FILE="${COMPOSE_DIR}/nodes/kovan_node.yml"
#             export KEEPER_NETWORK_NAME="kovan"
#             export ACL_CONTRACT_ADDRESS="$(get_acl_address ${KEEPER_VERSION})"
#             printf $COLOR_Y'Starting with local Kovan node...\n\n'$COLOR_RESET
#             ;;
#         # spins up a new ganache blockchain
#         --local-ganache-node)
#             COMPOSE_FILES+=" -f ${COMPOSE_DIR}/keeper_contracts.yml"
#             export NODE_COMPOSE_FILE="${COMPOSE_DIR}/nodes/ganache_node.yml"
#             export KEEPER_NETWORK_NAME="development"
#             export KEEPER_DEPLOY_CONTRACTS="true"
#             rm -f ${KEEPER_ARTIFACTS_FOLDER}/ready
#             rm -f ${KEEPER_ARTIFACTS_FOLDER}/*.development.json
#             printf $COLOR_Y'Starting with local Ganache node...\n\n'$COLOR_RESET
#             ;;
#         # connects you to nile ocean testnet
#         --local-nile-node)
#             export NODE_COMPOSE_FILE="${COMPOSE_DIR}/nodes/nile_node.yml"
#             export KEEPER_NETWORK_NAME="nile"
#             export ACL_CONTRACT_ADDRESS="$(get_acl_address ${KEEPER_VERSION})"
#             printf $COLOR_Y'Starting with local Nile node...\n\n'$COLOR_RESET
#             ;;
#         # spins up spree local testnet
#         --local-spree-node)
#             COMPOSE_FILES+=" -f ${COMPOSE_DIR}/keeper_contracts.yml"
#             export NODE_COMPOSE_FILE="${COMPOSE_DIR}/nodes/spree_node.yml"
#             # use this seed only on spree!
#             export KEEPER_MNEMONIC="taxi music thumb unique chat sand crew more leg another off lamp"
#             export KEEPER_NETWORK_NAME="spree"
#             export KEEPER_DEPLOY_CONTRACTS="true"
#             rm -f ${KEEPER_ARTIFACTS_FOLDER}/ready
#             rm -f ${KEEPER_ARTIFACTS_FOLDER}/*.spree.json
#             printf $COLOR_Y'Starting with local Spree node...\n\n'$COLOR_RESET
#             ;;
#         #################################################
#         # Cleaning switches
#         #################################################
#         --purge)
#             printf $COLOR_R'Doing a deep clean ...\n\n'$COLOR_RESET
#             docker-compose --project-name=$PROJECT_NAME $COMPOSE_FILES -f ${NODE_COMPOSE_FILE} down
#             docker network rm ${PROJECT_NAME}_default || true
#             docker network rm ${PROJECT_NAME}_backend || true
#             docker network rm ${PROJECT_NAME}_secretstore || true
#             docker volume rm ${PROJECT_NAME}_keeper-node || true
#             docker volume rm ${PROJECT_NAME}_secret-store || true
#             read -p "Are you sure you want to delete $KEEPER_ARTIFACTS_FOLDER? " -n 1 -r
#             echo
#             if [[ $REPLY =~ ^[Yy]$ ]]
#             then
#                 rm -rf "${KEEPER_ARTIFACTS_FOLDER}"
#             fi
#             ;;
#         --) # End of all options.
#             shift
#             break
#             ;;
#         -?*)
#             printf $COLOR_R'WARN: Unknown option (ignored): %s\n'$COLOR_RESET "$1" >&2
#             break
#             ;;
#         *)
#             printf $COLOR_Y'Starting Ocean...\n\n'$COLOR_RESET
#             [ ! -z ${NODE_COMPOSE_FILE} ] && COMPOSE_FILES+=" -f ${NODE_COMPOSE_FILE}"
#             [ ${FORCEPULL} = "true" ] && docker-compose $DOCKER_COMPOSE_EXTRA_OPTS --project-name=$PROJECT_NAME $COMPOSE_FILES pull
#             eval docker-compose $DOCKER_COMPOSE_EXTRA_OPTS --project-name=$PROJECT_NAME $COMPOSE_FILES up --remove-orphans
#             break
#     esac
#     shift
# done
