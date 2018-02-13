#!/bin/bash

bash build-love.sh

ROOT_DIR=`pwd`

rm -f AnotherBrick.zip
TMPDIR=`mktemp -d`
unzip love-0.10.2-win64.zip -d $TMPDIR
mv $TMPDIR/love-0.10.2-win64 $TMPDIR/AnotherBrick
cp game.love $TMPDIR/AnotherBrick
cd $TMPDIR/AnotherBrick
cat love.exe game.love > AnotherBrick.exe
zip -9 -r -D $ROOT_DIR/AnotherBrickWin_x64.zip .
cd $ROOT_DIR
rm -rf $TMPDIR
