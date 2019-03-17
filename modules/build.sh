#!/usr/bin/env bash

set -e

import com.encodeering.ci.config
import com.encodeering.ci.docker

./build-${BASE}.sh

docker-verify nginx -V 2>&1 | dup | contains "nginx/${VERSION}"
