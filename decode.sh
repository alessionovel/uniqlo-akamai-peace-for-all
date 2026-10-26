#!/usr/bin/env bash
#
# decode.sh: print the code hidden on the T-shirt without running it.
#
# The shirt runs `eval "$(base64 -d <<< '...')"`, which executes whatever the
# base64 string contains. Running unknown code like that is how malware often
# spreads, so this script only extracts and decodes the payload.
#
# Usage: ./decode.sh [FILE]   (default: original/tshirt-code.sh)

set -eu

file=${1:-"$(dirname "$0")/original/tshirt-code.sh"}
[ -r "$file" ] || { echo "decode.sh: cannot read $file" >&2; exit 1; }

# Keep only what sits between the quotes after `<<<`, then decode it.
sed -n "/<<< '/,/'/p" "$file" \
    | sed -e "s/.*<<< '//" -e "s/'.*//" \
    | tr -d ' \n' \
    | base64 --decode
