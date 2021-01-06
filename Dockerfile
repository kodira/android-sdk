FROM openjdk:8-stretch

USER root
WORKDIR /opt

ENV ANDROID_TOOLS_URL "https://dl.google.com/android/repository/commandlinetools-linux-6200805_latest.zip"
ENV ANDROID_HOME "/opt/android-sdk"
ENV ANDROID_PLATFORM_VERSION "30"
ENV ANDROID_BUILD_TOOLS_VERSION "29.0.3"
ENV ANDROID_NDK_VERSION "21.0.6113669"

RUN unset ANDROID_NDK_HOME

# Download Android SDK
RUN mkdir "$ANDROID_HOME" .android \
    && cd "$ANDROID_HOME" \
    && curl -s -o tools.zip $ANDROID_TOOLS_URL \
    && unzip tools.zip \
    && rm tools.zip \
    && yes | $ANDROID_HOME/tools/bin/sdkmanager --sdk_root=$ANDROID_HOME --licenses

# Install Android Build Tool and Libraries
RUN touch /root/.android/repositories.cfg
RUN $ANDROID_HOME/tools/bin/sdkmanager --sdk_root=$ANDROID_HOME --update
RUN $ANDROID_HOME/tools/bin/sdkmanager --sdk_root=$ANDROID_HOME --install \
    "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" \
    "platforms;android-${ANDROID_PLATFORM_VERSION}" \
    "platform-tools" \
    "ndk;${ANDROID_NDK_VERSION}"

# Needed for NDK 
RUN apt-get update && apt-get install -y cmake

# Install tool to publish to github
RUN wget -q "https://github.com/buildkite/github-release/releases/download/v1.0/github-release-linux-amd64" -O /usr/local/bin/github-release && chmod +x /usr/local/bin/github-release

RUN mkdir /opt/code
WORKDIR /opt/code

# Expose gradle cache to speed up builds
RUN mkdir /root/.gradle
VOLUME /root/.gradle

ENV KEYSTORE_PASSWORD "override me"

