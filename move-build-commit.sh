#!/bin/bash

# Exit jika ada error
set -e

echo "Membangun APK Flutter..."
flutter build apk --split-per-abi

./move-apk-to-download.sh

git add .

timestamp=$(date +"%Y-%m-%d %H:%M:%S")
git commit -m "Auto commit APK build: $timestamp"
git push origin master

