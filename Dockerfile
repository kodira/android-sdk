FROM openjdk:8-stretch

USER root
WORKDIR /opt

ENV SDK_URL "https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip"
ENV ANDROID_HOME "/opt/android-sdk"
ENV ANDROID_VERSION "28"
ENV ANDROID_BUILD_TOOLS_VERSION "28.0.3"

RUN unset ANDROID_NDK_HOME

# Download Android SDK
RUN mkdir "$ANDROID_HOME" .android \
    && cd "$ANDROID_HOME" \
    && curl -s -o sdk.zip $SDK_URL \
    && unzip sdk.zip \
    && rm sdk.zip \
    && yes | $ANDROID_HOME/tools/bin/sdkmanager --licenses

# Install Android Build Tool and Libraries
RUN touch /root/.android/repositories.cfg
RUN $ANDROID_HOME/tools/bin/sdkmanager --update
RUN $ANDROID_HOME/tools/bin/sdkmanager "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" \
    "platforms;android-${ANDROID_VERSION}" \
    "platform-tools"

# Needed for gh-release.sh
RUN apt-get update && apt-get install -y jq

RUN mkdir /opt/code
WORKDIR /opt/code

ENV KEYSTORE_PASSWORD "override me"


