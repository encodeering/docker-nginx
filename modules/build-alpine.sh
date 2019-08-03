#!/usr/bin/env bash

set -e

import com.encodeering.ci.config
import com.encodeering.ci.docker

docker-pull "$REPOSITORY/alpine-$ARCH:3.9" "alpine:3.9"

docker-build -t "nginx:alpine" "$PROJECT/stable/alpine"
docker-build --suffix sequel sequel

docker-verify --suffix sequel -V 2>&1 | dup | contains "nginx/${VERSION}"
