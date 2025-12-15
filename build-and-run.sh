#!/bin/bash

# --- Variabel ---
# Mendapatkan tanggal dan waktu saat ini dalam format yang mudah dibaca untuk commit
COMMIT_DATE=$(date +"%Y-%m-%d %H:%M:%S")
COMMIT_MESSAGE="Otomasi build dan commit pada $COMMIT_DATE"
MOVE_SCRIPT="./move-apk-to-download"

# Fungsi untuk menangani kesalahan
handle_error() {
    echo "🚨 ERROR: Gagal pada langkah $1."
    exit 1
}

# --- 1. Build Flutter APK ---
echo "🚀 Memulai Flutter build APK..."
flutter build apk --split-per-abi

# Periksa apakah build berhasil
if [ $? -ne 0 ]; then
    handle_error "Flutter Build"
fi
echo "✅ Build Flutter selesai."

# --- 2. Jalankan Skrip Pemindah APK ---
# Pastikan skrip pemindah sudah ada dan memiliki izin eksekusi
if [ -f "$MOVE_SCRIPT" ]; then
    echo "📂 Menjalankan skrip pemindah APK: $MOVE_SCRIPT"
    "$MOVE_SCRIPT"

    # Periksa apakah skrip pemindah berhasil
    if [ $? -ne 0 ]; then
        handle_error "Skrip Pemindah APK"
    fi
    echo "✅ Skrip pemindah APK selesai."
else
    echo "⚠️ Peringatan: Skrip $MOVE_SCRIPT tidak ditemukan. Melewati langkah pemindahan."
fi

# --- 3. Git Add, Commit, dan Push ---
echo "📦 Memulai Git add, commit, dan push..."

# Git add semua perubahan
git add .
if [ $? -ne 0 ]; then
    handle_error "Git Add"
fi

# Git commit dengan pesan yang berisi datetime
echo "💬 Melakukan commit dengan pesan: \"$COMMIT_MESSAGE\""
git commit -m "$COMMIT_MESSAGE"
if [ $? -ne 0 ]; then
    # Jika tidak ada perubahan untuk di-commit, git commit akan gagal, jadi kita cek pesannya
    if git status --porcelain | grep -q '^\(M\|A\|D\|R\|C\|U\)\s'; then
        handle_error "Git Commit"
    else
        echo "ℹ️ Tidak ada perubahan untuk di-commit. Melewati langkah push."
        exit 0 # Keluar dengan sukses karena tidak ada yang perlu di-push
    fi
fi

# Git push ke branch master
echo "⬆️ Melakukan Git push ke master..."
git push origin master
if [ $? -ne 0 ]; then
    handle_error "Git Push"
fi

echo "🎉 Semua langkah selesai dengan sukses!"