#!/bin/bash
cd mobile
flutter pub get
flutter build apk --release
echo "Mobile build complete: build/app/outputs/apk/release/app-release.apk"
