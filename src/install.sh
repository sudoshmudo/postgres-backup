#! /bin/sh

set -eux
set -o pipefail

apk update

# install pg_dump
apk add postgresql-client

# install gpg
apk add gnupg

apk add python3
apk add py3-pip  # separate package on edge only
pipx install awscli

# cleanup
rm -rf /var/cache/apk/*
