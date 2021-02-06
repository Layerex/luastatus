#!/usr/bin/env bash

set -e

opwd=$PWD
cd -- "$(dirname "$(readlink "$0" || printf '%s\n' "$0")")"

source ./utils.lib.bash

if (( $# != 1 )); then
    echo >&2 "USAGE: $0 <build root>"
    exit 2
fi
BUILD_DIR=$(resolve_relative "$1" "$opwd")

LUASTATUS=(
    "$BUILD_DIR"/luastatus/luastatus ${DEBUG:+-l trace}
)

VALGRIND=(
    valgrind --error-exitcode=42
)

run1() {
    local n=$1 m=$2 sep_st=$3 event_beg event_end
    if (( sep_st )); then
        event_beg='function()'
        event_end='end'
    else
        event_beg='[['
        event_end=']]'
    fi
    shift 3
    "${VALGRIND[@]}" "$@" "${LUASTATUS[@]}" -e -b "$BUILD_DIR"/tests/barlib-mock.so -B gen_events="$m" <(cat <<__EOF__
n = 0
widget = {
    plugin = '$BUILD_DIR/tests/plugin-mock.so',
    opts = {
        make_calls = $n,
    },
    cb = function()
        n = n + 1
        if n % 10000 == 0 then
            --print('--- n = ' .. n .. ' ---')
        end
    end,
    event = $event_beg
        m = (m or 0) + 1
        if m % 10000 == 0 then
            --print('--- m = ' .. m .. ' ---')
        end
    $event_end,
}
__EOF__
)
}

run2() {
    run1 "$1" "$2" 0 "${@:3}"
    run1 "$1" "$2" 1 "${@:3}"
}

run2 10000 10000 \
    --suppressions=dlopen.supp \
    --leak-check=full \
    --show-leak-kinds=all \
    --errors-for-leak-kinds=all \
    --track-fds=yes
# Interesting options:
#     --fair-sched=yes

run2 100000 100000 \
    --tool=helgrind

echo >&2 "=== PASSED ==="
