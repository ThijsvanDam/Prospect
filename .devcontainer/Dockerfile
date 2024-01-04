# Versions are overwritten by dockerfile args
ARG ELIXIR_VERSION="1.16.0"
ARG PHOENIX_VERSION="1.7.10"
FROM elixir:${ELIXIR_VERSION}

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# This Dockerfile adds a non-root user with sudo access. Use the "remoteUser"
# property in devcontainer.json to use it. On Linux, the container user's GID/UIDs
# will be updated to match your local UID/GID (when using the dockerFile property).
# See https://aka.ms/vscode-remote/containers/non-root-user for details.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Configure apt and install packages
# hadolint ignore=DL3008
RUN apt-get update
RUN apt-get -y install --no-install-recommends apt-utils dialog 2>&1
# Install bash tree
RUN apt-get -y install --no-install-recommends tree
# Install git iproute2, procps, lsb-release (useful for CLI installs)
RUN apt-get -y install --no-install-recommends git iproute2 procps iproute2 lsb-release ca-certificates
RUN apt-get -y install build-essential postgresql-client inotify-tools 
# Flutter deps
RUN apt-get -y install openjdk-17-jdk-headless xz-utils curl wget zip unzip libgconf-2-4 gdb libstdc++6 libglu1-mesa fonts-droid-fallback python3 libxtst6

# Create a non-root user to use if preferred - see https://aka.ms/vscode-remote/containers/non-root-user.
RUN groupadd --gid $USER_GID $USERNAME 
RUN useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME 
# [Optional] Add sudo support for the non-root user
RUN apt-get install -y sudo 
RUN echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME
RUN chmod 0440 /etc/sudoers.d/$USERNAME


# Clean up
RUN apt-get autoremove -y
RUN apt-get clean -y
RUN rm -rf /var/lib/apt/lists/*

# Change user
USER ${USERNAME}

# Android SDK
# https://developer.android.com/studio#downloads
ENV ANDROID_SDK_TOOLS_VERSION=8512546
ENV ANDROID_PLATFORM_VERSION=33
ENV ANDROID_BUILD_TOOLS_VERSION=33.0.0
ENV ANDROID_HOME="/home/$USERNAME/android-sdk-linux"
ENV ANDROID_SDK_ROOT="$ANDROID_HOME"
ENV PATH=${PATH}:${ANDROID_HOME}/cmdline-tools/cmdline-tools/bin:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/emulator
# Flutter SDK
# https://flutter.dev/docs/development/tools/sdk/releases?tab=linux
ENV FLUTTER_CHANNEL="stable"
ENV FLUTTER_VERSION="3.16.5"
# Make sure to use the needed channel and version for this.
ENV FLUTTER_HOME="/home/$USERNAME/flutter"
ENV PATH=${PATH}:${FLUTTER_HOME}/bin

# Android SDK	
RUN curl -C - --output ~/android-sdk-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_TOOLS_VERSION}_latest.zip
RUN mkdir -p ${ANDROID_HOME}/
RUN unzip -q ~/android-sdk-tools.zip -d ${ANDROID_HOME}/cmdline-tools/
RUN rm ~/android-sdk-tools.zip
RUN yes | sdkmanager --licenses
RUN touch /home/$USERNAME/.android/repositories.cfg
RUN sdkmanager platform-tools
RUN sdkmanager emulator
RUN sdkmanager "platforms;android-${ANDROID_PLATFORM_VERSION}" "build-tools;$ANDROID_BUILD_TOOLS_VERSION"
RUN sdkmanager --install "cmdline-tools;latest"
# create emulator android	
RUN sdkmanager "system-images;android-${ANDROID_PLATFORM_VERSION};google_apis;x86_64"
RUN echo "no" | avdmanager create avd -n Android${ANDROID_PLATFORM_VERSION} -k "system-images;android-${ANDROID_PLATFORM_VERSION};google_apis;x86_64"


# Flutter SDK
RUN curl -C - --output ~/flutter.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/${FLUTTER_CHANNEL}/linux/flutter_linux_${FLUTTER_VERSION}-${FLUTTER_CHANNEL}.tar.xz
RUN tar -xf ~/flutter.tar.xz -C ~
RUN rm ~/flutter.tar.xz
RUN flutter config --android-sdk "${ANDROID_SDK_ROOT}"
RUN yes | flutter doctor --android-licenses
RUN flutter config --no-analytics

# Install Hex (elixir) pkg manager, Rebar3 (erlang) pkg manager, and phoenix installer
RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix archive.install hex phx_new ${PHOENIX_VERSION}

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=dialog

# WORKDIR /app
EXPOSE 1337