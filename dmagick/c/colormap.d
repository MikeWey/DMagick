module dmagick.c.colormap;

import dmagick.c.image;
import dmagick.c.magickType;
import dmagick.c.magickVersion;

alias ptrdiff_t ssize_t;

extern(C)
{
	static if (MagickLibVersion >= 0x662)
	{
		MagickBooleanType AcquireImageColormap(Image*, const size_t);
	}

	MagickBooleanType CycleColormapImage(Image*, const ssize_t);
	MagickBooleanType SortColormapByIntensity(Image*);
}
