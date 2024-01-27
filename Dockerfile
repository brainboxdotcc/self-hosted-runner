# base image
FROM ubuntu:22.04

# input GitHub runner version argument
ARG RUNNER_VERSION
ARG ARCH
ENV DEBIAN_FRONTEND=noninteractive

LABEL Author="Craig Edwards"
LABEL Email="ci@dpp.dev"
LABEL GitHub="https://github.com/brainboxdotcc"
LABEL BaseImage="ubuntu:22.04"
LABEL RunnerVersion=${RUNNER_VERSION}

# update the base packages + add a non-sudo user
RUN apt-get update -y && apt-get upgrade -y && useradd -m docker

# install the packages and dependencies along with jq so we can parse JSON (add additional packages as necessary)
RUN apt-get install -y --no-install-recommends \
    curl nodejs wget unzip vim git "g++-12" cmake libssl-dev libopus-dev zlib1g-dev libsodium-dev jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip sudo pkg-config

# cd into the user directory, download and unzip the github actions runner
RUN cd /home/docker && mkdir actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-${ARCH}-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-${ARCH}-${RUNNER_VERSION}.tar.gz

# install some additional dependencies
RUN perl -p -i -e "s/liblttng-ust0/liblttng-ust1/g" /home/docker/actions-runner/bin/installdependencies.sh
RUN echo "docker ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN chown -R docker ~docker && /home/docker/actions-runner/bin/installdependencies.sh

# add over the start.sh script
ADD scripts/start.sh start.sh

# make the script executable
RUN chmod +x start.sh

# set the user to "docker" so all subsequent commands are run as the docker user
USER docker

# set the entrypoint to the start.sh script
ENTRYPOINT ["./start.sh"]

