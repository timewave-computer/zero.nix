import argparse
from pathlib import Path
from typing import Any
import tomli_w
import tomllib
from mergedeep import merge
parser = argparse.ArgumentParser(description="Merge multiple TOML files")
parser.add_argument(
    "files",
    type=Path,
    nargs="+",
    help="List of TOML files to merge",
)
args = parser.parse_args()
merged: dict[str, Any] = {}
for file in args.files:
    with open(file, "rb") as fh:
        loaded_toml = tomllib.load(fh)
        merged = merge(merged, loaded_toml)
print(tomli_w.dumps(merged))
