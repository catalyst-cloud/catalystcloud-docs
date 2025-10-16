#!/bin/bash -x

set -euo pipefail

groupadd -g "${GID}" sphinx
useradd -u "${UID}" -g "${GID}" -d /opt/workspace sphinx

if [ "${1}" = "--cli" ]; then
    apt-get update
    apt-get install -y gosu
    exec gosu sphinx bash
fi

env="${1}"
shift

#if [ -n "$*" ]; then
#    sudo --user=sphinx --preserve-env --set-home sphinx --verbose -e "${env}" -- "$@"
#else
#    sudo --user=sphinx --preserve-env --set-home sphinx --verbose -e "${env}"
#fi
($env)