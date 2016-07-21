FROM bitriseio/android-ndk:2016_05_26_1


# ------------------------------------------------------
# --- Install / update required tools

RUN apt-get update -qq


# ------------------------------------------------------
# --- Bitrise CLI

#
# Install Bitrise CLI
RUN curl -fL https://github.com/bitrise-io/bitrise/releases/download/1.3.6/bitrise-$(uname -s)-$(uname -m) > /usr/local/bin/bitrise
RUN chmod +x /usr/local/bin/bitrise
RUN bitrise setup --minimal
RUN envman -version
RUN stepman -version
# setup the default StepLib collection to stepman, for a pre-warmed
#  cache for the StepLib
RUN stepman setup -c https://github.com/bitrise-io/bitrise-steplib.git
RUN stepman update


# ------------------------------------------------------
# --- Cleanup, Workdir and revision

# Cleaning
RUN apt-get clean

ENV BITRISE_DOCKER_REV_NUMBER_ANDROID_NDK_LTS v2016_07_21_1
CMD bitrise --version