module dmagick.c.monitor;

import dmagick.c.image;
import dmagick.c.magickType;

extern(C)
{
	alias MagickBooleanType function(const(char)*, const MagickOffsetType, const MagickSizeType, void*) MagickProgressMonitor;

	MagickProgressMonitor SetImageProgressMonitor(Image*, const MagickProgressMonitor, void*);
	MagickProgressMonitor SetImageInfoProgressMonitor(ImageInfo*, const MagickProgressMonitor, void*);
}

static pure nothrow MagickBooleanType QuantumTick(const MagickOffsetType offset, const MagickSizeType span)
{
	if (span <= 100)
		return(true);
	if (offset == cast(MagickOffsetType) (span-1))
		return(true);
	if ((offset % (span/100)) == 0)
		return(true);
	return(false);
}
