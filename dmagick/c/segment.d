module dmagick.c.segment;

import dmagick.c.colorspace;
import dmagick.c.exception;
import dmagick.c.image;
import dmagick.c.magickType;
import dmagick.c.pixel;

extern(C)
{
	MagickBooleanType GetImageDynamicThreshold(const(Image)*, const double, const double, MagickPixelPacket*, ExceptionInfo*);
	MagickBooleanType SegmentImage(Image*, const ColorspaceType, const MagickBooleanType, const double, const double);
}
