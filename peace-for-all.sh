#!/usr/bin/env bash
#
# peace-for-all.sh: a rewrite of the easter egg printed on the back of the
# UNIQLO x Akamai "PEACE FOR ALL" T-shirt.
#
# A message is printed one character per line, swinging left and right along
# a sine wave and cycling through a rainbow of 256-color ANSI codes.
#
# Compatible with bash 3.2 (the default on macOS) and later.

set -u

readonly DEFAULT_TEXT="♥PEACE♥FOR♥ALL"
readonly DEFAULT_DELAY="0.03"
readonly WAVE_STEPS=32   # frames for one full left-right swing

# Rainbow through the 256-color cube: red, orange, yellow, green, cyan, blue, magenta.
PALETTE=(196 202 208 214 220 226 190 154 118 82 46 47 48 49 50 51
         45 39 33 27 21 57 93 129 165 201 200 199 198 197)
readonly PALETTE

text=$DEFAULT_TEXT
delay=$DEFAULT_DELAY
max_lines=0              # 0 = run forever
cols=80
wave=()                  # precomputed x offsets for one swing

usage() {
    cat <<EOF
Usage: ${0##*/} [-t TEXT] [-d DELAY] [-n LINES] [-h]

  -t TEXT    message to animate (default: "$DEFAULT_TEXT")
  -d DELAY   seconds between lines (default: $DEFAULT_DELAY)
  -n LINES   stop after LINES lines (default: run until Ctrl+C)
  -h         show this help
EOF
}

die() {
    printf '%s: %s\n' "${0##*/}" "$1" >&2
    exit 2
}

parse_args() {
    local opt
    while getopts ":t:d:n:h" opt; do
        case $opt in
            t) text=$OPTARG ;;
            d) delay=$OPTARG ;;
            n) max_lines=$OPTARG ;;
            h) usage; exit 0 ;;
            :) die "option -$OPTARG needs a value" ;;
            *) die "unknown option -$OPTARG (see -h)" ;;
        esac
    done

    [ -n "$text" ] || die "text must not be empty"
    case $max_lines in ''|*[!0-9]*) die "-n expects a whole number" ;; esac
    case $delay in ''|*[!0-9.]*) die "-d expects a number of seconds" ;; esac
}

# Read the terminal width and precompute the wave for it. The original script
# piped every frame through `bc` three times; computing a single period once
# with awk keeps the loop free of subprocesses (apart from the sleep).
measure() {
    cols=$(tput cols 2>/dev/null) || cols=80
    [ "$cols" -gt 1 ] 2>/dev/null || cols=80

    wave=()
    local x
    while read -r x; do
        wave+=("$x")
    done < <(awk -v cols="$cols" -v steps="$WAVE_STEPS" 'BEGIN {
        pi = atan2(0, -1)
        for (i = 0; i < steps; i++) {
            x = int(cols / 2 + cols / 4 * sin(2 * pi * i / steps) + 0.5)
            if (x > cols - 1) x = cols - 1
            if (x < 0) x = 0
            print x
        }
    }')
}

# Bash slices strings by character only under a UTF-8 locale; otherwise the
# multi-byte hearts would be cut in half.
use_utf8_locale() {
    case ${LC_ALL:-${LC_CTYPE:-${LANG:-}}} in
        *[Uu][Tt][Ff]-8*|*[Uu][Tt][Ff]8*) return ;;
    esac
    local loc
    for loc in C.UTF-8 en_US.UTF-8; do
        if [ "$(LC_ALL=$loc locale charmap 2>/dev/null)" = "UTF-8" ]; then
            export LC_ALL=$loc
            return
        fi
    done
}

cleanup() {
    printf '\033[0m'
    tput cnorm 2>/dev/null
}

main() {
    parse_args "$@"

    use_utf8_locale

    measure
    trap measure WINCH
    trap cleanup EXIT
    trap 'exit 130' INT
    trap 'exit 143' TERM
    tput civis 2>/dev/null

    local t=0 len=${#text} ncolors=${#PALETTE[@]}
    while [ "$max_lines" -eq 0 ] || [ "$t" -lt "$max_lines" ]; do
        printf '%*s\033[38;5;%sm%s\033[0m\n' \
            "${wave[t % WAVE_STEPS]}" '' \
            "${PALETTE[t % ncolors]}" \
            "${text:t % len:1}"
        t=$((t + 1))
        sleep "$delay"
    done
}

main "$@"
