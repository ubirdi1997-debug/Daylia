#!/bin/bash
set -e

echo "=============================="
echo "🚀 Flutter + Android Setup"
echo "For GitHub Codespaces / CI"
echo "=============================="

FLUTTER_VERSION="stable"
ANDROID_SDK_ROOT="$HOME/android-sdk"
JAVA_VERSION="17"

sudo apt update -y
sudo apt install -y curl git unzip zip xz-utils libglu1-mesa ca-certificates wget openjdk-17-jdk

export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
echo "export JAVA_HOME=$JAVA_HOME" >> ~/.bashrc
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> ~/.bashrc

cd $HOME
git clone https://github.com/flutter/flutter.git -b stable || true
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc
export PATH="$PATH:$HOME/flutter/bin"

mkdir -p $ANDROID_SDK_ROOT/cmdline-tools
cd $ANDROID_SDK_ROOT
wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
unzip commandlinetools-linux-11076708_latest.zip
mv cmdline-tools cmdline-tools/latest

export ANDROID_SDK_ROOT=$ANDROID_SDK_ROOT
export ANDROID_HOME=$ANDROID_SDK_ROOT
export PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_SDK_ROOT/platform-tools

echo "export ANDROID_SDK_ROOT=$ANDROID_SDK_ROOT" >> ~/.bashrc
echo "export ANDROID_HOME=$ANDROID_SDK_ROOT" >> ~/.bashrc
echo 'export PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin' >> ~/.bashrc
echo 'export PATH=$PATH:$ANDROID_SDK_ROOT/platform-tools' >> ~/.bashrc

yes | sdkmanager --licenses
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"

flutter doctor
