module dmagick.c.display;

import dmagick.c.exception;
import dmagick.c.image;
import dmagick.c.magickType;

extern(C)
{
	MagickBooleanType DisplayImages(const(ImageInfo)*, Image*);
	MagickBooleanType RemoteDisplayCommand(const(ImageInfo)*, const(char)*, const(char)*, ExceptionInfo*);
}
