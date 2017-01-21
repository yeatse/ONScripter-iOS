export set PATH=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin:$PATH
export set SDK_CC=`xcrun -find -sdk iphoneos clang`
export set SDK_CFLAGS='-arch armv7 -arch arm64 -miphoneos-version-min=7.0'
export set SDK_PATH=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk
export set HOST=arm-apple-darwin
export set INSTALL_PATH=$PWD/Release-iphoneos
mkdir -p $INSTALL_PATH
