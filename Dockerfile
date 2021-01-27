FROM quay.io/bitriseio/android-ndk:v2018_05_05-06_07-b990

ENV TOOL_VER_BITRISE_CLI="1.44.0"

# ------------------------------------------------------

RUN apt-get update -qq

# --- Install java 11-jdk
RUN add-apt-repository ppa:openjdk-r/ppa \
    && dpkg --add-architecture i386

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-11-jdk

# Keystore format has changed since JAVA 8 https://bugs.launchpad.net/ubuntu/+source/openjdk-9/+bug/1743139
RUN mv /etc/ssl/certs/java/cacerts /etc/ssl/certs/java/cacerts.old \
    && keytool -importkeystore -destkeystore /etc/ssl/certs/java/cacerts -deststoretype jks -deststorepass changeit -srckeystore /etc/ssl/certs/java/cacerts.old -srcstoretype pkcs12 -srcstorepass changeit \
    && rm /etc/ssl/certs/java/cacerts.old

# Select JAVA 8  as default
RUN sudo update-java-alternatives --jre-headless --set java-1.8.0-openjdk-amd64
RUN sudo update-alternatives --set javac /usr/lib/jvm/java-8-openjdk-amd64/bin/javac

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
RUN npm install -g npm@6.13.4 appcenter-cli


RUN DEBIAN_FRONTEND=noninteractive apt-get -y install \
    jq \
    awscli


# ------------------------------------------------------
# --- Cleanup, Workdir and revision

# Cleaning
RUN apt-get clean

ENV BITRISE_DOCKER_REV_NUMBER_ANDROID_NDK_LTS v2020_05_19_1
CMD bitrise --version
