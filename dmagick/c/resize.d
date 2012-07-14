module dmagick.c.resize;

import dmagick.c.exception;
import dmagick.c.image;
import dmagick.c.magickVersion;
import dmagick.c.pixel;
import dmagick.c.resample;

extern(C)
{
	Image* AdaptiveResizeImage(const(Image)*, const size_t, const size_t, ExceptionInfo*);

	static if ( MagickLibVersion >= 0x678 )
	{
		Image* InterpolativeResizeImage(const(Image)*, const size_t, const size_t, const InterpolatePixelMethod, ExceptionInfo*);
	}

	Image* LiquidRescaleImage(const(Image)*, const size_t, const size_t, const double, const double, ExceptionInfo*);
	Image* MagnifyImage(const(Image)*, ExceptionInfo*);
	Image* MinifyImage(const(Image)*, ExceptionInfo*);
	Image* ResampleImage(const(Image)*, const double, const double, const FilterTypes, const double, ExceptionInfo*);
	Image* ResizeImage(const(Image)*, const size_t, const size_t, const FilterTypes, const double, ExceptionInfo*);
	Image* SampleImage(const(Image)*, const size_t, const size_t, ExceptionInfo*);
	Image* ScaleImage(const(Image)*, const size_t, const size_t, ExceptionInfo*);
	Image* ThumbnailImage(const(Image)*, const size_t, const size_t, ExceptionInfo*);

	static if ( MagickLibVersion < 0x665 )
	{
		Image* ZoomImage(const(Image)*, const size_t, const size_t, ExceptionInfo*);
	}
}
