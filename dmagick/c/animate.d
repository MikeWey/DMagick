module dmagick.c.animate;

import dmagick.c.image;
import dmagick.c.magickType;

extern(C) MagickBooleanType AnimateImages(const(ImageInfo)*, Image*);
