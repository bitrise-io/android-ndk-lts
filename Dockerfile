FROM quay.io/bitriseio/android-ndk:v2018_05_05-06_07-b990

ENV TOOL_VER_BITRISE_CLI="1.41.2" \
    TOOL_VER_GO="1.13"

# ------------------------------------------------------

RUN apt-get update -qq


# ------------------------------------------------------
# --- Git config
RUN git config --global user.email "please-set-your-email@bitrise.io" \
    && git config --global user.name "J. Doe (https://devcenter.bitrise.io/builds/setting-your-git-credentials-on-build-machines/)"

# ------------------------------------------------------
# --- SSH config

COPY ./ssh/config /root/.ssh/config


# ------------------------------------------------------
# --- Bitrise CLI

#
# Install Bitrise CLI
RUN curl -fL https://github.com/bitrise-io/bitrise/releases/download/${TOOL_VER_BITRISE_CLI}/bitrise-$(uname -s)-$(uname -m) > /usr/local/bin/bitrise
RUN chmod +x /usr/local/bin/bitrise
RUN bitrise setup
RUN bitrise envman -version
RUN bitrise stepman -version
# setup the default StepLib collection to stepman, for a pre-warmed
#  cache for the StepLib
RUN bitrise stepman setup -c https://github.com/bitrise-io/bitrise-steplib.git
RUN bitrise stepman update

# Install fixed npm version
# releases: https://github.com/npm/cli/releases
RUN npm install -g npm@6.13.4

# install Go
#  from official binary package
RUN wget -q https://storage.googleapis.com/golang/go${TOOL_VER_GO}.linux-amd64.tar.gz -O go-bins.tar.gz \
    && tar -C /usr/local -xvzf go-bins.tar.gz \
    && rm go-bins.tar.gz
# ENV setup
ENV PATH $PATH:/usr/local/go/bin
# Go Workspace dirs & envs
# From the official Golang Dockerfile
#  https://github.com/docker-library/golang
ENV GOPATH /bitrise/go
ENV PATH $GOPATH/bin:$PATH
# 755 because Ruby complains if 777 (warning: Insecure world writable dir ... in PATH)
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 755 "$GOPATH"

# ------------------------------------------------------
# --- Cleanup, Workdir and revision

# Cleaning
RUN apt-get clean

ENV BITRISE_DOCKER_REV_NUMBER_ANDROID_NDK_LTS v2020_04_28_1
CMD bitrise --version
