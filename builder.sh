#!/bin/bash

BASE_DIR=/Users/applebro/Documents/Development/Personal/medium/bookletPdf
BUILD_DIR=$BASE_DIR/Builds
FOCUS_ARCHIVE=$BUILD_DIR/booklet.xcarchive
FOCUS_APP=$BUILD_DIR/booklet.app

echo "Building Focus..."

echo "Cleaning up old archive & app..."
rm -rf $FOCUS_ARCHIVE $FOCUS_APP

echo "Building archive..."
xcodebuild -workspace $BASE_DIR/booklet.xcworkspace -config Release -scheme Bocus -archivePath $FOCUS_ARCHIVE archive

echo "Exporting archive..."
xcodebuild -archivePath $FOCUS_ARCHIVE -exportArchive -exportPath $FOCUS_APP -exportFormat app

echo "Cleaning up archive..."
rm -rf $FOCUS_ARCHIVE

echo "Done"
