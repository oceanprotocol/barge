"""A useful collection of functions for the script."""

import os
import typing
import subprocess
import colorama
import sys
from colors import *


def set_current_directory() -> str:
    """
    Set the current directory to the location of the script.

    Returns the absolute path to the current directory.
    """
    file_path = os.path.abspath(__file__)
    directory = os.path.dirname(file_path)
    os.chdir(directory)
    return directory


def export(variable: str, value: typing.Any) -> typing.Any:
    """
    Mimics Bash variable export.

    Used to temporarily set environment variables for
    other commands, eg: docker compose commands
    that are executed from this script.
    Returns the value it was passed to make creating variables
    easier.
    """
    os.environ[variable] = convert_to_string(value)
    return value


def convert_to_string(value: typing.Any) -> str:
    """Convert the given value to the value it used to have in the Bash script."""
    if isinstance(value, bool):
        return str(value).lower()
    return str(value)


def read(file_name: str) -> str:
    """Read a file using the best practices with statement."""
    with open(file_name, 'r') as file:
        return file.read()


def run(command: str) -> str:
    """Emulate Bash command execution using shell argument for now to keep things simple."""
    return subprocess.check_output(command, shell=True)


def show_banner():
    """Replicate the show_banner bash function."""
    print(colorama.Fore.BLUE + read(".banner"))


def get_user_id():
    """Return the current users' UID"""
    return os.getuid()


def get_group_id():
    """Return the current GID"""
    return os.getgid()


def get_acl_address(directory: str, keeper_network_name: str, version: str = '-latest') -> str:
    """Return the ACL address"""
    #! takes param 1 from cmd if its not set sets it to -latest

    text = read("{}/{}_acl_contract_addresses.txt".format(directory, keeper_network_name))
    lines = text.splitlines()

    # remove title
    del lines[0]

    # get keys and values
    key_value_pairs = list(map(lambda x: x.split('='), lines))

    addresses = dict(key_value_pairs)

    if version not in addresses:
        print('Cannot determine the ACL Contract Address for {} version {}. Exiting'.format(keeper_network_name, version))
        sys.exit(1)

    return addresses[version]


def add_cli_flags(parser, flags: dict):
    """Adds each flag to the CLI. Accepts a dictionary containing the name of the flag and its help description."""

    for flag, help in flags.items():
        parser.add_argument('--' + flag, action='store_true', help=help)


def print_switch_message(msg: str):
    print(COLOR_Y + msg + "...\n\n" + COLOR_RESET)

    # line =

#     line=$(grep "^${version}=" "${DIR}/${KEEPER_NETWORK_NAME}_acl_contract_addresses.txt")
#     address="${line##*=}"
#     [ -z "${address}" ] && echo "Cannot determine the ACL Contract Address for ${KEEPER_NETWORK_NAME} version ${version}. Exiting" && exit 1
#     echo "${address}"
