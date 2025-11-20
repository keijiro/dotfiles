# Unity/Android tools on macOS
if [ "$(uname)" = "Darwin" ]; then
    UNITY_ROOT=/Applications/Unity/Hub/Editor
    if [ -d "$UNITY_ROOT" ]; then
        latest_unity=$(find "$UNITY_ROOT" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort -V | tail -n 1)
        if [ -n "$latest_unity" ]; then
            tools_dir="$latest_unity/Unity.app/Contents/Tools"
            helpers_dir="$latest_unity/Unity.app/Contents/Helpers"
            if [ -d "$tools_dir" ]; then
                export PATH="$PATH:$tools_dir"
            elif [ -d "$helpers_dir" ]; then
                export PATH="$PATH:$helpers_dir"
            fi
        fi

        latest_android=
        while IFS= read -r dir; do
            android_player="$dir/PlaybackEngines/AndroidPlayer"
            [ -d "$android_player" ] && latest_android="$dir"
        done <<EOF
$(find "$UNITY_ROOT" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort -V)
EOF

        if [ -n "$latest_android" ]; then
            android_player="$latest_android/PlaybackEngines/AndroidPlayer"
            sdk_dir="$android_player/SDK"
            ndk_dir="$android_player/NDK"
            [ -d "$sdk_dir" ] && export ANDROID_SDK_ROOT="$sdk_dir"
            [ -d "$ndk_dir" ] && export ANDROID_NDK_ROOT="$ndk_dir"
            platform_tools="$sdk_dir/platform-tools"
            [ -d "$platform_tools" ] && export PATH="$PATH:$platform_tools"
        fi
    fi
fi
