module dmagick.c.histogram;

import core.stdc.stdio;

import dmagick.c.exception;
import dmagick.c.image;
import dmagick.c.magickType;
import dmagick.c.pixel;

extern(C)
{
	struct ColorPacket
	{
		PixelPacket
			pixel;

		IndexPacket
			index;

		MagickSizeType
			count;
	}

	ColorPacket* GetImageHistogram(const(Image)*, size_t*, ExceptionInfo*);

	Image* UniqueImageColors(const(Image)*, ExceptionInfo*);

	MagickBooleanType IsHistogramImage(const(Image)*, ExceptionInfo*);
	MagickBooleanType IsPaletteImage(const(Image)*, ExceptionInfo*);
	MagickBooleanType MinMaxStretchImage(Image*, const ChannelType, const double, const double);

	size_t GetNumberColors(const(Image)*, FILE*, ExceptionInfo*);
}
