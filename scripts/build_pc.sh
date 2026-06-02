#!/bin/bash
cd pc
flutter pub get
flutter build windows
echo "PC build complete: build/windows/runner/Release/cypher.exe"
