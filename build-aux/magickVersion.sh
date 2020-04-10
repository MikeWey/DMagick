#!/bin/sh

echo $PACKAGE_DIR

CACHE_FILE=$PACKAGE_DIR/build-aux/magickVersion.cache

MAGICK_VERSION_CACHED="$(cat $CACHE_FILE 2>/dev/null)"

MAGICK_VERSION=$(pkg-config --modversion MagickCore | tr -d '.')
MAGICK_VERSION_TEXT=$(pkg-config --modversion MagickCore)
MAGICK_QUANTUM_DEPTH="16"
MAGICK_HDRI="false"

if [ -n "$(pkg-config --variable=libname MagickCore | grep 8)" ]; then
    MAGICK_QUANTUM_DEPTH="8"
elif [ -n "$(pkg-config --variable=libname MagickCore | grep 32)" ]; then
    MAGICK_QUANTUM_DEPTH="32"
elif [ -n "$(pkg-config --variable=libname MagickCore | grep 64)" ]; then
    MAGICK_QUANTUM_DEPTH="64"
fi

if [ -n "$(pkg-config --variable=libname MagickCore | grep HDRI)" ]; then
    MAGICK_HDRI="true"
fi

if [ "$MAGICK_VERSION_CACHED" != "$MAGICK_VERSION_TEXT" ]; then
    echo -n "$MAGICK_VERSION_TEXT" > $CACHE_FILE

    sed 's/@MagickLibVersion@/'$MAGICK_VERSION'/g' "$PACKAGE_DIR/dmagick/c/magickVersion.d.in" | \
    sed 's/@MagickLibVersionText@/'$MAGICK_VERSION_TEXT'/g' | \
    sed 's/@QuantumDepth@/'$MAGICK_QUANTUM_DEPTH'/g' | \
    sed 's/@HDRI@/'$MAGICK_HDRI'/g' > "$PACKAGE_DIR/dmagick/c/magickVersion.d"
fi
