#!/usr/bin/env bash

set -e

import com.encodeering.ci.config
import com.encodeering.ci.docker

docker-pull "$REPOSITORY/debian-$ARCH:buster" "debian:buster-slim"

docker-build "$PROJECT/stable/buster"
