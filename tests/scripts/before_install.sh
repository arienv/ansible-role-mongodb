#!/usr/bin/env bash
# -*- mode: sh; -*-

# File: before_install.sh
# Time-stamp: <2018-07-12 18:05:37>
# Copyright (C) 2018 Sergei Antipov
# Description:

# set -o xtrace
set -o nounset
set -o errexit
set -o pipefail

# Latest Ansible install
pip install docker ansible mitogen

MITOGEN_LOC=$(pip show mitogen | awk '/Location: /{print $2}')
export ANSIBLE_STRATEGY_PLUGINS=${MITOGEN_LOC}/strategy

cat << EOF > ansible.cfg
[defaults]
pipelining = True
strategy = mitogen_linear
strategy_plugins = ${ANSIBLE_STRATEGY_PLUGINS}

EOF

cat ansible.cfg

# Pull docker image or build it
if [ -f tests/Dockerfile.${DISTRIBUTION}_${DIST_VERSION} ]
then
    docker build --rm=true --file=tests/Dockerfile.${DISTRIBUTION}_${DIST_VERSION} --tag ${DISTRIBUTION}:${DIST_VERSION} tests
else
    docker pull ${DISTRIBUTION}:${DIST_VERSION}
fi

ln -s ${PWD} tests/greendayonfire.mongodb
