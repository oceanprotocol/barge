"""A useful collection of functions for the script."""

import os
import typing


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
    """Converts the given value to the value it used to have in the Bash script."""

    if isinstance(value, bool):
        return str(value).lower()
    return str(value)