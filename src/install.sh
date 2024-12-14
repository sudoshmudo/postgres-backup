#! /bin/sh

set -eux
set -o pipefail

apk update

# install pg_dump
apk add postgresql-client=17.2

# install gpg
apk add gnupg

apk add python3
apk add py3-pip  # separate package on edge only
pip3 install awscli

# cleanup
rm -rf /var/cache/apk/*
