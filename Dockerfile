FROM quay.io/bitriseio/android-ndk:v2018_05_05-06_07-b990

ENV TOOL_VER_BITRISE_CLI="1.16.0"

# ------------------------------------------------------

RUN apt-get update -qq


# ------------------------------------------------------
# --- Git config

# Git config
RUN git config --global user.email builds@bitrise.io
RUN git config --global user.name "Bitrise Bot"

# ------------------------------------------------------
# --- SSH config

COPY ./ssh/config /root/.ssh/config


# ------------------------------------------------------
# --- Bitrise CLI

#
# Install Bitrise CLI
RUN curl -fL https://github.com/bitrise-io/bitrise/releases/download/${TOOL_VER_BITRISE_CLI}/bitrise-$(uname -s)-$(uname -m) > /usr/local/bin/bitrise
RUN chmod +x /usr/local/bin/bitrise
# remove ancient versions of envman & stepman, which were installed in /usr/local/bin
RUN rm /usr/local/bin/envman /usr/local/bin/stepman
RUN bitrise setup
RUN bitrise envman -version
RUN bitrise stepman -version
# setup the default StepLib collection to stepman, for a pre-warmed
#  cache for the StepLib
RUN bitrise stepman setup -c https://github.com/bitrise-io/bitrise-steplib.git
RUN bitrise stepman update


# ------------------------------------------------------
# --- Cleanup, Workdir and revision

# Cleaning
RUN apt-get clean

ENV BITRISE_DOCKER_REV_NUMBER_ANDROID_NDK_LTS v2018_05_16_1
CMD bitrise --version
