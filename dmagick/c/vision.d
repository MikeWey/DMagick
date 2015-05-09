module dmagick.c.vision;

import dmagick.c.exception;
import dmagick.c.image;
import dmagick.c.magickVersion;

extern(C)
{
	static if ( MagickLibVersion >= 0x664 )
	{
		Image* ConnectedComponentsImage(const(Image)*, const size_t, ExceptionInfo*);
	}
}
