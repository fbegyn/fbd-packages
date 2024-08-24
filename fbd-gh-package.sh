#! /usr/bin/env bash

# setup some basic variables for script processing. By default we also
# do ARCH=amd64
ROOT=$(pwd)
tempdir=$(mktemp -d)
ARCH=${1:-amd64}

# I need the entire lines, not the whitespace seperated list items
# so we just change the IFS function here temporary and set it back
# later
old="$IFS"
IFS='
'
for line in $(< ./gh-projects.url); do
    # set the IFS back to what it was before after reading the file
    IFS=$old

    # convert the line into array of [ url, version ]
    temp=($line)

    # extract the organisation and project name from the URL
    url=${temp[0]}
    ORG=$(echo ${url=} | sed -n "s/https\:\/\/github.com\/\(.*\)\/\(.*\)/\1/p")
    NAME=$(echo ${url=} | sed -n "s/https\:\/\/github.com\/\(.*\)\/\(.*\)/\2/p")

    # generate a tempdir for the downloads etc.
    mkdir -p ${tempdir=}/${ORG=}

    # if there is a version, no need to git clone, we can go directly to downloading
    # if there is no version, we need to fetch the latest tag for the project
    if [[ ${#temp[@]} -gt 2 ]]; then
        mkdir -p ${tempdir=}/${ORG=}/${NAME=}
        cd ${tempdir=}/${ORG=}/${NAME=}
        TAG=${temp[2]}
    else
        git clone -q "${url=}.git" ${tempdir=}/${ORG=}/${NAME=}
        cd ${tempdir=}/${ORG=}/${NAME=}
        TAG=$(git describe --tags --abbrev=0)
    fi
    # for dowloading, we need the version with the `v` prefix, so just drop it
    VERSION=${TAG#"v"}

    # actually download the damm thing after loading the path and constructing the download url
    path=$(eval echo "${temp[1]}")
    download="${url=}${path=}"
    echo "[INFO] downloading from ${download=}"
    curl -fSL -o "${tempdir=}/${ORG=}/${NAME=}/$(basename ${path=})" "${download=}"
    echo "[INFO] file downloaded to ${tempdir=}/${ORG=}/${NAME=}/$(basename ${path=})"

    # if we downloaded a compressed file, uncompress and unpack it
    if [[ ${path=} == *.tar.gz ]]; then
      echo "[INFO] unpacking $(basename ${path=})"
      tar --strip-components=1 -xzvf ${tempdir=}/${ORG=}/${NAME=}/$(basename ${path=})
    fi

    cd ${tempdir=}/${ORG=}/${NAME=}

    # render some unit/deb/rpm scripts for when installing and removing. This generally
    # boils down to inserting the right name in some scripts.
    SCRIPTDIR=$(${ROOT=}/gen-scripts.sh ${url=})

    # substitute some variables in the nfpm file. We have seperate nfpm file instead of a general
    # one since each project brings it's own binaries and config files.
    # TODO: evaluate if this is the best approach
    ROOT=${ROOT=} VERSION=${TAG=} ORG=${ORG=} NAME=${NAME=} SCRIPTDIR=${SCRIPTDIR=} ARCH=${ARCH=} envsubst < ${ROOT}/nfpms/nfpm-${NAME=}.yaml > ./nfpm-temp.yaml

    # build a .deb and .rpm package
    nfpm pkg --packager deb --config="nfpm-temp.yaml"
    nfpm pkg --packager rpm --config="nfpm-temp.yaml"

    echo "[INFO] packaged ${NAME=} into a .deb and .rpm package"
    echo "[INFO] packages for ${NAME=} available in $(pwd), moving to ${ROOT=}"
    mv $(pwd)/*.deb ${ROOT=}
    mv $(pwd)/*.rpm ${ROOT=}
    echo ""
done

