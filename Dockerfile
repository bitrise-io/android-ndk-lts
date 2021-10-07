FROM quay.io/bitriseio/android-ndk:v2018_05_05-06_07-b990

ENV TOOL_VER_BITRISE_CLI="1.48.0" \
    TOOL_VER_GO="1.16.5"

# ------------------------------------------------------

#
# This is a workaround / fix story is in the backlog
#
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 6B05F25D762E3157
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 23E7166788B63E1E
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 8B57C5C2836F4BEB
RUN apt-get clean

RUN mkdir -p /etc/apt/sources.list.d \
    && cp /usr/share/doc/apt/examples/sources.list /etc/apt/sources.list
# --- Add ppa
RUN apt-key adv --refresh-keys --keyserver keyserver.ubuntu.com
RUN add-apt-repository ppa:git-core/ppa \
    && add-apt-repository ppa:openjdk-r/ppa

RUN rm /etc/ssl/certs/DST_Root_CA_X3.pem \
    && sed -i '/mozilla\/DST_Root_CA_X3.crt/d' /etc/ca-certificates.conf
RUN apt-get install --fix-missing ca-certificates -y
RUN update-ca-certificates --fresh
RUN apt-get update -qq

# install Go
#  from official binary package
RUN wget -q https://storage.googleapis.com/golang/go${TOOL_VER_GO}.linux-amd64.tar.gz -O go-bins.tar.gz \
    && tar -C /usr/local -xvzf go-bins.tar.gz \
    && rm go-bins.tar.gz

# --- Install java 11-jdk
RUN dpkg --add-architecture i386

RUN DEBIAN_FRONTEND=noninteractive apt-get update -qq \
    && apt-get install -y openjdk-11-jdk

# Keystore format has changed since JAVA 8 https://bugs.launchpad.net/ubuntu/+source/openjdk-9/+bug/1743139
RUN mv /etc/ssl/certs/java/cacerts /etc/ssl/certs/java/cacerts.old \
    && keytool -importkeystore -destkeystore /etc/ssl/certs/java/cacerts -deststoretype jks -deststorepass changeit -srckeystore /etc/ssl/certs/java/cacerts.old -srcstoretype pkcs12 -srcstorepass changeit \
    && rm /etc/ssl/certs/java/cacerts.old

# Select JAVA 11  as default
RUN sudo update-alternatives --set javac /usr/lib/jvm/java-11-openjdk-amd64/bin/javac
RUN sudo update-alternatives --set java /usr/lib/jvm/java-11-openjdk-amd64/bin/java
ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-amd64

# ------------------------------------------------------
# --- Update and configure Git

RUN apt-get install -y git 

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

ENV BITRISE_DOCKER_REV_NUMBER_ANDROID_NDK_LTS v2021_09_30
CMD bitrise --version
