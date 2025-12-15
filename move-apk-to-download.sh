#!/bin/bash

rm -rf ./download

mkdir -p ./download

timestamp=$(date +"%H-%M-%S_%d-%m-%Y")

for file in build/*/*/*/app-arm64-v8a-release.apk; do
    filename=$(basename "$file")
    new_filename="${filename%.apk}-$timestamp.apk"
    cp "$file" "./download/$new_filename"
done

echo "File .apk telah disalin ke ./download/ dengan timestamp."
