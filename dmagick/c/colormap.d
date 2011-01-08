module dmagick.c.colormap;

import core.sys.posix.sys.types;

import dmagick.c.image;
import dmagick.c.magickType;

extern(C)
{
	MagickBooleanType AcquireImageColormap(Image*, const size_t);
	MagickBooleanType CycleColormapImage(Image*, const ssize_t);
	MagickBooleanType SortColormapByIntensity(Image*);
}
