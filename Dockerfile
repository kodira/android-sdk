FROM eclipse-temurin:21-jdk-jammy

USER root
WORKDIR /opt

ENV ANDROID_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip"
ENV ANDROID_HOME="/opt/android-sdk"
ENV ANDROID_PLATFORM_VERSION="36"
ENV ANDROID_BUILD_TOOLS_VERSION="36.0.0"
ENV ANDROID_NDK_VERSION="28.2.13676358"
ENV ANDROID_CMAKE_VERSION="3.18.1"
ENV GRADLE_VERSION="8.13"

# Install required utilities
RUN apt-get update && apt-get install -y unzip curl wget && rm -rf /var/lib/apt/lists/*

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

# Install Gradle (Java 21 requires Gradle 8.5+, Debian packages only have 4.4.1)
RUN curl -s -L -o gradle.zip https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip \
    && unzip gradle.zip \
    && rm gradle.zip

ENV PATH="/opt/gradle-${GRADLE_VERSION}/bin:${PATH}"

# Install cmake and NodeJS
# cmake is sometimes needed for other scripts that do not know about cmake from Android SDK
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash -
RUN apt-get update && apt-get install -y cmake nodejs git

# Install tool to publish to github
RUN wget -q "https://github.com/buildkite/github-release/releases/download/v1.0/github-release-linux-amd64" -O /usr/local/bin/github-release \
    && chmod +x /usr/local/bin/github-release

RUN mkdir /opt/code
WORKDIR /opt/code

# Expose gradle cache to speed up builds
RUN mkdir /root/.gradle
VOLUME /root/.gradle

ENV KEYSTORE_PASSWORD="override me"

# Build arguments for versioning
ARG IMAGE_TAG=dev
ENV IMAGE_TAG=${IMAGE_TAG}

# Add image labels for metadata
LABEL org.opencontainers.image.title="Android SDK"
LABEL org.opencontainers.image.description="Docker image to build Android apps"
LABEL org.opencontainers.image.version="${IMAGE_TAG}"
