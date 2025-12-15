#!/bin/bash

# --- Variabel ---
# Mendapatkan stempel waktu (timestamp) saat ini dalam format YYYYMMDD_HHMMSS
TIMESTAMP=$(date +"%H%M%S_%d%m%Y")
SOURCE_FILE="build/app/outputs/apk/release/app-arm64-v8a-release.apk" # Ganti path ini jika berbeda
DEST_DIR="./download"
NEW_FILE_NAME="app-release_arm64-v8a_${TIMESTAMP}.apk"
DEST_PATH="${DEST_DIR}/${NEW_FILE_NAME}"

# Pastikan path build Flutter Anda benar. Path standar rilis adalah:
# build/app/outputs/apk/release/app-arm64-v8a-release.apk
# Jika Anda menggunakan --split-per-abi, path-nya mungkin sedikit berbeda,
# pastikan Anda menargetkan file yang benar.
# Berdasarkan skrip sebelumnya, path umum setelah --split-per-abi adalah:
# build/app/outputs/apk/release/app-arm64-v8a/app-release.apk
# Kami akan gunakan asumsi yang lebih spesifik jika build Anda sukses.

# --- 1. Buat Direktori Tujuan ---
mkdir -p "$DEST_DIR"

# Periksa apakah file sumber ada
if [ ! -f "$SOURCE_FILE" ]; then
    echo "🚨 ERROR: File APK sumber tidak ditemukan di $SOURCE_FILE."
    echo "Pastikan Anda menjalankan 'flutter build apk --split-per-abi' terlebih dahulu."
    exit 1
fi

# --- 2. Salin dan Ganti Nama File ---
echo "⚙️ Menyalin dan mengganti nama file APK..."

# Menyalin file sambil mengganti namanya
cp "$SOURCE_FILE" "$DEST_PATH"

# Periksa apakah operasi penyalinan berhasil
if [ $? -ne 0 ]; then
    echo "🚨 ERROR: Gagal menyalin file APK."
    exit 1
fi

echo "✅ File .apk telah disalin ke ${DEST_DIR}/"
echo "   Nama file baru: ${NEW_FILE_NAME}"