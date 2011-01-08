module dmagick.c.identify;

import core.stdc.stdio;

import dmagick.c.image;
import dmagick.c.magickType;

extern(C) MagickBooleanType IdentifyImage(Image*, FILE*, const MagickBooleanType);
