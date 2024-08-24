#! /usr/bin/env bash

set -euo pipefail

url=${1}
tempdir=$(mktemp -d)

org=$(echo ${url=} | sed -n "s/https\:\/\/github.com\/\(.*\)\/\(.*\)/\1/p")
name=$(echo ${url=} | sed -n "s/https\:\/\/github.com\/\(.*\)\/\(.*\)/\2/p")
mkdir -p ${tempdir=}/${org=}/scripts/${name=}

cat <<EOF > ${tempdir}/${org=}/scripts/${name=}/postinstall.sh
#!/bin/sh
systemctl daemon-reload
systemctl enable ${name=}.service
EOF

cat <<EOF > ${tempdir}/${org=}/scripts/${name=}/preremove.sh
#!/bin/sh
systemctl stop ${name=}.service
systemctl disable ${name=}.service
EOF

echo "${tempdir=}/${org=}/scripts/${name=}"
