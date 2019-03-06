"""A useful collection of functions for the script."""

import os
import typing
import subprocess
import colorama

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
    print(colorama.Fore.BLUE + libs.read(".banner") + "\n")