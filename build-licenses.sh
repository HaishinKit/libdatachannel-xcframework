#!/bin/bash

OUTPUT="LICENSES"
> "$OUTPUT"

CMAKEDIR="build/macosx"  # 事前に CMake で configure 済みのディレクトリ
CACHE="$CMAKEDIR/CMakeCache.txt"

if [ ! -f "$CACHE" ]; then
    exit 1
fi

grep "_SOURCE_DIR:" "$CACHE" | while IFS='=' read -r var path; do
    LIBNAME=$(basename "$path")
    LICENSE_FILE=""

    for f in "$path"/LICENSE* "$path"/COPYING*; do
        [ -f "$f" ] && LICENSE_FILE="$f" && break
    done

    if [ -n "$LICENSE_FILE" ]; then
        echo "========================================================================" >> "$OUTPUT"
        echo "Library: $LIBNAME" >> "$OUTPUT"
        echo "========================================================================" >> "$OUTPUT"
        cat "$LICENSE_FILE" >> "$OUTPUT"
        echo -e "\n\n" >> "$OUTPUT"
    else
        echo "LICENSE not found for $LIBNAME"
    fi
done

OPENSSL_LICENSE_PATH="OpenSSL/LICENSE.txt"
if [ -f "$OPENSSL_LICENSE_PATH" ]; then
    echo "========================================================================" >> "$OUTPUT"
    echo "Library: OpenSSL" >> "$OUTPUT"
    echo "========================================================================" >> "$OUTPUT"
    cat "$OPENSSL_LICENSE_PATH" >> "$OUTPUT"
    echo -e "\n\n" >> "$OUTPUT"
else
    echo "OpenSSL LICENSE not found at $OPENSSL_LICENSE_PATH"
fi

echo "All licenses collected into $OUTPUT"
