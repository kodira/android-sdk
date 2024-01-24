FROM openjdk:17-bullseye

USER root
WORKDIR /opt

ENV ANDROID_TOOLS_URL "https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip"
ENV ANDROID_HOME "/opt/android-sdk"
ENV ANDROID_PLATFORM_VERSION "34"
ENV ANDROID_BUILD_TOOLS_VERSION "33.0.2"
ENV ANDROID_NDK_VERSION "21.4.7075529"
ENV ANDROID_CMAKE_VERSION "3.18.1"

RUN unset ANDROID_NDK_HOME

# Download Android SDK
RUN mkdir "$ANDROID_HOME" .android \
    && cd "$ANDROID_HOME" \
    && curl -s -o tools.zip $ANDROID_TOOLS_URL \
    && unzip tools.zip \
    && rm tools.zip \
    && yes | $ANDROID_HOME/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_HOME --licenses

# Install Android Build Tool and Libraries
RUN touch /root/.android/repositories.cfg
RUN $ANDROID_HOME/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_HOME --update
RUN $ANDROID_HOME/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_HOME --install \
    "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" \
    "platforms;android-${ANDROID_PLATFORM_VERSION}" \
    "platform-tools" \
    "ndk;${ANDROID_NDK_VERSION}" \
    "cmake;${ANDROID_CMAKE_VERSION}"

# Install cmake, gradle and NodeJS
# cmake is sometimes needed for other scripts that do not know about cmake from Android SDK
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
RUN apt-get update && apt-get install -y cmake gradle nodejs

# Install tool to publish to github
RUN wget -q "https://github.com/buildkite/github-release/releases/download/v1.0/github-release-linux-amd64" -O /usr/local/bin/github-release \
    && chmod +x /usr/local/bin/github-release

RUN mkdir /opt/code
WORKDIR /opt/code

# Expose gradle cache to speed up builds
RUN mkdir /root/.gradle
VOLUME /root/.gradle

ENV KEYSTORE_PASSWORD "override me"
