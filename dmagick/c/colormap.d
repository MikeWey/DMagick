module dmagick.c.colormap;

import dmagick.c.image;
import dmagick.c.magickType;

alias ptrdiff_t ssize_t;

extern(C)
{
	MagickBooleanType AcquireImageColormap(Image*, const size_t);
	MagickBooleanType CycleColormapImage(Image*, const ssize_t);
	MagickBooleanType SortColormapByIntensity(Image*);
}
