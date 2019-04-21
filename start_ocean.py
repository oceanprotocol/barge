#!/usr/bin/env python

from pathlib import Path
import libs
import colorama
import argparse
from colors import COLOR_RESET

# colorama is used for cross platform compatible terminal coloring


# https://stackoverflow.com/questions/8365394/set-environment-variable-in-python-script



# make sure to export all the environment variables too to avoid breaking changes


DIR = libs.set_current_directory()
BRIZO_ENV_FILE = libs.export("BRIZO_ENV_FILE", DIR + "/brizo.env")


# # Patch $DIR if spaces (BRIZO_ENV_FILE does not need patch)
# DIR="${DIR/ /\\ }"
# COMPOSE_DIR="${DIR}/compose-files"

# ! above not needed because its Python? need to run tests to make sure


COMPOSE_DIR = libs.export("COMPOSE_DIR", DIR + "/compose-files")
PROJECT_NAME = libs.export("PROJECT_NAME", "ocean")
FORCEPULL = libs.export("FORCEPULL", "false")

# # default to latest versions
# export OCEAN_VERSION=stable

OCEAN_VERSION = libs.export("OCEAN_VERSION", "stable")

# defining to make sure scope is handled correctly
AQUARIUS_VERSION = None
BRIZO_VERSION = None
KEEPER_VERSION = None
PLEUSTON_VERSION = None

# keeper options

KEEPER_DEPLOY_CONTRACTS = libs.export("KEEPER_DEPLOY_CONTRACTS", "false")

HOME = str(Path.home())

KEEPER_ARTIFACTS_FOLDER = libs.export("KEEPER_ARTIFACTS_FOLDER", HOME + "/.ocean/keeper-contracts/artifacts")

# Specify which ethereum client to run or connect to: development, kovan, spree or nile
KEEPER_NETWORK_NAME = libs.export("KEEPER_NETWORK_NAME", "nile")
# todo change this?
KEEPER_VERSION = libs.export("KEEPER_VERSION", "latest")

NODE_COMPOSE_FILE = libs.export("NODE_COMPOSE_FILE", COMPOSE_DIR + "/nodes/nile_node.yml")

# Ganache specific option, these two options have no effect when not running ganache-cli

GANACHE_DATABASE_PATH = libs.export("GANACHE_DATABASE_PATH", DIR)
GANACHE_REUSE_DATABASE = libs.export("GANACHE_REUSE_DATABASE", "false")

# Specify the ethereum default RPC container provider

KEEPER_RPC_HOST = libs.export("KEEPER_RPC_HOST", 'keeper-node')
KEEPER_RPC_PORT = libs.export("KEEPER_RPC_PORT", '8545')
KEEPER_RPC_URL = libs.export("KEEPER_RPC_URL", "http://{}:{}".format(KEEPER_RPC_HOST, KEEPER_RPC_PORT))
KEEPER_MNEMONIC = libs.export("KEEPER_MNEMONIC", '')

# Enable acl-contract validation in Secret-store

CONFIGURE_ACL = libs.export("CONFIGURE_ACL", "true")
ACL_CONTRACT_ADDRESS = libs.export("ACL_CONTRACT_ADDRESS", "")

LOCAL_USER_ID = libs.export("LOCAL_USER_ID", libs.get_user_id())
LOCAL_GROUP_ID = libs.export("LOCAL_GROUP_ID", libs.get_group_id())


colorama.init()

libs.show_banner()

print(COLOR_RESET)


# if extra ops is empty or null set it to blank
DOCKER_COMPOSE_EXTRA_OPTS = libs.export("DOCKER_COMPOSE_EXTRA_OPTS", libs.default("DOCKER_COMPOSE_EXTRA_OPTS", ""))

parser = argparse.ArgumentParser(description='Barge makes it easy to build projects using the Ocean Protocol')


# ! add to docs that --help and -h display the help dialog

libs.add_cli_flags(
    parser,
    {
        'no-ansi': 'Disables text coloring in the terminal.',
        'latest': '"latest" means to use the latest "develop" branches whereas "stable" means to use the last "stable" releases.',
        'force-pull': 'Force pulling the latest revision of the used docker images.',
        'no-pleuston': 'Start up Ocean without the "pleuston" Building Block. Helpful for development on "pleuston".',
        'no-brizo': 'Start up Ocean without the "brizo" Building Block.',
        'no-aquarius': 'Start up Ocean without the "aquarius" Building Block.',
        'no-secret-store': 'Start up Ocean without the "secret-store" Building Block.',
        'only-secret-store': 'Only launch the secret store.',
        'reuse-ganache-database': 'Don\'t wipe the ganache database after reboot',
        'no-acl-contract': 'Configures secret-store "acl_contract" option to disable secret-store authorization.',
        'local-kovan-node': 'Runs a light node of the "kovan" network and connects the node',
        'local-ganache-node': 'Configures a running ganache node to use a persistent database.',
        'local-nile-node': 'Runs a node of the "nile" network and connects the node to the "nile" network.',
        'local-spree-node': 'Runs a node of the local "spree" network.',
        'purge': 'Removes the containers, volumes, artifact folder and networks used by the script.',
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
    libs.unset_colors()
    COLOR_RESET = ""

if args.latest:

    libs.notify("Switched to latest components")
    AQUARIUS_VERSION = libs.export("AQUARIUS_VERSION", libs.default("AQUARIUS_VERSION", OCEAN_VERSION))
    BRIZO_VERSION = libs.export("BRIZO_VERSION", libs.default("BRIZO_VERSION", OCEAN_VERSION))
    KEEPER_VERSION = libs.export("KEEPER_VERSION", libs.default("KEEPER_VERSION", OCEAN_VERSION))
    PLEUSTON_VERSION = libs.export("PLEUSTON_VERSION", libs.default("PLEUSTON_VERSION", OCEAN_VERSION))


if args.force_pull:
    FORCEPULL = libs.export("FORCEPULL", "true")
    libs.notify("Pulling latest components")

if args.no_pleuston:
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
    ACL_CONTRACT_ADDRESS = libs.export("ACL_CONTRACT_ADDRESS", libs.get_acl_address('.', 'kovan', KEEPER_VERSION))
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
    ACL_CONTRACT_ADDRESS = libs.export("ACL_CONTRACT_ADDRESS", libs.get_acl_address('.', 'nile', KEEPER_VERSION))
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


# create the list of files to pass to docker-compose
COMPOSE_FILES = " ".join(list(map(lambda x: "-f {}/{}.yml".format(COMPOSE_DIR, x), compose_files)))


if args.purge:
    libs.notify("Doing a deep clean")
    libs.run("docker-compose --project-name {} {} -f {} down".format(PROJECT_NAME, COMPOSE_FILES, NODE_COMPOSE_FILE))

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


libs.notify('Starting Ocean')

# create the list of files to pass to docker-compose
COMPOSE_FILES = " ".join(list(map(lambda x: "-f {}/{}.yml".format(COMPOSE_DIR, x), compose_files)))

if len(NODE_COMPOSE_FILE) > 0:
    COMPOSE_FILES = COMPOSE_FILES + " -f " + NODE_COMPOSE_FILE

if FORCEPULL == "true":
    libs.run("docker-compose {} --project-name={} {} pull".format(DOCKER_COMPOSE_EXTRA_OPTS, PROJECT_NAME, COMPOSE_FILES))

libs.run('docker-compose {} --project-name={} {} up --remove-orphans'.format(DOCKER_COMPOSE_EXTRA_OPTS, PROJECT_NAME, COMPOSE_FILES))
