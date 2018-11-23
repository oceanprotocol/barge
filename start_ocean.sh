#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
# Must be set to true for the first run, change it to "false" to avoid migrating the smart contracts on each run.
export DEPLOY_CONTRACTS="true"
# Ganache specific option, these two options have no effect when not running ganache-cli
export GANACHE_DATABASE_PATH="."
export REUSE_DATABASE="false"
# Specify which ethereum client to run or connect to: kovan, ganache, or ocean_poa_net_local
export KEEPER_NETWORK_NAME="ganache"
export ARTIFACTS_FOLDER=~/.ocean/keeper-contracts/artifacts

# colors
COLOR_R="\033[0;31m"    # red
COLOR_G="\033[0;32m"    # green
COLOR_Y="\033[0;33m"    # yellow
COLOR_B="\033[0;34m"    # blue
COLOR_M="\033[0;35m"    # magenta
COLOR_C="\033[0;36m"    # cyan

# reset
COLOR_RESET="\033[00m"

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
COMPOSE_FILE='docker-compose.yml'

# other default values
KOVAN_ADDRESS_FILE="$DIR/parity/kovan/account.json"
KOVAN_PASSWORD_FILE="$DIR/parity/kovan/password"

while :; do
    case $1 in
        --latest)
            export OCEAN_VERSION=latest
            printf $COLOR_Y'Switched to latest components...\n\n'$COLOR_RESET
            ;;
        --reuse-database)
            export REUSE_DATABASE="true"
            printf $COLOR_Y'Starting and reusing the database ...\n\n'$COLOR_RESET
            ;;
        --no-pleuston)
            COMPOSE_FILE="$DIR/docker-compose-no-pleuston.yml"
            printf $COLOR_Y'Starting without Pleuston...\n\n'$COLOR_RESET
            ;;
        --local-parity-node)
            export KEEPER_NETWORK_NAME="ocean_poa_net_local"
            COMPOSE_FILE="$DIR/docker-compose-local-parity-node.yml"
            printf $COLOR_Y'Starting with local Parity node...\n\n'$COLOR_RESET
            ;;
        --kovan-parity-node)
            [ -f "$KOVAN_ADDRESS_FILE" ] || error "Kovan account json file not found in $KOVAN_ADDRESS_FILE"
            [ -f "$KOVAN_PASSWORD_FILE" ] || error "Kovan account password file not found in $KOVAN_PASSWORD_FILE"
            [ -z "$UNLOCK_ADDRESS" ] && error "Kovan account address must be exported in variable \$UNLOCK_ADDRESS"
            COMPOSE_FILE='docker-compose-only-parity.yml'
            ;;
        --testnet-parity-node)
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
            docker-compose --project-name=ocean -f $COMPOSE_FILE up
            break
    esac
    shift
done
