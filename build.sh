#!/bin/sh
#
# build by specifying architecture on command line:
#
# ./build.sh arm
# ./build.sh arm64
#
docker build --build-arg ARCH=$1 RUNNER_VERSION=2.311.0 --tag docker-github-runner-lin .
