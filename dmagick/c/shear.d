module dmagick.c.shear;

import dmagick.c.exception;
import dmagick.c.image;
import dmagick.c.magickVersion;

extern(C)
{
	Image* DeskewImage(const(Image)*, const double, ExceptionInfo*);

	static if ( MagickLibVersion >= 0x674 )
	{
		Image* IntegralRotateImage(const(Image)*, size_t, ExceptionInfo*);
	}

	Image* ShearImage(const(Image)*, const double, const double, ExceptionInfo*);

	static if ( MagickLibVersion >= 0x674 )
	{
		Image* ShearRotateImage(const(Image)*, const double, ExceptionInfo*);
	}
}
