# Setting the evironment variables for Android SDK.
if [ `uname` = "Darwin" ]; then
    export ANDROID_SDK_ROOT=~/Library/android-sdk-macosx
    export ANDROID_NDK_ROOT=~/Library/android-ndk-r8e
    export PATH=$PATH:$ANDROID_SDK_ROOT/tools
    export PATH=$PATH:$ANDROID_SDK_ROOT/platform-tools
fi
