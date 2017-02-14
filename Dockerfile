FROM bitriseio/android-ndk:2016_05_26_1


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
RUN curl -fL https://github.com/bitrise-io/bitrise/releases/download/1.5.4/bitrise-$(uname -s)-$(uname -m) > /usr/local/bin/bitrise
RUN chmod +x /usr/local/bin/bitrise
RUN rm /usr/local/bin/envman /usr/local/bin/stepman
RUN bitrise setup
RUN /root/.bitrise/tools/envman -version
RUN /root/.bitrise/tools/stepman -version
# setup the default StepLib collection to stepman, for a pre-warmed
#  cache for the StepLib
RUN /root/.bitrise/tools/stepman setup -c https://github.com/bitrise-io/bitrise-steplib.git
RUN /root/.bitrise/tools/stepman update


# ------------------------------------------------------
# --- Cleanup, Workdir and revision

# Cleaning
RUN apt-get clean

ENV BITRISE_DOCKER_REV_NUMBER_ANDROID_NDK_LTS v2017_02_14_1
CMD bitrise --version
