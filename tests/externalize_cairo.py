"""Make internal cairo functions external to be able to test them
This module contains functions to do that for lines of code, files and directories
It could also be called as a script
"""

from mailbox import ExternalClashError
from multiprocessing.sharedctypes import Value
import os
from pathlib import Path
import sys


FUNC_DEFINITION = "func"
EXTERNAL_DECORATOR = "@external"
DECORATOR_SYMBOL = "@"


def externalize(lines: list[str]):
    for index, line in enumerate(lines):
        func_index = line.find(FUNC_DEFINITION)
        if func_index != -1:
            previous_line = lines[index - 1]
            if (
                len(previous_line) > func_index
                and previous_line[func_index] == DECORATOR_SYMBOL
            ):
                yield line
                continue

            decorating_line = " " * func_index + EXTERNAL_DECORATOR + "\n"

            yield decorating_line
            yield line

        else:
            yield line


def externalize_file(input_path, output_path):
    with open(input_path) as f:
        lines = externalize(f.readlines())

    with open(output_path, "w") as f:
        f.writelines(lines)


def externalize_dir(input_dir, output_dir):
    os.makedirs(output_dir, exist_ok=True)
    for dir_path, _, filenames in os.walk(input_dir):
        for filename in filenames:
            input_path = os.path.join(dir_path, filename)

            output_file_dir = os.path.join(
                output_dir, dir_path.removeprefix(input_dir).lstrip("/")
            )
            os.makedirs(output_file_dir, exist_ok=True)

            output_path = os.path.join(output_file_dir, filename)
            externalize_file(input_path, output_path)


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Error: missing arguments")
        print("Usage: externalize_cairo.py INPUT_PATH OUTPUT_PATH")
        sys.exit()

    input_path = sys.argv[1]
    output_path = sys.argv[2]

    input_is_dir = Path(input_path).is_dir()
    output_is_dir = Path(output_path).is_dir()

    if input_is_dir == output_is_dir == True:
        externalize_dir(input_path, output_path)
    elif input_is_dir == output_is_dir == False:
        externalize_file(input_path, output_path)
    else:
        print("Error: input and output should be either both files or directories")
