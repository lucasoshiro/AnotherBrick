#!/bin/bash

bash build-love.sh

export ROOT_DIR=`pwd`

export ANDROID_HOME="$ROOT_DIR/tools/android-linux"

## make android ID and name unique so we can have multiple installs
# restore original manifest and src subdir
cp tools/love-android-sdl2/original/AndroidManifest.xml tools/love-android-sdl2/ > /dev/null
rm tools/love-android-sdl2/src/love -r > /dev/null
cp tools/love-android-sdl2/original/love tools/love-android-sdl2/src/ -r > /dev/null

# get date and hope no participants compile at the same second
# datevar=`date +"%m%d%H%M%S"`

# replace id, name and src subdir
sed -i "s/loveToAndroid Game/AnotherBrick/g" tools/love-android-sdl2/AndroidManifest.xml
sed -i "s/love.to.android/br\.usp\.ime.\mac046.\AnotherBrick/g" tools/love-android-sdl2/AndroidManifest.xml
sed -i "s/love.to.android/br\.usp\.ime.\mac046.\AnotherBrick/g" tools/love-android-sdl2/src/love/to/android/LtaActivity.java
mv tools/love-android-sdl2/src/love/to/android tools/love-android-sdl2/src/br/usp/ime/mac046/AnotherBrick

## make the apk
rm game.apk > /dev/null
cd "tools/love-android-sdl2"
rm -r gen bin > /dev/null

cp ../../game.love assets/ > /dev/null
cp ../../icon.png res/drawable-xxhdpi/ic_launcher.png > /dev/null

ant debug

cp bin/love_android_sdl2-debug.apk ../../AnotherBrick.apk > /dev/null

cd $ROOT_DIR

adb install -r AnotherBrick.apk
