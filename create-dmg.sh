#!/bin/bash
echo "Preparing DMG staging folder..."
rm -rf dmg_stage
mkdir -p dmg_stage
cp -r "Local RTMP Server.app" dmg_stage/
ln -s /Applications dmg_stage/Applications

echo "Creating DMG..."
hdiutil create -volname "Local RTMP Server 3.0" -srcfolder dmg_stage -ov -format UDZO "Local RTMP Server 3.0.dmg"

echo "Cleaning up..."
rm -rf dmg_stage

echo "Done! Local RTMP Server 3.0.dmg created."
