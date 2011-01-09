module dmagick.c.stream;

import dmagick.c.exception;
import dmagick.c.image;
import dmagick.c.magickType;

extern(C)
{
	alias size_t function(const(Image)*, const(void)*, const size_t) StreamHandler;

	Image* ReadStream(const(ImageInfo)*, StreamHandler, ExceptionInfo*);

	MagickBooleanType WriteStream(const(ImageInfo)*, Image*, StreamHandler);
}
