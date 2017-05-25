#!/bin/sh

echo $PACKAGE_DIR

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

sed 's/@MagickLibVersion@/'$MAGICK_VERSION'/g' "$PACKAGE_DIR/dmagick/c/magickVersion.d.in" | \
sed 's/@MagickLibVersionText@/'$MAGICK_VERSION_TEXT'/g' | \
sed 's/@QuantumDepth@/'$MAGICK_QUANTUM_DEPTH'/g' | \
sed 's/@HDRI@/'$MAGICK_HDRI'/g' > "$PACKAGE_DIR/dmagick/c/magickVersion.d"
