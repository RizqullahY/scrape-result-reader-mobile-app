#!/bin/bash

# Exit jika ada error
set -e

# 1. Build Flutter APK dengan split per ABI
echo "Membangun APK Flutter..."
flutter build apk --split-per-abi

# 2. Jalankan move_file.sh untuk menyalin APK dengan timestamp
echo "Menyalin APK ke folder download dengan timestamp..."
./move-apk-to-download.sh

# 3. Auto git commit
echo "Menambahkan perubahan ke git..."
git add .

# Membuat pesan commit dengan timestamp
timestamp=$(date +"%Y-%m-%d %H:%M:%S")
git commit -m "Auto commit APK build: $timestamp"

echo "Selesai! APK telah dibangun, disalin, dan perubahan dicommit ke git."
